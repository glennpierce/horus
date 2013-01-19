#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 
# Copyright 2012 Glenn Pierce
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

import sys, re, os, os.path, time, datetime, serial, logging, traceback, signal
from daemon import Daemon
from multiprocessing import Process, Queue
from collections import defaultdict

import bottle
import sqlite3
from bottle import install, route, run, template, TEMPLATE_PATH, request, redirect, error
from logging.handlers import RotatingFileHandler

import bottle_sqlite

script_dir, script_name = os.path.split(os.path.abspath(__file__))
dbfile = os.path.join(script_dir,'horus.db')
#sys.path.append(script_dir)
TEMPLATE_PATH.append(script_dir)

stop_queue = Queue()

try:
    from setproctitle import setproctitle
    from setproctitle import getproctitle
except ImportError:
    setproctitle = lambda t: None
    getproctitle = lambda : ""

def create_logger(foreground=False, verbose=False):
    logger = logging.getLogger()

    if verbose:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    if foreground:
        handler = logging.StreamHandler()
    else:
        handler = RotatingFileHandler('/var/log/horus.log', maxBytes=204800)

    logger.addHandler(handler)
    return logger

def process_data():
    setproctitle("horus - data processor")
    ser = serial.Serial(
        port='/dev/ttyUSB0',
        baudrate=19200,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout = 1
    )

    logger = create_logger(foreground=False, verbose=True)
    try:
        conn = sqlite3.connect(dbfile)
        cur = conn.cursor()
        count=0
        while stop_queue.empty():
            count+=1
            current = ser.readline()[:-1]
            if current:
                try:
                    cur.execute("INSERT INTO current(amps) VALUES (?)", (float(current),))
                    conn.commit()
                except Exception, e:
                    print e
    except KeyboardInterrupt, e:
        logging.info("exiting horus")
        return
    except Exception, e:
        process_data()   # Try again
        return
    finally:
        conn.close()
        logging.info("Finished process_data")

install(bottle_sqlite.SQLitePlugin(dbfile=dbfile))

@error(404)
def error404(error):
    return 'Nothing here, sorry'

@bottle.hook('after_request')
def enable_cors():
    bottle.response.headers['X-UA-Compatible: chrome=1'] = '*'
    
@route('/favicon.ico')
def send_favicon():
    return bottle.static_file('favicon.ico', root=os.path.join(script_dir,'static/'))

@route('/static/<filepath:path>')
def server_static(filepath):
    return bottle.static_file(filepath, root=os.path.join(script_dir,'static/'))

@route('/data/<from_year:int>/<from_month:int>/<from_day:int>/<to_year:int>/<to_month:int>/<to_day:int>',
  method=['GET'])
def data(db, from_year,from_month,from_day,to_year,to_month,to_day):
    d1 = datetime.date(year=from_year,month=from_month,day=from_day)
    d2 = datetime.date(year=to_year,month=to_month,day=to_day)

    if d2 <= d1:
        raise HTTPError(status=500, body="End date must not preceed start date")    

    timestamp1 = time.mktime(d1.timetuple())
    timestamp2 = time.mktime(d2.timetuple())

    diff = d2 - d1

    months = defaultdict(float)

    cur = db.cursor()
    print time.time()

    # 151200 is number of samples in 7 days
    if diff.total_seconds() < 151200:
        cur.execute("select datetime(timestamp, 'localtime'),amps from current")
    else:
        cur.execute("select datetime(timestamp, 'locatime'),amps from current_days")

    result = [(str(r[0]) + "," + str(r[1])) for r in cur.fetchall()]
    print time.time()
    print result

    return 'Date,Amps\n' + '\n'.join(result)

@route('/', method=['GET', 'POST'])
def default():
    return template('index')

class HorusServer(Daemon):

    def __init__(self, pidfile='/var/run/horus.pid', host="0.0.0.0", port=80, foreground=False):
        super(HorusServer, self).__init__(pidfile,
                                            stdin='/dev/null', stdout='/dev/null', stderr='/dev/null')
        self.foreground = foreground
        self.host=host
        self.port=port
        self.process = None
        self.process_data_grouper = None

    def start(self):
        logging.info("starting horus")
        if self.foreground:
            return self.run()
        else:
            super(HorusServer, self).start()

    def shutdown(self):
        os.kill(self.process.pid, signal.SIGINT)

    def stop(self):
        stop_queue.put(True) 
        if self.process:
            self.process.join()
        logging.critical("done stop callback - here2")

        super(HorusServer, self).stop()

    def run(self):
        self.process = Process(target=process_data)
        self.process.start()

        bottle.debug(True)
        app = bottle.default_app()

        logging.info("started webserver host: %s port: %s", self.host, self.port)
        try:
            bottle.run(server='cherrypy', app=app, host=self.host, port=self.port, debug=True)
        except Exception, e:
            logging.critical("bottle: %s", e)
            sys.exit(1)

if __name__ == "__main__":

    usage = '''
            "usage: @
            "Examples"
            @ -d info -f -p 80 start
            @ --debug info --foreground --port 9870 start
            @ stop
            '''.replace('@', sys.argv[0])

    from optparse import OptionParser

    parser = OptionParser(usage=usage)
    parser.add_option("-f", "--foreground", dest="foreground", action="store_true", default=False, help="Run in foreground")
    parser.add_option("-v", "--verbose", dest="verbose", action="store_true", default=False, help="Verbose logging")
    parser.add_option("-p", "--port", dest="port",  default=80, help="Port to run on")
    (options, args) = parser.parse_args()

    logger = create_logger(foreground=options.foreground, verbose=options.verbose)

    server = HorusServer('/var/run/horus.pid', port=options.port, foreground=options.foreground)

    if len(args) != 1:
        print usage
        sys.exit(1)

    try:
        if args[0] == 'start':
            server.start()
        elif args[0] == 'stop':
            server.stop()
    except KeyboardInterrupt, e:
        logging.info("attempting to shut down")  
        server.stop()
