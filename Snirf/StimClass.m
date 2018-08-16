classdef StimClass  < matlab.mixin.Copyable
    
    properties
        name
        data
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = StimClass(s,t)
            obj.name = '';
            if nargin>0
                kk=1;
                for ii=1:size(s,2)
                    k = find(s(:,ii)>0);
                    for jj=1:length(k)
                        obj.data(kk,1) = t(k(jj));
                        obj.data(kk,2) = 10;
                        obj.data(kk,3) = ii;
                        kk=kk+1;
                    end
                end
            else
                obj.data = [];
            end
        end
        
        % -------------------------------------------------------
        function obj = Load(obj, fname, parent)
            %
            % Example:
            %
            %     s = snirf.stim.Load('Simple_Probe.h5','/snirf/stim');
            %
            
            if ~exist(fname, 'file')
                return;
            end
            
            obj.name = h5read_safe(fname, [parent, '/name'], obj.name);
            obj.data = hdf5read_safe(fname, [parent, '/data'], obj.data);
            
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
            h5write('myfile.h5',[parent, '/data'], obj.data, [1,1], size(obj.data));

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