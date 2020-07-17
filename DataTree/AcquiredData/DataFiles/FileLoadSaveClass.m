classdef FileLoadSaveClass < matlab.mixin.Copyable
    
    properties
        filename;
        fileformat;
        supportedFomats;
        err;
        options;        
    end
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = FileLoadSaveClass()
            obj.filename = '';
            obj.fileformat = '';
            obj.supportedFomats = struct( ...
                'matlab', {{'.mat','matlab','mat'}}, ...
                'hdf5', {{'hdf','.hdf','hdf5','.hdf5','hf5','.hf5','h5','.h5'}} ...
                );
            obj.err = 0;
            obj.options = 'memory';            
        end
        
        
        % ---------------------------------------------------------
        function Load(obj, filename, format, params)
            if ~exist('filename','var')
                filename = obj.filename;
            end
            if ~exist('format','var')
                format = obj.fileformat;
            elseif obj.Supported(format)
                obj.fileformat = format;
            end
            if ~exist('params','var')
                params = [];
            end            
                        
            switch(lower(format))
                case obj.supportedFomats.matlab
                    if ismethod(obj, 'LoadMat')
                        obj.err = obj.LoadMat(filename, params);
                    end
                case obj.supportedFomats.hdf5
                    if ismethod(obj, 'LoadHdf5')
                        obj.err = obj.LoadHdf5(filename, params);
                    end
            end
        end
        
        
        % ---------------------------------------------------------
        function Save(obj, filename, format, params)
            if ~exist('filename','var')
                filename = obj.filename;
            end            
            if ~exist('format','var')
                format = obj.fileformat;
            end
            if ~exist('params','var')
                params = [];
            end            
                       
            switch(lower(format))
                case obj.supportedFomats.matlab
                    if ismethod(obj, 'SaveMat')
                        obj.SaveMat(filename, params);
                    end
                case obj.supportedFomats.hdf5
                    if ismethod(obj, 'SaveHdf5')
                        obj.SaveHdf5(filename, params);
                    end
            end
        end
        
        
        % ---------------------------------------------------------
        function b = Supported(obj, format)
            b = true;
            switch(lower(format))
                case obj.supportedFomats.matlab
                    return;
                case obj.supportedFomats.hdf5
                    return;
            end
            b = false;
        end
        

        % -------------------------------------------------------
        function B = ne(obj, obj2)
            if obj==obj2
                B = false;
            else
                B = true;
            end
        end
        
    end
end