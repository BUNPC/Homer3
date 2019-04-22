classdef GenericAcqClass < AcqDataClass
    
    properties
        
    end
    
    
    methods

        function obj = GenericAcqClass()
            ;
        end
        
        % ---------------------------------------------------------
        function t = GetTime(obj, iBlk)
            t = [];
        end
        
        
        % ---------------------------------------------------------
        function datamat = GetDataMatrix(obj, iBlk)
            datamat = [];
        end
        
        
        % ---------------------------------------------------------
        function SD = GetSDG(obj)
            SD = [];
        end
        
        
        % ---------------------------------------------------------
        function SetSDG(obj, SD)
            obj.SD = [];
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj, iBlk)
            ml = [];
        end
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = [];
        end
        
        
        % ---------------------------------------------------------
        function SetStims_MatInput(obj,s,t,CondNames)
            obj.s = [];
        end
                
        
        % ---------------------------------------------------------
        function s = GetStims(obj, t)
            s = [];
        end
        
        
        % ---------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = [];
        end
                
        
        % ---------------------------------------------------------
        function srcpos = GetSrcPos(obj)
            srcpos = [];
        end
        
        
        % ---------------------------------------------------------
        function detpos = GetDetPos(obj)
            detpos = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function aux = GetAuxiliary(obj)
            aux = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(obj)
            n = 1;
        end
        
        
        % ----------------------------------------------------------------------------------
        function obj2 = MutableParams(obj)            
            obj2 =[];
        end
        
        
        % ----------------------------------------------------------------------------------
        function [iDataBlks, ich] = GetDataBlocksIdxs(obj, ich)
            iDataBlks = [];
            ich=[];
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimDuration(obj, icond, duration)
            return;
        end
        
        
        % ----------------------------------------------------------------------------------
        function duration = GetStimDuration(obj, icond)
            duration = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function objnew = CopyMutable(obj)
            objnew = obj.copy;
        end
        
    end
        
end

