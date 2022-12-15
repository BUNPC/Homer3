function tsv = readTsv(filename, option)
tsv = struct([]);
if ~exist('filename', 'var')
    filename = '';
end
if ~exist('option', 'var')
    option = '';
end

[p,f,e] = fileparts(filename);
if isempty(e)
    e = '.tsv';
end
filename = [filesepStandard(p), f, e];
if ~ispathvalid(filename, 'file')
    return;
end
numstr2num = false;
if strcmp(option, 'numstr2num')
    numstr2num = true;
end
fid = fopen(filename, 'rt');
kk = 1;
while 1
    line = fgetl(fid);
    if line==-1
        break;
    end
    if isempty(line)
        continue;
    end
    
    % Get rid of any non-ascii characters from read line
    if ischar(line)
        line(line>130) = '';
        line(line<9) = '';
    end
    
    c = str2cell(line, {sprintf('\t')});
    if isempty(tsv)
        tsv = cell(1,length(c));
    end
    if numstr2num
        for iCol = 1:length(c)
            if isnumber(c{iCol})
                c{iCol} = str2double(c{iCol});
            end
        end
    end
    tsv(kk,:) = c;
    kk = kk+1;
end
fclose(fid);


