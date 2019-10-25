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
            if nargin==1
                if ischar(varargin{1}) && strcmp(varargin{1}, 'standalone')
                    skipconfigfile = true;
                else
                    obj.type = varargin{1};
                    if obj.type(1)=='.'
                        obj.type(1)='';
                    end
                end
            end
            obj.errmsg = {};
            
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
            foo = mydir(obj.pathnm);
            if ~isempty(foo) && ~foo(1).isdir
                obj.files = foo;
            end
            if nargin==0
                return;
            end
            GetDataSet(obj);
        end
        
        
        % -----------------------------------------------------------------------------------
        function GetDataSet(obj)
            if exist(obj.pathnm, 'dir')~=7
                error(sprintf('Invalid subject folder: ''%s''', obj.pathnm));
            end
            cd(obj.pathnm);
            obj.findDataSet(obj.type);                        
        end

        
        % ----------------------------------------------------
        function findDataSet(obj, type)
            obj.files = mydir(['./*.', type]);
            if isempty( obj.files )
                
                % If there are no .nirs files in current dir, don't give up yet - check
                % the subdirs for .nirs files.
                dirs = mydir();
                for ii=1:length(dirs)
                    if dirs(ii).isdir && ...
                            ~strcmp(dirs(ii).name,'.') && ...
                            ~strcmp(dirs(ii).name,'..') && ...
                            ~strcmp(dirs(ii).name,'hide')
                        dirs(ii).idx = length(obj.files)+1;
                        cd(dirs(ii).name);
                        foos = mydir(['./*.', type]);
                        nfoos = length(foos);
                        if nfoos>0
                            for jj=1:nfoos
                                foos(jj).subjdir      = dirs(ii).name;
                                foos(jj).subjdiridx   = dirs(ii).idx;
                                foos(jj).idx          = dirs(ii).idx+jj;
                                foos(jj).filename     = foos(jj).name;
                                foos(jj).name         = [dirs(ii).name, '/', foos(jj).name];
                                foos(jj).map2group    = struct('iGroup',0, 'iSubj',0, 'iRun',0);
                            end
                            
                            % Add .nirs file from current subdir to files struct
                            if isempty(obj.files)
                                obj.files = dirs(ii);
                            else
                                obj.files(end+1) = dirs(ii);
                            end
                            obj.files(end+1:end+nfoos) = foos;
                        end
                        cd('../');
                    end
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
