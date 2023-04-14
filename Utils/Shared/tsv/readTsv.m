function [tsv, err] = readTsv(filename, option)
global cfg
cfg = InitConfig(cfg);
err = 0;

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
nLines = 0;
ncols = 0;
tabReplacefFlag = [];
while 1
    line = fgetl(fid);
    if line==-1
        break;
    end
    if isempty(line)
        continue;
    end
    
    nLines = nLines+1;
    
    % Get rid of any non-ascii characters from read line
    if ischar(line)
        line(line>130) = '';
        line(line<9) = '';
    end
    
    delimiter = findDelimiter(strtrim(line), ncols);
    c = str2cell(strtrim(line), delimiter);
    if ncols == 0
        ncols = length(c);
    end
    
    % Check for errors
    if errorCheck([f,e], nLines, c, ncols, delimiter)<0
        err = -1;
        return;
    end
    
    % If delimiter contains non-tab spaces then raise flag that
    % they need to be replaces by tabs in a tav file
    if ~isempty(find(strcmp(delimiter,' ')))
        tabReplacefFlag = [tabReplacefFlag, nLines];
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
    tsv(nLines,:) = c;
end
fclose(fid);

% If delimiter contains non-tab spaces then raise flag that
% they need to be replaces by tabs in a tsv file
if ~isempty(tabReplacefFlag)
    fprintf('WARNING: File  "%s"  uses space separators instead of tabs at lines:  [ %s ]. This could confuse some applications\n', ...
        [f,e], num2str(tabReplacefFlag));
    val = '';
    if ~isempty(cfg)
        val = cfg.GetValue('Replace TSV File Tabs with Spaces');
    end
    if strcmpi(val, 'Yes')
        printMethod(sprintf('Rewriting file %s to replace space separators with tabs\n', filename));
        copyfile(filename, [filename, '.orig']);
        writeTsv(filename, tsv);
    end
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
    elseif ntabs>0 && nspaces>0 && nspaces+1==ncols
        delimiter = {sprintf('\t'), ' '};
    elseif ntabs>0
        delimiter = sprintf('\t');
    end
end




% -----------------------------------------------------------
function err = errorCheck(filename, nLines, c, ncols, delimiter)
err = 0;
errmsg = '';
if length(c) ~= ncols
    errmsg{1} = sprintf('ERROR: Found %d data columns in line %d of %s which does not match number of columns in file (%d)\n\n', ...
        length(c), nLines, filename, ncols);
    for ii = 1:length(c)
        errmsg{ii+1} = sprintf('col %d:    "', ii);
        c2 = str2cell(c{ii}, {delimiter, sprintf('\t')});
        for jj = 1:length(c2)
            errmsg{ii+1} = [errmsg{ii+1}, sprintf('%s    ', c2{jj})];
        end
        errmsg{ii+1} = [errmsg{ii+1}, sprintf('"\n')];
    end
end
if ~isempty(errmsg)
    errmsgLen = length([errmsg{:}]);
    if errmsgLen > 70 
        errmsgLen = 100;
    end
    MenuBox(errmsg,{},[],errmsgLen);
    err = -1;
end
printMethod(errmsg);



% -------------------------------------------------------------------------
function printMethod(msg)
global logger
if isempty(msg)
    return;
end
if isa(logger', 'Logger')
    try
        logger.Write(msg);
    catch
        fprintf(msg);
    end
else
    fprintf(msg);
end



