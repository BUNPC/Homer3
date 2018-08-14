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
            obj.formatVersion = '';
            obj.timeOffset     = 0;
            obj.metaDataTags   = { 
                                   {'SubjectID','subj1'}
                                   {'MeasurementDate','19700401'}
                                   {'MeasurementTime','150127.34'}
                                   {'SpatialUnit','mm'} 
                                 };
            obj.data           = DataClass();

            if nargin>0
                obj.data(1) = DataClass(d,t,SD.MeasList);
                obj.stim    = StimClass(s);
                obj.sd      = SdClass(SD);
                obj.aux     = AuxClass(aux);                
            else
                obj.data(1) = DataClass();
                obj.stim    = StimClass();
                obj.sd      = SdClass();
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

