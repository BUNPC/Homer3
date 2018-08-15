classdef StimClass  < matlab.mixin.Copyable
    
    properties
        name
        data
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = StimClass(s)
            obj.name = '';
            if nargin>0
                obj.data = s;
            else
                obj.data = [];
            end
        end
        
        % -------------------------------------------------------
        function obj = Load(obj, fname, parent)
            
            if ~exist(fname, 'file')
                return;
            end
              
            obj.name = h5read_safe(fname, [parent, '/name'], obj.name);
            obj.data = h5read_safe(fname, [parent, '/data'], obj.data);

        end

        
        % -------------------------------------------------------
        function Save(obj, fname, parent)
            
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end     
            hdf5write_safe(fname, [parent, '/name'], obj.name);
            hdf5write_safe(fname, [parent, '/data'], obj.data);
            
        end
        
    end
    
end