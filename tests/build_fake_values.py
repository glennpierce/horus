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

import sys, time, datetime, random, logging
import sqlite3

dbfile = 'horus.db'

conn = sqlite3.connect(dbfile)
cur = conn.cursor()

now = datetime.datetime.now()
t = start_time = datetime.datetime(year=2012, month=03, day=1)

count=0
while t < now:
    timestamp = time.mktime(t.timetuple())
    value = random.random() * 200.0
    try:
        cur.execute("INSERT INTO current_minutes(timestamp, amps) VALUES (?,?)", (timestamp, value))
        t += datetime.timedelta(seconds=300)
        print t
        if (count % 200) == 0:
            conn.commit()
    except:
        t += datetime.timedelta(seconds=300)
        pass

conn.commit()
conn.close()
