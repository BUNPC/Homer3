function [datetimeNum, datetimeStr] = datestr2datenum(datetimeStr)
datetimeNum = 0;

START_YEAR     = 2000;
MONTHS         = {'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'};
NUMDAYSINMONTH = [  31    29    31    30    31    30    31    31    30    31    30    31 ];

base_yr  = 32140800;   % 12*31*24*60*60
base_mo  = 2678400;    % 31*24*60*60;
base_day = 86400;      % 24*60*60;
base_hr  = 3600;       % 60*60;
base_min = 60;

date_object = datetime(datetimeStr, 'TimeZone','local','Format','MMM-dd-yyyy HH:mm:ss');

year    = date_object.Year - START_YEAR;
month   = date_object.Month;
day     = date_object.Day;
hour    = date_object.Hour;
min     = date_object.Minute;
sec     = date_object.Second;

% Now that we have a numeric date, check it for errors
if year<0
    return;
end
if isempty(month) || month<1 || month>12
    return;
end
if day<1 || day>NUMDAYSINMONTH(month)
    return;
end
if hour<0 || hour>23
    return;
end
if min<0 || min>59
    return;
end
if sec<0 || sec>59
    return;
end

datetimeNum = uint32(year*base_yr + month*base_mo + day*base_day + hour*base_hr + min*base_min + sec);

