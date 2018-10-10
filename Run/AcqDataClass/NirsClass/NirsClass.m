classdef NirsClass < AcqDataClass
    
    properties
        filename;
        SD;
        t;
        s;
        d;
        aux;
        CondNames;
    end
    
    methods
        
        % ---------------------------------------------------------
        function obj = NirsClass(filename)
            obj.filename  = '';
            obj.SD        = struct([]);
            obj.t         = [];
            obj.s         = [];
            obj.d         = [];
            obj.aux       = [];
            obj.CondNames = {};
            
            if ~exist('filename','var')
                return;
            end
            if ~exist(filename,'file')
                return;
            end
            obj.filename  = filename;
            
            obj.Load();
            
        end
        
        
        
        % ---------------------------------------------------------
        function Load(obj)
            
            if isempty(obj.filename) || ~exist(obj.filename, 'file')
                return;
            end
            
            warning('off', 'MATLAB:load:variableNotFound');
            
            fdata = load(obj.filename,'-mat', 'SD','t','d','s','aux');
            
            if isproperty(fdata,'d')
                obj.d = fdata.d;
            end
            
            if isproperty(fdata,'t')
                obj.t = fdata.t;
            end
            
            if isproperty(fdata,'SD')
                obj.SetSD(fdata.SD);
            end
            
            if isproperty(fdata,'s')
                obj.s = fdata.s;
            end
            
            if isproperty(fdata,'aux')
                obj.aux = fdata.aux;
            end
            
            if isproperty(fdata,'CondNames')
                obj.CondNames = fdata.CondNames;
            else
                obj.InitCondNames();
            end
            
            warning('on', 'MATLAB:load:variableNotFound');
            
        end
        
        
        
        % ---------------------------------------------------------
        function Save(obj)
            
            SD        = obj.SD;
            s         = obj.s;
            CondNames = obj.CondNames;
            
            save(obj.filename,'-mat', 'SD','s','CondNames');
            
        end
        

        
        % ---------------------------------------------------------
        function nTrials = InitCondNames(obj)
            
            if isempty(obj.CondNames)
                obj.CondNames = repmat({''},1,size(obj.s,2));
            end
            
            for ii=1:size(obj.s,2)
                
                if isempty(obj.CondNames{ii})
                    
                    % Make sure not to duplicate a condition name
                    jj=0;
                    kk=ii+jj;
                    condName = num2str(kk);
                    while ~isempty(find(strcmp(condName, obj.CondNames)))
                        jj=jj+1;
                        kk=ii+jj;
                        condName = num2str(kk);
                    end
                    obj.CondNames{ii} = condName;
                    
                else
                    
                    % Check if CondNames{ii} has a name. If not name it but
                    % make sure not to duplicate a condition name
                    k = find(strcmp(obj.CondNames{ii}, obj.CondNames));
                    if length(k)>1
                        % Unname and then rename duplicate condition
                        obj.CondNames{ii} = '';
                        
                        jj=0;
                        while find(strcmp(num2str(ii), obj.CondNames))
                            kk=ii+jj;
                            obj.CondNames{ii} = num2str(kk);
                            jj=jj+1;
                        end
                    end
                    
                end
                
            end
            
            nTrials = sum(obj.s,1);
            
        end
        
        
        % ---------------------------------------------------------
        function t = GetTime(obj)
            
            t = obj.t;
            
        end
        
        
        % ---------------------------------------------------------
        function datamat = GetDataMatrix(obj, idx)
            
            datamat = obj.d;
            
        end
        
        
        % ---------------------------------------------------------
        function SD = GetSD(obj)
            
            SD = obj.SD;
            
        end
                
        
        % ---------------------------------------------------------
        function SetSD(obj, SD)
            
            obj.SD = SD;
            
        end
                
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj)
            
            ml = obj.SD.MeasList;
            
        end        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)

            wls = obj.SD.Lambda;
        
        end
        
        
        % ---------------------------------------------------------
        function SetStims(obj,s)
            
            obj.s = s;
            
        end
        
        
        % ---------------------------------------------------------
        function s = GetStims(obj)
            
            s = obj.s;
            
        end
        
        
        % ---------------------------------------------------------
        function CondNames = GetCondNames(obj)
            
            CondNames = obj.CondNames;
            
        end
        

        
        % ---------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            
            bbox = [obj.SD.xmin, obj.SD.xmax, obj.SD.ymin, obj.SD.ymax];
            
        end

        
        % ---------------------------------------------------------
        function srcpos = GetSrcPos(obj)
            
            srcpos = obj.SD.SrcPos;
            
        end
        
        
        % ---------------------------------------------------------
        function detpos = GetDetPos(obj)
            
            detpos = obj.SD.DetPos;
            
        end                
        
    end

end