classdef GuiUnitTest < handle
    
    properties
        callbacks
        handles
        procStreamFile
    end
    
    methods
        
        % -------------------------------------------
        function obj = GuiUnitTest(handles, f, procStreamFile)
            obj.Initialize(handles, f, procStreamFile);
        end
        
        
        % ------------------------------------------
        function Initialize(obj, handles, f, procStreamFile)
            if ~exist('handles','var')
                handles = [];
            end
            if ~exist('f','var')
                f = [];
            end
            if ~exist('procStreamFile','var')
                procStreamFile = '';
            end
            obj.callbacks = f(handles);
            obj.handles = handles;
            obj.procStreamFile = procStreamFile;
        end
        
        
        % ------------------------------------------
        function fname = GetProcStreamFile(obj)
            fname = obj.procStreamFile;
        end
        
        
        % ------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            if isempty(obj.handles)
                return;
            end
            if isempty(obj.callbacks)
                return;
            end
            b = false;
        end
        
    end
    
end

