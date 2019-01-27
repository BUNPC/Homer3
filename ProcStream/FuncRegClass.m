classdef FuncRegClass < matlab.mixin.Copyable

    properties
        entries
    end
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = FuncRegClass()
            obj.entries = FuncRegEntryClass().empty();
        end
        
        % ----------------------------------------------------------------------------------
        function idx = FindEntry(obj, funcname)
        end
        
        % ----------------------------------------------------------------------------------
        function AddEntry(obj)
        end
        
        % ----------------------------------------------------------------------------------
        function EditEntry(obj, idx)
        end
        
        % ----------------------------------------------------------------------------------
        function DeleteEntry(obj, idx)
        end
        
    end
    
end
