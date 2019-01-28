classdef FuncRegEntryClass < matlab.mixin.Copyable

    properties
        name
        uiname
        usageoptions
        help
    end    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = FuncRegEntryClass(funcname)
            obj.name = funcname;
            obj.uiname = '';
            obj.usageoptions = {};
            obj.help = FuncHelpClass(funcname);
        end

        % ----------------------------------------------------------------------------------
        function obj = ParseUsageOptions()
            
        end
        
    end
    
end
