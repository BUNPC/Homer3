function [dateNum, dateStr] = datestr2datenum(dateStr)
dateNum = 0;

c = str2cell(dateStr, ' ');
if length(c)<2
    return
end
dateStr = c{1};
timeStr = c{2};

dateStr(dateStr=='-')='';
timeStr(timeStr==':')='';

timeNum = str2num(timeStr);
dateNum = str2num(dateStr) + timeNum/1e6;

dateStr = [c{1}, ' ', c{2}];