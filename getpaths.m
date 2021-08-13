function [out1, out2, out3] = getpaths(inp1)
out1 = [];
out2 = [];
out3 = [];
ns = getNamespace();
if isempty(ns)
    return;
end
if strcmp(ns, 'AtlasViewerGUI')
    if nargin == 0
        [out1, out2, out3] = getpaths_AtlasViewerGUI();
    elseif nargin == 1
        [out1, out2, out3] = getpaths_AtlasViewerGUI(inp1);
    end
elseif strcmp(ns, 'Homer3')
    if nargin == 0
        [out1, out2, out3] = getpaths_Homer3();
    elseif nargin == 1
        [out1, out2, out3] = getpaths_Homer3(inp1);
    end
end


% ---------------------------------------------------------
function [paths, wspaths, paths_excl_str] = getpaths_AtlasViewerGUI(options)

DEBUG = 0;

paths = {...
    '/'; ...
    '/Install'; ...
    '/Axesv'; ...
    '/Data'; ...
    '/Data/Colin'; ...
    '/Digpts'; ...
    '/Digpts/Headsize'; ...
    '/ForwardModel'; ...
    '/ForwardModel/tMCimg'; ...
    '/ForwardModel/tMCimg/bin/Darwin'; ...
    '/ForwardModel/tMCimg/bin/Linux'; ...
    '/ForwardModel/tMCimg/bin/Win'; ...
    '/Group'; ...
    '/Group/DataTree/'; ...
    '/Group/DataTree/AcquiredData'; ...
    '/Group/DataTree/AcquiredData/DataFiles'; ...
    '/Group/DataTree/AcquiredData/DataFiles/Hdf5'; ...
    '/Group/DataTree/AcquiredData/Snirf'; ...
    '/Group/DataTree/ProcStream'; ...
    '/Group/FuncRegistry'; ...
    '/Guiobj'; ...
    '/HbConc'; ...
    '/Headsurf'; ...
    '/Headvol'; ...
    '/ImgRecon'; ...
    '/Labelssurf'; ...
    '/Pialsurf'; ...
    '/Pialvol'; ...
    '/Probe'; ...
    '/Probe/NIRS_Probe_Designer_V1'; ...
    '/Probe/NIRS_Probe_Designer_V1/functions'; ...
    '/Probe/registerDigpts'; ...
    '/Probe/registerSprings'; ...
    '/Probe/SDgui'; ...
    '/Probe/SDgui/lambda'; ...
    '/Probe/SDgui/optode_tbls'; ...
    '/Probe/SDgui/optode_tbls2'; ...
    '/Probe/SDgui/probe_geometry_axes'; ...
    '/Probe/SDgui/probe_geometry_axes2'; ...
    '/Probe/SDgui/sample_data'; ...
    '/Probe/SDgui/sd_data'; ...
    '/Probe/SDgui/sd_file'; ...
    '/Probe/SDgui/utils'; ...
    '/Refpts'; ...
    '/Utils'; ...
    '/Utils/fs2viewer'; ...
    '/Utils/fontresizedlg'; ...
    '/Utils/probe'; ...
    '/Utils/namespace'; ...
    '/freesurfer'; ...
    '/iso2mesh'; ...
    '/iso2mesh/bin'; ...
    '/metch'; ...
    };


wspaths = {};
paths_excl_str = {};

if options.conflcheck
        
    % Get all workspace paths that have similar functions sets with current applications
    % appmainfunc = {'AtlasViewerGUI.m','Homer2_UI.m','Homer3.m','brainScape.m','AcqDataClass.m'};
    % Remove Homer3 from list of conflicting workspaces needed to be removed
    % in preparation for coexistance in one matlab session
    appmainfunc = {'AtlasViewerGUI.m','Homer2_UI.m','brainScape.m','ResolveCommonFunctions.m'};
    
    kk=1;
    wsidx = [];
    for ii=1:length(appmainfunc)
        
        while 1
            
            [paths_excl, foo] = getactivewspace(appmainfunc{ii});
            if isempty(paths_excl)
                break;
            end
            
            wspaths{kk,1} = foo;
            if pathscompare(wspaths{kk}, pwd)
                wsidx = kk;
            end
            
            paths_excl_str{kk} = '';
            for jj=1:length(paths_excl)
                if DEBUG
                    fprintf('Removing path %s\n', paths_excl{jj});
                end
                if isempty(paths_excl_str{kk})
                    paths_excl_str{kk} = paths_excl{jj};
                else
                    paths_excl_str{kk} = [paths_excl_str{kk}, delimiter, paths_excl{jj}];
                end
            end
            removePaths_AtlasViewerGUI(paths_excl_str{kk}, wspaths{1,1});
            kk=kk+1;
            
        end
        
    end

    
    % Change the order of precedence of all the conflicting workspaces to
    % the current one as primary workspace
    if ~isempty(wsidx)
        strtmp = wspaths{1};
        celltmp = paths_excl_str{1};
        
        wspaths{1} = wspaths{wsidx};
        paths_excl_str{1} = paths_excl_str{wsidx};
        
        wspaths{wsidx} = strtmp;
        paths_excl_str{wsidx} = celltmp;        
    end
    
end




% ---------------------------------------------------------------
function removePaths_AtlasViewerGUI(paths, wspace)

rmpath(paths);
if exist([pwd, '/Utils'], 'dir')==7
    addpath([pwd, '/Utils'], '-end');
end




% ---------------------------------------------------------
function [paths, wspaths, paths_excl_str] = getpaths_Homer3(options)

DEBUG = 0;

paths = {...
    '/'; ...
    '/DataTree'; ...
    '/DataTree/AcquiredData'; ...
    '/DataTree/AcquiredData/Nirs'; ...
    '/DataTree/AcquiredData/Snirf'; ...
    '/DataTree/AcquiredData/Snirf/Examples'; ...
    '/DataTree/AcquiredData/DataFiles'; ...
    '/DataTree/AcquiredData/DataFiles/Hdf5'; ...
    '/DataTree/ProcStream'; ...
    '/FuncRegistry'; ...
    '/FuncRegistry/UserFunctions'; ...
    '/FuncRegistry/UserFunctions/Archive'; ...
    '/FuncRegistry/UserFunctions/tcca_glm'; ...
    '/MainGUI'; ...
    '/Install'; ...
    '/PlotProbeGUI'; ...
    '/ProcStreamEditGUI'; ...
    '/PvaluesDisplayGUI'; ...
    '/StimEditGUI'; ...
    '/UnitTests'; ...
    '/UnitTests/Example9_SessRuns'; ...
    '/Utils'; ...
    '/Utils/iWLS'; ...
    '/Utils/namespace'; ...
    };


wspaths = {};
paths_excl_str = {};

if options.conflcheck
        
    % Get all workspace paths that have similar functions sets with current applications
    % appmainfunc = {'Homer2_UI.m','Homer3.m','AtlasViewerGUI.m','brainScape.m'};
    % Remove AtlasViewer from list of conflicting workspaces needed to be removed
    % in preparation for coexistance in one matlab session
    appmainfunc = {'Homer2_UI.m','Homer3.m','brainScape.m','ResolveCommonFunctions.m'};
        
    kk=1;
    wsidx = [];
    for ii=1:length(appmainfunc)
        
        while 1
            
            [paths_excl, foo] = getactivewspace(appmainfunc{ii});
            if isempty(paths_excl)
                break;
            end
            
            wspaths{kk,1} = foo;
            if pathscompare(wspaths{kk}, pwd)
                wsidx = kk;
            end
            
            paths_excl_str{kk} = '';
            for jj=1:length(paths_excl)
                if DEBUG
                    fprintf('Removing path %s\n', paths_excl{jj});
                end
                if isempty(paths_excl_str{kk})
                    paths_excl_str{kk} = paths_excl{jj};
                else
                    paths_excl_str{kk} = [paths_excl_str{kk}, delimiter, paths_excl{jj}];
                end
            end
            removePaths_Homer3(paths_excl_str{kk}, wspaths{1,1});
            kk=kk+1;
            
        end
        
    end

    
    % Change the order of precedence of all the conflicting workspaces to
    % the current one as primary workspace
    if ~isempty(wsidx)
        strtmp = wspaths{1};
        celltmp = paths_excl_str{1};
        
        wspaths{1} = wspaths{wsidx};
        paths_excl_str{1} = paths_excl_str{wsidx};
        
        wspaths{wsidx} = strtmp;
        paths_excl_str{wsidx} = celltmp;        
    end
    
end




% ---------------------------------------------------------------
function removePaths_Homer3(paths, wspace)

rmpath(paths);
if exist([pwd, '/Utils'], 'dir')==7
    addpath([pwd, '/Utils'], '-end');
end


