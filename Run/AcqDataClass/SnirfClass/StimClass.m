classdef StimClass  < matlab.mixin.Copyable
    
    properties
        name
        data
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = StimClass(s, t, CondName)
            
            if nargin==3
                
                k = s>0;
                obj.data = [t(k), 5*ones(length(t(k)),1), ones(length(t(k)),1)];
                obj.name = CondName;

            elseif nargin==0

                obj.name = '';
                obj.data = [];

            end
            
        end
        
        
        % -------------------------------------------------------
        function err = Load(obj, fname, parent)

            err = 0;
            
            if ~exist(fname, 'file')
                err = -1;
                return;
            end
              
            try
                name = deblank(h5read(fname, [parent, '/name']));
                obj.name = name{1};
                obj.data = h5read(fname, [parent, '/data']);
            catch
                err = -1;
                return;
            end
                        
        end
        
        
        % -------------------------------------------------------
        function Save(obj, fname, parent)
            
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            hdf5write_safe(fname, [parent, '/name'], obj.name);
            
            % Since this is a writable and variable size parameter, we want to 
            % use h5create and specify 'Inf' for the number of rows to
            % indicate variable number of rows
            h5create(fname, [parent, '/data'], [Inf,3],'ChunkSize',[3,3]);
            if ~isempty(obj.data)
                h5write(fname,[parent, '/data'], obj.data, [1,1], size(obj.data));
            end

        end
        
        
        
        % -------------------------------------------------------
        function Update(obj, fname, parent)
            
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            hdf5write_safe(fname, [parent, '/name'], obj.name);
            h5write_safe(fname, [parent, '/data'], obj.data);
            
        end
        
    end
    
end
