function runProcessingStream(rootdir, rooturl, branch)
if ~exist('rootdir','var')
    rootdir = pwd;
end
if ~exist('rooturl','var')
    rooturl = 'https://github.com/jayd1860';
end
if ~exist('branch','var')
    branch = 'development';
end

submodules = {
    'DataTree';
    'FuncRegistry';
    'Utils';
    };

for ii = 1:length(submodules)
    if ~exist([rootdir, '/', submodules{ii}],'dir')
        cmd = sprintf('git clone -b %s %s/%s', branch, rooturl, submodules{ii});
        system(cmd);
    end
    if ii > 1
        movefile([rootdir, '/', submodules{ii}], [rootdir, '/', submodules{1}])
    end
end
cd([rootdir, '/', submodules{1}]);
setpaths


