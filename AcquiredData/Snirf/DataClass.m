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
        function err = Load(obj, fname, parent)
            
            err = 0;
            
            if ~exist(fname, 'file')
                err = -1;
                return;
            end
              
            try
                obj.d = h5read(fname, [parent, '/d']);
                obj.t = h5read(fname, [parent, '/t']);
            catch
                err = -1;
                return;
            end
            
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

        
        
        % -------------------------------------------------------
        function b = Empty(obj)
            
            b = false;
            if isempty(obj.d) && isempty(obj.t)
                b = true;
            end
            
        end
    
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            
            wls = obj.ml(1).GetWls();
            
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj)
            
            ml = zeros(length(obj.ml), 4);
            for ii=1:length(obj.ml)
                ml(ii,:) = [obj.ml(ii).GetSourceIndex(), obj.ml(ii).GetDetectorIndex(), 1, obj.ml(ii).GetWavelengthIndex()];
            end
            
        end
        
        
        % ---------------------------------------------------------
        function t = GetTime(obj)
            
            t = obj.t;
            
        end
        
        
        % ---------------------------------------------------------
        function datamat = GetDataMatrix(obj)
            
            datamat = obj.d;
            
        end
        
        
        
        
    end
    
end