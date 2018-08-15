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
        function obj = SnirfClass(d, t, s, SD, aux)
            obj.formatVersion = '1.0';
            obj.timeOffset     = 0;
            obj.metaDataTags   = { 
                                   {'SubjectID','subj1'}
                                   {'MeasurementDate','yyyyddmo'}
                                   {'MeasurementTime','hhmmss.ms'}
                                   {'SpatialUnit','mm'} 
                                 };
            obj.data           = DataClass();

            if nargin>0
                obj.data(1) = DataClass(d,t,SD.MeasList);
                obj.stim    = StimClass(s);
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
            obj.timeOffset = h5read(fname, [parent, '/timeOffset']);
            obj.metaDataTags = h5read(fname, [parent, '/metaDataTags']);
            
            ii=1;
            while h5exist(finfo, [parent, '/data_', num2str(ii)])
                if ii > length(obj.data)
                    obj.data(ii) = DataClass;
                end
                obj.data(ii).Load(fname, [parent, '/data_', num2str(ii)]);
                ii=ii+1;
            end
            obj.stim.Load(fname, [parent, '/stim']);
            obj.sd.Load(fname, [parent, '/sd']);
            obj.aux.Load(fname, [parent, '/aux']);
                        
        end
        
        
        % -------------------------------------------------------
        function Save(obj, fname, parent)
            
            % Args
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            if ~exist('parent', 'var')
                parent = '/snirf';
            elseif parent(1)~='/'
                parent = ['/',parent];
            end            
            
            hdf5write(fname, [parent, '/formatVersion'], obj.formatVersion, 'WriteMode','append');
            hdf5write(fname, [parent, '/timeOffset'], obj.timeOffset, 'WriteMode','append');
            hdf5write(fname, [parent, '/metaDataTags'], obj.metaDataTags, 'WriteMode','append');
           
            for ii=1:length(obj.data)
                obj.data(ii).Save(fname, [parent, '/data_', num2str(ii)]);
            end
            obj.stim.Save(fname, [parent, '/stim']);
            obj.sd.Save(fname, [parent, '/sd']);
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

