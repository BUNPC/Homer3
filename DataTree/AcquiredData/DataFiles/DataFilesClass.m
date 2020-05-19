classdef DataFilesClass < handle
    
    properties
        files;
        type;
        err;
        errmsg;
        pathnm;
        config;
        
    end
    
    methods
        
        % ----------------------------------------------------
        function obj = DataFilesClass(varargin)
            obj.type = '';
            obj.pathnm = pwd;
            skipconfigfile = false;
            
            if nargin>0
                obj.pathnm = varargin{1};
            end
            obj.pathnm = convertToStandardPath(obj.pathnm);

            if nargin>1
                obj.type = varargin{2};
                if obj.type(1)=='.'
                    obj.type(1)='';
                end
            end
            obj.errmsg = {};
            
            if nargin>2
                if strcmp(varargin{3}, 'standalone')
                    skipconfigfile = true;
                end
            end
            
            obj.config = struct('RegressionTestActive','');
            if skipconfigfile==false
                cfg = ConfigFileClass();
                str = cfg.GetValue('Regression Test Active');
                if strcmp(str,'true')
                    obj.config.RegressionTestActive=true;
                else
                    obj.config.RegressionTestActive=false;
                end
            else
                obj.config.RegressionTestActive=false;
            end
            
            if nargin==0
                return;
            end
            
            obj.files = mydir(obj.pathnm);
            GetDataSet(obj);
        end
        
        
        % -----------------------------------------------------------------------------------
        function GetDataSet(obj)
            if exist(obj.pathnm, 'dir')~=7
                error(sprintf('Invalid subject folder: ''%s''', obj.pathnm));
            end
            obj.findDataSet(obj.type);                        
        end

        
        % ----------------------------------------------------
        function findDataSet(obj, type)
            obj.files = mydir([obj.pathnm, '/*.', type]);
            if isempty( obj.files )
                
                % If there are no .nirs files in current dir, don't give up yet - check
                % the subdirs for .nirs files.
                dirs = mydir(obj.pathnm);
                for ii=1:length(dirs)
                    if dirs(ii).isdir && ...
                            ~strcmp(dirs(ii).name,'.') && ...
                            ~strcmp(dirs(ii).name,'..') && ...
                            ~strcmp(dirs(ii).name,'hide')
                        dirs(ii).idx = length(obj.files)+1;
                        foos = mydir([obj.pathnm, dirs(ii).name, '/*.', type]);
                        nfoos = length(foos);
                        if nfoos>0
                            for jj=1:nfoos
                                foos(jj).subjdir      = dirs(ii).name;
                                foos(jj).subjdiridx   = dirs(ii).idx;
                                foos(jj).idx          = dirs(ii).idx+jj;
                                foos(jj).filename     = foos(jj).name;
                                foos(jj).name         = [dirs(ii).name, '/', foos(jj).name];
                                foos(jj).map2group    = struct('iGroup',0, 'iSubj',0, 'iRun',0);
                                foos(jj).pathfull     = dirs(ii).pathfull;
                            end
                            
                            % Add .nirs file from current subdir to files struct
                            if isempty(obj.files)
                                obj.files = dirs(ii);
                            else
                                obj.files(end+1) = dirs(ii);
                            end
                            obj.files(end+1:end+nfoos) = foos;
                        end
                    end
                end
            else
                for ii=1:length(obj.files)
                    obj.files(ii).pathfull = obj.pathnm;
                end
            end
        end
        
        
        % ----------------------------------------------------
        function getDataFile(obj, filename)
            obj.files = mydir(filename);
        end
        
        
        
        % -------------------------------------------------------
        function pushbuttonLoadDataset_Callback(obj, hObject)
            hp = get(hObject,'parent');
            hc = get(hp,'children');
            for ii=1:length(hc)
                
                if strcmp(get(hc(ii),'tag'),'pushbuttonLoad')
                    hButtnLoad = hc(ii);
                elseif strcmp(get(hc(ii),'tag'),'pushbuttonSelectAnother')
                    hButtnSelectAnother = hc(ii);
                end
                
            end
            
            if hObject==hButtnLoad
                delete(hButtnSelectAnother);
            elseif hObject==hButtnSelectAnother
                delete(hButtnLoad);
            end
            delete(hp);
        end
            
        
        % ----------------------------------------------------------
        function b = isempty(obj)
            if isempty(obj.files)
                b = true;
            else
                b = false;
            end
        end
       
    end
end
