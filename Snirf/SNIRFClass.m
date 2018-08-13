classdef SNIRFClass  < matlab.mixin.Copyable
    
    properties
        format_version
        data
        stim
        SD
        aux
        timeoffset
        metadatatags
    end
    
    methods

        % -------------------------------------------------------
        function obj = SNIRFClass(d, t, s, SD, aux)
            obj.format_version = '';
            obj.timeoffset     = 0;
            obj.metadatatags   = { {'K1','V1'}, {'K2','V2'}, {'K3','V3'}, {'K4','V4'} };
            obj.data           = DataClass();

            if nargin>0
                obj.data(1) = DataClass(d,t,SD.MeasList);
                obj.stim    = StimClass(s);
                obj.SD      = SDClass(SD);
                obj.aux     = AuxClass(aux);                
            else
                obj.data(1) = DataClass();
                obj.stim    = StimClass();
                obj.SD      = SDClass();
                obj.aux     = AuxClass();
            end

        end


        % -------------------------------------------------------
        function obj = Load(obj, fname)
            
              obj = h5load(fname, obj, 'snirf');
              
        end

        
        % -------------------------------------------------------
        function Save(obj, fname)
            
            h5save(fname, obj, 'snirf');
            
        end
        
    end
    
end

