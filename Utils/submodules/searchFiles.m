function paths = searchFiles(submodules, options)
%
% Syntax:
%    paths = searchFiles(submodules, options)
%
% Usage:
%    paths = searchFiles()
%    paths = searchFiles(submodules)
%    paths = searchFiles(submodules, options)
%
% Examples:
%    paths = searchFiles()
%    paths = searchFiles({}, 'update')
%    
%
global paths  %#ok<REDEFGI>

if ~exist('submodules','var') || isempty(submodules)
    submodules = parseGitSubmodulesFile();
end
if ~exist('options','var')
    options = '';
end
paths = {};

submodulenames = {};
submodulepaths = {};
urls = {};
kk = 1;
for ii = 1:size(submodules,1)
    urls{ii}            = submodules{ii,1};
    submodulepaths{ii}  = submodules{ii,3};
    if optionExists_startup(options,'update')
        removeFolderContents(submodulepaths{ii});
    elseif ~isemptyFolder(submodulepaths{ii})
        continue;
    end
    [~, submodulenames{kk}] = fileparts(urls{ii});
    kk = kk+1;
end
if isempty(submodulenames)
    return;
end


hf = figure('numbertitle', 'off', 'menubar','none', 'toolbar','none', 'name','Files Paths');
p = get(hf, 'position');
set(hf, 'position',[p(1), p(2), 1.5*p(3), p(4)]);

xpos  = .01;
ypos  =  .70;
xsize =  .20;
ysize =  .07;
xgapsize = .02;
ygapsize = .03;


xpos0 = 12*xpos;
ypos0 = ypos+.1*ypos;
xsize0 = 3.5*xsize;
ysize0 = 2*ysize;
fprintf('Display instructions at [%1.f, %1.f, %1.f, %1.f]\n', [xpos0, ypos0, xsize0, ysize0]);
uicontrol('parent',hf, 'style','text', 'string','Provide paths of downloaded submodules', 'units','normalized', 'position',[xpos0, ypos0, xsize0, ysize0], ...
    'fontsize',11, 'fontweight','bold', 'horizontalalignment','center');

for ii = 1:length(submodulenames)
    fprintf('%d. File %s\n', ii, submodulenames{ii});
    
    yposi = ypos - (ii-1)*(ysize+ygapsize);
    if yposi<0
        break;
    end
    
    xpos1 = .7*xpos;
    xsize1 = xsize;
    ysize1 = ysize;
    k = .98;
    fprintf('Display label at [%1.f, %1.f, %1.f, %1.f]\n', [xpos1, k*yposi, xsize1, ysize1]);
    htxt(ii)  = uicontrol('parent',hf, 'style','text',       'string',[submodulenames{ii}, ' :'], 'units','normalized', 'position',[xpos1, k*yposi, xsize1, ysize1], ...
        'fontsize',10, 'fontweight','bold', 'horizontalalignment','right');
    
    xpos2 = xpos1+xsize1+xgapsize/2;
    xsize2 = 2.5*xsize;
    ysize2 = ysize;
    fprintf('Display edit box at [%1.f, %1.f, %1.f, %1.f]\n', [xpos2, yposi, xsize2, ysize2]);
    hedit(ii) = uicontrol('parent',hf, 'style','edit',       'string','',        'units','normalized', 'position',[xpos2, yposi, xsize2, ysize2], ...
        'fontsize',9, 'fontweight','normal', 'horizontalalignment','left', 'tag',sprintf('edit%sPath',submodulenames{ii}));
    
    xpos3 = xpos2+xsize2+xgapsize;
    xsize3 = .8*xsize;
    ysize3 = ysize;
    fprintf('Display browse pushbutton at [%1.f, %1.f, %1.f, %1.f]\n', [xpos3, yposi, xsize3, ysize3]);
    hbttn(ii) = uicontrol('parent',hf, 'style','pushbutton', 'string','Browse',  'units','normalized', 'position',[xpos3, yposi, xsize3, ysize3], ...
        'fontsize',10, 'fontweight','bold','callback',{@browseBttnCallback, hedit(ii), submodulenames{ii}});
    
    fprintf('\n');
end


yposi = ypos - 2*ii*(ysize+ygapsize);
if yposi<0
    return;
end
xpos4  = .35;
xsize4 = 1.2*xsize;
ysize4 = 1.5*ysize;
fprintf('Display SUBMIT button [%1.f, %1.f, %1.f, %1.f]\n', [xpos4, yposi, xsize4, ysize4]);
uicontrol('parent',hf, 'style','pushbutton', 'string','SUBMIT', 'units','normalized', 'position',[xpos4, yposi, xsize4, ysize4], ...
    'fontsize',11, 'fontweight','bold', 'callback',{@submitBttnCallback, hedit, submodules});

waitForGui_startup(hf);



% ------------------------------------------------------
function pname = browseBttnCallback(~, ~, hEdit, submodulename)
pname = '';
[filename, pathname] = uigetfile('*.zip', sprintf('Select file for submodule "%s"', submodulename));
if filename==0
    return
end
pause(.01)

pname = filesepStandard_startup([pathname, '/', filename]);
if isempty(strfind(pname, submodulename)) %#ok<*STREMP>
    msgbox(sprintf('Selected file  "%s"  does not match the submodule  "%s". Please download and provide the path name for submodule  "%s"...', ...
        filename, submodulename, submodulename))
    return;
end
set(hEdit, 'string',pname)




% ------------------------------------------------------
function submitBttnCallback(hObject, ~, hEdits, submodules)
global paths 

hf = get(hObject,'parent');

for ii = 1:length(hEdits)
    filepath = get(hEdits(ii), 'string');
    if ~ispathvalid_startup(filepath)
        continue;
    end
    [p,f,e] = fileparts(filepath);
    filenameUnziped = filesepStandard_startup([p,'/',f], 'nameonly:dir');
    
    if strcmp(e,'.zip')
        if ~ispathvalid_startup(filepath,'file')
            continue
        end
        try
            if ispathvalid_startup(filenameUnziped,'dir')
                rmdir(filenameUnziped,'s')
            end
            unzip(filepath, fileparts(filenameUnziped(1:end-1)));
        catch
        end
    end
    
    if ~ispathvalid_startup(filenameUnziped,'dir')
        continue
    end
    
    % Copy downloaded and unzipped submodule folder contents to
    % corresponding submodule folder in the parent repo
    for jj = 1:size(submodules,1)
        submodulepath = submodules{jj,3};
        [~, submodulename] = fileparts(submodules{jj,1});
        if isempty(strfind(filenameUnziped, submodulename))
            continue
        end
        fprintf('Copying %s to %s\n', [filenameUnziped, '/*'], submodulepath);
        copyFolderContents(filenameUnziped, submodulepath);
        rmdir(filenameUnziped,'s');
        paths{ii,1} = filenameUnziped;
        break;
    end    
end

delete(hf)

