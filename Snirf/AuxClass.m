classdef AuxClass  < matlab.mixin.Copyable
    
    properties
        name
        d
        t
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = AuxClass(aux,t)
            obj.name = 'aux1';
            if nargin>0
                obj.d = aux;
                obj.t = t;
            else
                obj.d = [];
                obj.t = [];
            end
        end
        
        % -------------------------------------------------------
        function obj = Load(obj, fname, parent)
            
            if ~exist(fname, 'file')
                return;
            end
              
            obj.name = h5read(fname, [parent, '/name']);
            obj.d    = h5read_safe(fname, [parent, '/d'], obj.d);
            obj.t    = h5read_safe(fname, [parent, '/t'], obj.t);

        end

        
        % -------------------------------------------------------
        function Save(obj, fname, parent)
            
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end     
            
            hdf5write(fname, [parent, '/name'], obj.name, 'WriteMode','append');
            hdf5write_safe(fname, [parent, '/d'], obj.d);
            hdf5write_safe(fname, [parent, '/t'], obj.t);

        end
        
    end
    
end