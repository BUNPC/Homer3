classdef SnirfClass  < matlab.mixin.Copyable
    
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
        function obj = SnirfClass(d, t, s, SD, aux, CondNames)
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

            % The basic 5 of a .nirs format
            if nargin==5
                
                obj.data(1) = DataClass(d,t,SD.MeasList);
                for ii=1:size(s,2)
                    obj.stim(ii) = StimClass(s(:,ii),t,num2str(ii));
                end
                obj.sd      = SdClass(SD);
                obj.aux     = AuxClass(aux,t);                
                
            % The basic 5 of a .nirs format plus the condition names
            elseif nargin==6
                
                obj.data(1) = DataClass(d,t,SD.MeasList);
                for ii=1:size(s,2)
                    obj.stim(ii) = StimClass(s(:,ii),t,CondNames{ii});
                end
                obj.sd      = SdClass(SD);
                obj.aux     = AuxClass(aux,t);
                
            else
                
                obj.data(1) = DataClass();
                obj.stim    = StimClass();
                obj.sd      = SdClass();
                obj.aux     = AuxClass();
                
            end

        end


        % -------------------------------------------------------
        function obj = Load(obj, fname, parent)
            
            % Args
            if ~exist(fname, 'file')
                return;
            end
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
            obj.aux.Load(fname, [parent, '/aux']);
                        
        end
        
        
        % -------------------------------------------------------
        function Save(obj, fname, parent)
            
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
            obj.aux.Save(fname, [parent, '/aux']);

        end

        
        % -------------------------------------------------------
        function obj = Load_try(obj, fname)
            
              obj = h5load(fname, obj, 'snirf');
              
        end
        
        
        % -------------------------------------------------------
        function Save_try(obj, fname)
            
             h5save(fname, obj, 'snirf');
             
        end
        
        
    end
    
end

