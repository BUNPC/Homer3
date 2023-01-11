function [tsv, tabReplacefFlag] = readTsv(filename, option)
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
ncols = 0;
tabReplacefFlag = false;
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
    
    delimiter = findDelimiter(strtrim(line), ncols);
    
    % If delimiter contains non-tab spaces then raise flag that 
    % they need to be replaces by tabs in a tav file
    if ~isempty(find(strcmp(delimiter,' ')))
        fprintf('WARNING: file %s uses space separators instead of tabs. This could confuse some applitions\n', filename);
        tabReplacefFlag = true;
    end
    
    c = str2cell(strtrim(line), delimiter);
    if ncols == 0
        ncols = length(c);
    end
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


% If delimiter contains non-tab spaces then raise flag that
% they need to be replaces by tabs in a tav file
if tabReplacefFlag
    fprintf('Rewriting file %s to replace space separators with tabs\n', filename);
    writeTsv(filename, tsv);
end




% -------------------------------------------------------------------------
function delimiter = findDelimiter(line, ncols)
delimiter = ' ';
ntabSections = length(str2cell(line, sprintf('\t')));  % number of sections separated by spaces
ntabs = ntabSections-1;   % number of tabs
nspaceSections = length(str2cell(line, sprintf(' ')));  % number of sections separated by spaces
nspaces = nspaceSections-1;   % number of spaces
if ncols==0
    if ntabs>0 && nspaces==0
        delimiter = sprintf('\t');
    elseif ntabs==0 && nspaces>0
        delimiter = sprintf(' ');
    elseif ntabs>0 && nspaces>0
        delimiter = sprintf('\t');
    end
else
    if ntabs>0 && nspaces==0 && ntabs+1==ncols
        delimiter = sprintf('\t');
    elseif ntabs==0 && nspaces>0 && nspaces+1==ncols
        delimiter = sprintf(' ');
    elseif ntabs>0 && nspaces>0
        if ntabs+1 == ncols
            delimiter = sprintf(' ');
        elseif nspaces+1 == ncols
            delimiter = sprintf('\t');
        else
            delimiter = {sprintf('\t'), ' '};
        end
    end
end


