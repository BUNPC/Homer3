function [paths, wspaths, paths_excl_str] = getpaths(mode)

DEBUG = 0;

if ~exist('mode','var') || isempty(mode)
    mode = 'errcheck';
end


paths = {...
    '/'; ...
    '/GuiMain'; ...
    '/GuiMain/AxesData'; ...
    '/GuiMain/AxesSDG'; ...
    '/CurrElem'; ...
    '/Group'; ...
    '/Group/ProcStream'; ...
    '/Group/ProcStream/Funcs'; ...
    '/DataFiles'; ...
    '/PlotProbe'; ...
    '/ProcStream'; ...
    '/ProcStream/Funcs'; ...
    '/Run'; ...
    '/Run/ProcStream'; ...
    '/Run/ProcStream/Funcs'; ...
    '/Snirf'; ...
    '/Snirf/Hdf5'; ...
    '/Snirf/Examples'; ...
    '/Subj'; ...
    '/Subj/ProcStream'; ...
    '/Subj/ProcStream/Funcs'; ...
    '/Utils'; ...
    '/stimGUI'; ...
    };


wspaths = {};
paths_excl_str = {};

if isempty(strfind(mode, 'noerrcheck'))  && ~isempty(strfind(mode, 'errcheck'))
        
    % Get all workspace paths that have similar functions sets with current applications
    appmainfunc = {'Homer3.m','Homer2_UI.m','brainScape.m'};
    
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
            rmpath(paths_excl_str{kk});
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

