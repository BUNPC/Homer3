classdef SnirfClass < AcqDataClass
    
    %
    % Example usage:
    %
    %     snirf = SnirfClass('./Simple_Probe1_run04.snir5');
    %     t = snirf.GetTime();
    %     s = snirf.GetStims();
    %     
    
    properties
        formatVersion
        data
        stim
        sd
        aux
        timeOffset
        metaDataTags
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = SnirfClass(varargin)
            
            % This parameter does NOT get saved when saving to Snirf file
            obj.filename = '';
            
            % Initialize fields that can be initialized without any
            % arguments
            obj.formatVersion = '1.0';
            obj.timeOffset     = 0;
            obj.metaDataTags   = {
                {'SubjectID','subj1'};
                {'MeasurementDate','yyyyddmo'};
                {'MeasurementTime','hhmmss.ms'};
                {'SpatialUnit','mm'};
                };
            obj.data           = DataClass();
            obj.stim           = StimClass();
            obj.sd             = SdClass();
            obj.aux            = AuxClass();
            
            % See if we're loading .nirs data format
            if nargin>4
                d         = varargin{1};
                t         = varargin{2};
                SD        = varargin{3};
                aux       = varargin{4};
                s         = varargin{5};
            end
            if nargin>5
                CondNames = varargin{6};
            end
            
            
            % The basic 5 of a .nirs format
            if nargin==1
                
                if ischar(varargin{1})
                    obj.filename = varargin{1};
                    obj.Load();
                elseif isstruct(varargin{1})
                    nirs = varargin{1};
                    
                    obj.data(1) = DataClass(nirs.d, nirs.t, nirs.SD.MeasList);
                    for ii=1:size(nirs.s,2)
                        if isfield(nirs, 'CondNames')
                            obj.stim(ii) = StimClass(nirs.s(:,ii), nirs.t, nirs.CondNames{ii});
                        else
                            obj.stim(ii) = StimClass(nirs.s(:,ii), nirs.t, num2str(ii));
                        end
                    end
                    obj.sd      = SdClass(nirs.SD);
                    for ii=1:size(nirs.aux,2)
                        obj.aux(ii) = AuxClass(nirs.aux(:,ii), nirs.t, sprintf('aux%d',ii));
                    end
                end
                
            elseif nargin==5
                
                obj.data(1) = DataClass(d,t,SD.MeasList);
                for ii=1:size(s,2)
                    obj.stim(ii) = StimClass(s(:,ii),t,num2str(ii));
                end
                obj.sd      = SdClass(SD);
                for ii=1:size(aux,2)
                    obj.aux(ii) = AuxClass(aux, t, sprintf('aux%d',ii));
                end
                
                % The basic 5 of a .nirs format plus the condition names
            elseif nargin==6
                
                obj.data(1) = DataClass(d,t,SD.MeasList);
                for ii=1:size(s,2)
                    obj.stim(ii) = StimClass(s(:,ii),t,CondNames{ii});
                end
                obj.sd      = SdClass(SD);
                for ii=1:size(aux,2)
                    obj.aux(ii) = AuxClass(aux, t, sprintf('aux%d',ii));
                end
                
            end
            
        end
        
        
        % -------------------------------------------------------
        function obj = Load(obj, fname, parent)
            
            % Overwrite 1st argument if the property filename is NOT empty
            if ~isempty(obj.filename)
                fname = obj.filename;
            end
            
            % Arg 1
            if ~exist('fname','var')
                return;
            end
            if ~exist(fname,'file')
                return;
            end
            
            % Arg 2
            if ~exist('parent', 'var')
                parent = '/snirf';
            elseif parent(1)~='/'
                parent = ['/',parent];
            end
            
            finfo = h5info(fname);
            
            obj.formatVersion = deblank(h5read(fname, [parent, '/formatVersion']));
            obj.timeOffset = hdf5read(fname, [parent, '/timeOffset']);
            
            % Load metaDataTags
            ii=1;
            while 1
                try
                    obj.metaDataTags{ii}{1} = deblank(h5read(fname, [parent, '/metaDataTags_', num2str(ii), '/k']));
                    obj.metaDataTags{ii}{2} = deblank(h5read(fname, [parent, '/metaDataTags_', num2str(ii), '/v']));
                catch
                    break;
                end
                ii=ii+1;
            end
            
            % Load data
            ii=1;
            while 1
                if ii > length(obj.data)
                    obj.data(ii) = DataClass;
                end
                if obj.data(ii).Load(fname, [parent, '/data_', num2str(ii)]) < 0
                    obj.data(ii).delete();
                    obj.data(ii) = [];
                    break;
                end
                ii=ii+1;
            end
            
            % Load stim
            ii=1;
            while 1
                if ii > length(obj.stim)
                    obj.stim(ii) = StimClass;
                end
                if obj.stim(ii).Load(fname, [parent, '/stim_', num2str(ii)]) < 0
                    obj.stim(ii).delete();
                    obj.stim(ii) = [];
                    break;
                end
                ii=ii+1;
            end
            
            % Load sd
            obj.sd.Load(fname, [parent, '/sd']);
            
            % Load aux
            ii=1;
            while 1
                if ii > length(obj.aux)
                    obj.aux(ii) = AuxClass;
                end
                if obj.aux(ii).Load(fname, [parent, '/aux_', num2str(ii)]) < 0
                    obj.aux(ii).delete();
                    obj.aux(ii) = [];
                    break;
                end
                ii=ii+1;
            end
            
        end
        
        
        % -------------------------------------------------------
        function Save(obj, fname, parent)
            
            if ~isempty(obj.filename)
                fname = obj.filename;
            end
            
            % Args
            if exist(fname, 'file')
                delete(fname);
            end
            fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
            H5F.close(fid);
            
            if ~exist('parent', 'var')
                parent = '/snirf';
            elseif parent(1)~='/'
                parent = ['/',parent];
            end
            
            %%%%% Save this object's properties
            
            % Save formatVersion
            hdf5write(fname, [parent, '/formatVersion'], obj.formatVersion, 'WriteMode','append');
            
            % Save timeOffset
            hdf5write(fname, [parent, '/timeOffset'], obj.timeOffset, 'WriteMode','append');
            
            % Save metaDataTags
            for ii=1:length(obj.metaDataTags)
                key = sprintf('%s/metaDataTags_%d/k', parent, ii);
                val = sprintf('%s/metaDataTags_%d/v', parent, ii);
                hdf5write_safe(fname, key, obj.metaDataTags{ii}{1});
                hdf5write_safe(fname, val, obj.metaDataTags{ii}{2});
            end
            
            % Save data
            for ii=1:length(obj.data)
                obj.data(ii).Save(fname, [parent, '/data_', num2str(ii)]);
            end
            
            % Save stim
            for ii=1:length(obj.stim)
                obj.stim(ii).Save(fname, [parent, '/stim_', num2str(ii)]);
            end
            
            % Save sd
            obj.sd.Save(fname, [parent, '/sd']);
            
            % Save aux
            for ii=1:length(obj.aux)
                obj.aux(ii).Save(fname, [parent, '/aux_', num2str(ii)]);
            end
                        
        end
                      
                   
        % ---------------------------------------------------------
        function t = GetTime(obj, idx)
            
            if nargin==1
                idx=1;
            end
            t = obj.data(idx).GetTime();
            
        end
        
        
        % ---------------------------------------------------------
        function datamat = GetDataMatrix(obj, idx)
            
            if nargin==1
                idx=1;
            end
            datamat = obj.data(idx).GetDataMatrix();
                        
        end
        
        
        % ---------------------------------------------------------
        function SD = GetSD(obj)
            
            SD.srcpos = obj.sd.GetSrcPos();
            SD.detpos = obj.sd.GetDetPos();
            
        end
        
        
        % ---------------------------------------------------------
        function SetSD(obj, SD)
            
            %obj.SD = SD;
            
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj, idx)
            
            if nargin==1
                idx=1;
            end
            ml = obj.data(idx).GetMeasList();
            
        end
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            
            wls = obj.sd.GetWls();
            
        end
        
        
        % ---------------------------------------------------------
        function SetStims(obj, s)
            
            %obj.s = s;
            
        end
        
        
        % ---------------------------------------------------------
        function s = GetStims(obj)
            
            t = obj.data(1).GetTime();
            s = zeros(length(t), length(obj.stim));
            for ii=1:length(obj.stim)
                ts = obj.stim(ii).GetStim();
                [~, k] = nearest_point(t, ts);
                if isempty(k)
                    continue;
                end
                s(k,ii) = 1;
            end
            
        end
        
        
        % ---------------------------------------------------------
        function SetCondNames(obj)
            
            ;
            
        end
        
        
        % ---------------------------------------------------------
        function CondNames = GetCondNames(obj)
            
            CondNames = {};
            for ii=1:length(obj.stim)
                CondNames{ii} = obj.stim(ii).GetCondName();
            end
            
        end
        
        
        
        % ---------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            
            %bbox = [obj.SD.xmin, obj.SD.xmax, obj.SD.ymin, obj.SD.ymax];
            optpos = [obj.sd.GetSrcPos(); obj.sd.GetDetPos()];
            
            xmin = min(optpos(:,1));
            xmax = max(optpos(:,1));
            ymin = min(optpos(:,2));
            ymax = max(optpos(:,2));
            
            bbox = [xmin, xmax, ymin, ymax];
            
        end
        
        
        % ---------------------------------------------------------
        function srcpos = GetSrcPos(obj)
            
            srcpos = obj.sd.GetSrcPos();
            
        end
        
        
        % ---------------------------------------------------------
        function detpos = GetDetPos(obj)
            
            detpos = obj.sd.GetDetPos();
            
        end
        
        
        % ----------------------------------------------------------------------------------
        function aux = GetAux(obj)
            
            aux = struct('data',[], 'names',{{}});            
            for ii=1:size(obj.aux,2)
                aux.data(:,ii) = obj.aux(ii).GetData();
                aux.names{ii} = obj.aux(ii).GetName();
            end
            
        end
        
    end
    
end

