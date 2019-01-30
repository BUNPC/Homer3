classdef ChildGuiClass < handle
    
    properties
        name
        handle
        args
        visible
        lastpos
    end
    
    methods
        
        % -------------------------------------------------------------------
        function obj = ChildGuiClass(name, launch, varargin)
            % Syntax:
            %   gui = ChildGuiClass()
            %   gui = ChildGuiClass('guiname')
            %   gui = ChildGuiClass('guiname', true)
            %   gui = ChildGuiClass('guiname', true, arg1, arg2, ..., arg5);
            %
            % Examples:
            %   gui = ChildGuiClass('procStreamGUI', true, '.nirs');
            %   gui = ChildGuiClass('procStreamGUI', true, '.snirf');
            %
            obj.name = '';
            obj.handle = [];
            obj.args = {};
            obj.visible = 'on';
            obj.lastpos = [];

            if nargin==0
                return;
            elseif nargin==1
                obj.name = name;
            elseif nargin==2                
                obj.name = name;
                if launch
                    obj.Launch();
                end
            elseif nargin>2
                obj.name = name;
                if launch
                    obj.args = varargin;
                    a = obj.args;

                    % Allow passing of up to 5 arguments.
                    switch(length(a))
                        case 0
                            obj.Launch();
                        case 1
                            obj.Launch(a{1});
                        case 2
                            obj.Launch(a{1}, a{2});
                        case 3
                            obj.Launch(a{1}, a{2}, a{3});
                        case 4
                            obj.Launch(a{1}, a{2}, a{3}, a{4});
                        case 5
                            obj.Launch(a{1}, a{2}, a{3}, a{4}, a{5});
                    end
                end
            end
        end
        
        
        % -------------------------------------------------------------------
        function Launch(obj, varargin)
            if isempty(obj.name)
                return;
            end
            
            % If GUI already up and running, then don't relaunch it, simply exit
            if ishandle(obj.handle)
                return;
            end           
            if exist('varargin','var') && isempty(obj.args)
                obj.args = varargin;
            end
            
            % Allow up to 5 arguments to be passed to GUI
            a = obj.args;            
            switch(length(a))
                % Note that in addition to the guis known args we add as the last arg the last gui position. 
                % We do this because even we can set the position after launching gui, it is much nices when 
                % the gui is not seen to change position. If the position is set from within the GUI it 
                % appears only in the position we pass it since it is invisible until the gui's open function 
                % exits
                case 0
                    eval( sprintf('obj.handle = %s(obj.lastpos);', obj.name) );
                case 1
                    eval( sprintf('obj.handle = %s(a{1}, obj.lastpos);', obj.name) );
                case 2
                    eval( sprintf('obj.handle = %s(a{1}, a{2}, obj.lastpos);', obj.name) );
                case 3
                    eval( sprintf('obj.handle = %s(a{1}, a{2}, a{3}, obj.lastpos);', obj.name) );
                case 4
                    eval( sprintf('obj.handle = %s(a{1}, a{2}, a{3}, a{4}, obj.lastpos);', obj.name) );
                case 5
                    eval( sprintf('obj.handle = %s(a{1}, a{2}, a{3}, a{4}, a{5}, obj.lastpos);', obj.name) );
            end
            if ishandle(obj.handle)
                set(obj.handle, 'visible',obj.visible, 'CloseRequestFcn',@obj.Close);
                if ~isempty(obj.lastpos)
                    % Even though we pass the last position arg to the GUI
                    % there's no guarantee, the gui will take advantage of
                    % it. There we make sure to set last gui position if it
                    % is available. 
                    p = obj.lastpos;
                    set(obj.handle, 'position',[p(1),p(2),p(3),p(4)]);
                end
            end
        end
        
        
        % -------------------------------------------------------------------
        function Close(obj, hObject, eventdata)
            if ~ishandle(obj.handle)
                return;
            end
            obj.lastpos = get(obj.handle, 'position');
            delete(obj.handle);
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set/Get methods for class properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        % -------------------------------------------------------------------
        function SetName(obj, val)
            obj.name = val;
        end
        
        % -------------------------------------------------------------------
        function val = GetName(obj)
            val = obj.name;
        end
        
        % -------------------------------------------------------------------
        function SetHandle(obj, val)
            obj.handle = val;
        end
        
        % -------------------------------------------------------------------
        function val = GetHandle(obj)
            val = obj.handle;
        end
        
        % -------------------------------------------------------------------
        function SetLastPos(obj, val)
            obj.lastpos = val;
        end
        
        % -------------------------------------------------------------------
        function val = GetLastPos(obj)
            val = obj.lastpos;
        end
        
        % -------------------------------------------------------------------
        function SetVisible(obj, val)
            obj.visible = val;
        end
        
        % -------------------------------------------------------------------
        function val = GetVisible(obj)
            val = obj.visible;
        end
        
        % -------------------------------------------------------------------
        function SetArgs(obj, val)
            obj.args = val;
        end
        
        % -------------------------------------------------------------------
        function val = GetArgs(obj)
            val = obj.args;
        end
        
    end
end