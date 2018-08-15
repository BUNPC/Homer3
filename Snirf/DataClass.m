classdef DataClass  < matlab.mixin.Copyable
    
    properties
        d
        t
        ml
    end
    
    
    methods
        
        % -------------------------------------------------------
        function obj = DataClass(d, t, ml)

            obj.ml = MeasListClass();

            if nargin>0
                obj.d = d;
                obj.t = t;
                for ii=1:size(ml)
                    obj.ml(ii) = MeasListClass(ml(ii,:));
                end
            else
                obj.d = double([]);
                obj.t = double([]);
            end

        end
        


        % -------------------------------------------------------
        function obj = Load(obj, fname, parent)
            
            if ~exist(fname, 'file')
                return;
            end
              
            obj.d = h5read_safe(fname, [parent, '/d'], obj.d);
            obj.t = h5read_safe(fname, [parent, '/t'], obj.t);
            
            ii=1;
            info = h5info(fname);
            while h5exist(info, [parent, '/ml_', num2str(ii)])
                if ii > length(obj.ml)
                    obj.ml(ii) = MeasListClass;
                end
                obj.ml(ii).Load(fname, [parent, '/ml_', num2str(ii)]);
                ii=ii+1;
            end
            
        end
        
        
        % -------------------------------------------------------
        function Save(obj, fname, parent)
            
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            
            hdf5write_safe(fname, [parent, '/d'], obj.d);
            hdf5write_safe(fname, [parent, '/t'], obj.t);
            
            for ii=1:length(obj.ml)
                obj.ml(ii).Save(fname, [parent, '/ml_', num2str(ii)]);
            end
            
        end
                
    end
    
end