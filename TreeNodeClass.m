% classdef TreeNodeClass < handle

% This class is derived from matlab.mixin.Copyable 
% which means an object of this class is passed and assigned by 
% reference; same as if it was derived from handle (see the 
% commented definition at the top). However in addition to the 
% being of being a handle object the base class matlab.mixin.Copyable
% provides a copy function which allows assignments and argument 
% passing by value which is very useful
classdef TreeNodeClass < matlab.mixin.Copyable
    
    properties % (Access = private)
        
        name;
        type;
        SD;
        CondNames;
        procInput;
        procResult;
        err;
    end
    
    methods
        
        
        % -------------------------------------------------
        function obj = TreeNodeClass()
            obj.name = '';
            obj.type = '';
            obj.SD = struct([]);
            obj.CondNames = {};
            obj.procInput = InitProcInput();
            obj.procResult = InitProcResult();
            obj.err = 0;
        end
        
    end    
end