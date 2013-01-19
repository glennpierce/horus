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

dbfile = 'ecoiris.db'

conn = sqlite3.connect(dbfile)
cur = conn.cursor()

from pytz import timezone
import pytz

utc = pytz.utc
uk = timezone('Europe/London')
tz = timezone('America/St_Johns')

dt = datetime.datetime(year=2012, month=6, day=1, hour=14, minute=1, second=1, tzinfo=utc)

print dt.astimezone(uk).astimezone(utc)

dt = datetime.datetime(year=2012, month=12, day=1, hour=14, minute=1, second=1, tzinfo=utc)

print dt.astimezone(uk)

now = datetime.datetime.now().replace(tzinfo=utc)

t = start_time = datetime.datetime(year=2011, month=6, day=1, tzinfo=utc)

while t < now:
    timestamp = time.mktime(t.timetuple())
    day = time.mktime(t.date().timetuple()) 
    #timestamp = t.strftime("%Y-%m-%d %H:%M:%S")
    #day_str = t.strftime("%Y-%m-%d")
    #time_str = t.strftime("%H:%M:%S")
    value = random.random() * 20.0
    cur.execute("INSERT INTO current(day, timestamp, amps) VALUES (?,?,?)", (day,timestamp, value))
    t += datetime.timedelta(seconds=4)

conn.commit()
conn.close()
