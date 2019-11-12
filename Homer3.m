function Homer3(groupDirs, fmt)
if nargin==0
    groupDirs = convertToStandardPath(pwd);
end
if nargin<2
    fmt='snirf';
elseif nargin==1 && isempty(fmt)
    fmt='snirf';
end
cfg = ConfigFileClass();
fprintf('Opened application config file %s\n', cfg.filename)
gdir = cfg.GetValue('Last Group Folder');
if isempty(gdir)
    if isdeployed()
        groupDirs = {[getAppDir(), 'SubjDataSample']};
    end
end
MainGUI(groupDirs, fmt, 'userargs');

