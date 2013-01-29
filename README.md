horus
=====

Horus - A small web front end to Ecoeye energy monitors

Horus is a webserver and logger for the Eco eye sart electricity monitor device.
A big thank to Peter Longley of Ecoeye for providing me with a monitor.

First setup the db
sqlite3 horus.db < horus.schema

Run like sudo ./horus.py  -v start

Dependencies

pyserial
python-sqlite3
python-cherrypi (For raspberry pi I had to use easy_install as the debian python-cherrypi seems broken)
optional - easy_install setproctitle
