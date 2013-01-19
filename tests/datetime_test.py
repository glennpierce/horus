#!/usr/bin/python

import datetime

from pytz import timezone
import pytz

utc = pytz.utc
uk = timezone('Europe/London')
tz = timezone('America/St_Johns')

dt = datetime.datetime(year=2012, month=6, day=1, hour=14, minute=1, second=1, tzinfo=utc)

print dt.astimezone(uk).astimezone(utc)

dt = datetime.datetime(year=2012, month=12, day=1, hour=14, minute=1, second=1, tzinfo=utc)

print dt.astimezone(uk)

#local = pytz.timezone ("America/Los_Angeles")
#naive = datetime.datetime(year=2012, month=6, day=1, hour=14, minute=1, second=1)
#local_dt = local.localize(naive, is_dst=None)
#utc_dt = local_dt.astimezone (pytz.utc)
#print utc_dt
