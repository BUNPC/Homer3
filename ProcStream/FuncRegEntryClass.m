classdef FuncRegEntryClass < matlab.mixin.Copyable

    properties
        name
        uiname
        usageoptions
        params
        help
    end    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = FuncRegEntryClass(filename)
            if nargin==0
                return;
            end
            [~,funcname] = fileparts(filename);
            obj.name = funcname;
            obj.uiname = '';
            obj.usageoptions = {};
            obj.params       = {};
            obj.help = FuncHelpClass(funcname);
            obj.Parse();
        end

        
        % ----------------------------------------------------------------------------------
        function Parse(obj)
            %
            % Data flow for Parse:
            %   obj.help  --> Parse() --> {obj.usageoptions, obj.params}
            %
            [usage, friendlyname] = obj.help.GetUsageOptions();
            for ii=1:length(usage)
                obj.usageoptions{ii,1} = friendlyname{ii};
                obj.usageoptions{ii,2} = usage{ii};
            end
            
            [paramname, valformat] = obj.help.GetParamUsage();
            for ii=1:length(paramname)
                obj.params{ii,1} = paramname{ii};
                obj.params{ii,2} = valformat{ii};
            end
            
            obj.uiname = obj.help.GetUiname();
        end
        
    end
    
end
