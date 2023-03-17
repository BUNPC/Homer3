function [dateNum, dateStr] = getCurrTime()
ds = char(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm:ss'));
[dateNum, dateStr] = datestr2datenum(ds);

