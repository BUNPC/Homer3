function myCopyFile(src, dst)
global logger %#ok<NUSED>
global h
global iStep
global nSteps

if nargin==0
    src = '';
    dst = '';
end
if nargin==1
    dst = '';
end
if ~ispathvalid(src)
    if ~ispathvalid([src, '.gz'])
        if ~ispathvalid([src, 'tar.gz'])
            if ~ispathvalid([src, '.zip'])
                if ~ispathvalid([src, '.tar'])
                    return
                end
            end
        end
    end
end

printFuncName = getStandardOutputFuncName();

[~,f,e] = fileparts(src);
if (isempty(f) || strcmp(f, '.')) && strcmp(e, '.')
    return;
end

src = filesepStandard(src, 'full');
dst = filesepStandard(dst, 'full:nameonly');


files = dir(src);

for ii = 1:length(files)
    if strcmp(files(ii).name, '.') || strcmp(files(ii).name, '..')
        continue;
    end
    
    % Set full path names of source and destination
    srcNew = unpack([filesepStandard(files(ii).folder), files(ii).name]);
    [~, f, e] = fileparts(srcNew);
    if ~strcmp(files(ii).name, [f,e])
        eval( sprintf('%s(''Skipping %%s\\n'', [filesepStandard(files(ii).folder), files(ii).name]);', printFuncName) );        
        files(ii).name = [f,e];
    end
    
    % Rules for copying
    if ispathvalid(srcNew,'dir')
        dstNew = [dst, '/', files(ii).name];
        if ~ispathvalid(dstNew)
            try
            mkdir(dstNew)
            catch
                d=1;
            end
        end
        myCopyFile(srcNew, dstNew);
    elseif ispathvalid(srcNew,'file')
        if ispathvalid(dst, 'dir')
            dstNew = [dst, '/', files(ii).name];
        elseif ispathvalid(src, 'dir')
            dstNew = [dst, '/', files(ii).name];
            mkdir(dst)
        else
            dstNew = dst;
            dstRoot = fileparts(dst);
            if ~ispathvalid(dstRoot)
                mkdir(dstRoot)
            end
        end
        try
            if ispathvalid(dstNew)
                return
            end
            eval( sprintf('%s(''Copying  %%s   to   %%s\\n'', srcNew, dstNew);', printFuncName) );
            copyfile(srcNew, dstNew);
            if ~isempty(iStep)
                if ishandles(h)
                    waitbar(iStep/nSteps, h);
                end
                iStep = iStep+1;
            end            
        catch ME
            printStack(ME);
        end
    else
        eval( sprintf('%s(''WARNING: Path %%s does not exist\\n'', srcNew);', printFuncName) );
    end
end
pause(.7)



% ----------------------------------------------------------------------
function [src, ext] = unpack(src)
[pname1, fname1, ext1] = fileparts(src);
[~, ~, ext2] = fileparts(fname1);
ext = [ext2, ext1];
temp = [pname1, '/temp/'];
if ispathvalid(temp)
    rmdir(temp,'s');
end
switch(ext)
    case '.tar'
        mkdir(temp);
        untar(src, temp);
    case '.tar.gz'
        mkdir(temp);
        untar(src, temp);
    case '.gz'
        mkdir(temp);
        gunzip(src, temp);
    case '.zip'
        mkdir(temp);
        unzip(src, temp);
    otherwise
        return
end

f = dir([temp, '/*']);
for ii = 1:length(f)
    if strcmp(f(ii).name,'.')
        continue;
    end
    if strcmp(f(ii).name,'..')
        continue;
    end
    if ~ispathvalid([pname1, '/', f(ii).name])
        copyfile([temp, '/', f(ii).name], pname1)
        break;
    end
end
if ispathvalid(temp)
    rmdir(temp,'s');
end    
src = [pname1, '/', f(ii).name];


