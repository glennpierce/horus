--CREATE TABLE settings(setting_name TEXT PRIMARY KEY, setting_value REAL);

--DROP VIEW power_minutes;
--DROP VIEW kwh_minutes;

--CREATE VIEW power_minutes AS SELECT timestamp,(amps*240.0) AS power FROM current_minutes;

--CREATE VIEW kwh AS SELECT timestamp,(sum(power)/60000.0) AS kwh 
--                   FROM power_minutes group by (strftime('%Y-%m-%d %H:00', datetime(timestamp, 'unixepoch')));

--CREATE VIEW cost AS SELECT timestamp, (kwh*14.0) AS cost FROM kwh;

--CREATE VIEW power_hours AS SELECT timestamp,(amps*240.0) AS power FROM current_hours;
--CREATE VIEW kwh_hours AS SELECT timestamp,(power/900.0) AS kwh
--                         FROM power_hours;
--CREATE VIEW cost_hours AS SELECT timestamp, (kwh*14.0) AS cost FROM kwh_hours;

--select (strftime('%Y-%m-%d %H:00', datetime(timestamp, 'unixepoch'))), sum(amps) as power from current group by (strftime('%Y-%m-%d %H:00', datetime(timestamp, 'unixepoch')));
