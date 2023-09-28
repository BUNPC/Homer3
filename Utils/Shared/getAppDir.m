function [out1] = getAppDir(inp1)
out1 = [];
ns = getNamespace();
if isempty(ns)
    return;
end
if strcmp(ns, 'AtlasViewerGUI')
    if nargin == 0
        [out1] = getAppDir_AtlasViewerGUI();
    elseif nargin == 1
        [out1] = getAppDir_AtlasViewerGUI(inp1);
    end
elseif strcmp(ns, 'Homer3')
    if nargin == 0
        [out1] = getAppDir_Homer3();
    elseif nargin == 1
        [out1] = getAppDir_Homer3(inp1);
    end
elseif strcmp(ns, 'DataTreeClass')
    if nargin == 0
        [out1] = getAppDir_DataTreeClass();
    elseif nargin == 1
        [out1] = getAppDir_DataTreeClass(inp1);
    end
end


% ---------------------------------------------------------
function [dirname] = getAppDir_AtlasViewerGUI(isdeployed_override)

if ~exist('isdeployed_override','var')
    isdeployed_override = 'notdeployed';
end

if isdeployed() || strcmp(isdeployed_override, 'isdeployed')
    if ispc()
        dirname = 'c:/users/public/atlasviewer/';
    else
        currdir = pwd;
        cd ~/;
        dirnameHome = pwd;
        dirname = [dirnameHome, '/atlasviewer/'];
        cd(currdir);
    end
else
    dirname = fileparts(which('AtlasViewerGUI.m'));
end

dirname(dirname=='\') = '/';
if dirname(end) ~= '/'
    dirname(end+1) = '/';
end





% ---------------------------------------------------------
function [dirname] = getAppDir_Homer3(isdeployed_override)

if ~exist('isdeployed_override','var')
    isdeployed_override = 'notdeployed';
end

if isdeployed() || strcmp(isdeployed_override, 'isdeployed')
    if ispc()
        dirname = 'c:/users/public/homer3/';
    else
        currdir = pwd;
        cd ~/;
        dirnameHome = pwd;
        dirname = [dirnameHome, '/homer3/'];
        cd(currdir);
    end
else
    dirname = fileparts(which('Homer3.m'));
end

dirname(dirname=='\') = '/';
if dirname(end) ~= '/'
    dirname(end+1) = '/';
end



% ---------------------------------------------------------
function [dirname] = getAppDir_DataTreeClass(isdeployed_override)

if ~exist('isdeployed_override','var')
    isdeployed_override = 'notdeployed';
end

if isdeployed() || strcmp(isdeployed_override, 'isdeployed')
    if ispc()
        dirname = 'c:/users/public/datatree/';
    else
        currdir = pwd;
        cd ~/;
        dirnameHome = pwd;
        dirname = [dirnameHome, '/datatree/'];
        cd(currdir);
    end
else
    dirname = fileparts(which('DataTreeClass.m'));
end

dirname(dirname=='\') = '/';
if dirname(end) ~= '/'
    dirname(end+1) = '/';
end



