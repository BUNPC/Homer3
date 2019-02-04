classdef FuncCallClass
    properties
        name
        nameUI
        argOut
        argIn
        nParam
        nParamVar
        param
        paramFormat
        paramVal
        help
    end
    
    methods
        function obj = FuncCallClass()
            obj.name        = '';
            obj.nameUI      = '';
            obj.argOut      = '';
            obj.argIn       = '';
            obj.nParam      = 0;
            obj.nParamVar   = 0;
            obj.param       = {};
            obj.paramFormat = {};
            obj.paramVal    = {};
            obj.help        = FuncHelpClass().empty();
        end
    end
end

