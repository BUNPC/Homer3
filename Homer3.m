function Homer3(fmt)
if nargin==0
    fmt='snirf';
elseif nargin==1 && isempty(fmt)
    fmt='snirf';
end
cfg = ConfigFileClass();
fprintf('Opened application config file %s\n', cfg.filename)
subjDir = cfg.GetValue('Last Subject Folder');
if isempty(subjDir)
    if isdeployed()
        subjDir = [getAppDir(), 'SubjDataSample'];
    else
        subjDir = pwd;
    end
end
cd(subjDir);
fprintf('Current working directory: %s\n', pwd)

MainGUI(fmt);