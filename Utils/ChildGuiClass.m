classdef ChildGuiClass < handle
    
    properties
        name
        handles
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
            % Description:
            %   Child GUIs must follow certain rules to be managed by this 
            %   class. Rules are these:
            % 
            %       a) GUI output function <gui_name>_OutputFcn callback
            %          function must be in this form:
            % 
            %           function varargout = <gui_name>_OutputFcn(hObject, eventdata, handles)
            %           handles.updateptr = @<function name for updating>;
            %           handles.closeptr = @<function name for closing>;   
            %           varargout{1} = handles;
            %
            %           The function pointers updateptr and closeptr can
            %           also be empty.
            %
            %       b) position argument pos must be last if it exists. 
            %
            %       c) GUI 'tag' property must be named 'figure'
            %
            %      
            % Examples:
            %   gui = ChildGuiClass('ProcStreamEditGUI', true, '.nirs');
            %   gui = ChildGuiClass('ProcStreamEditGUI', true, '.snirf');
            %
            
            obj.name = '';
            obj.handles = struct('figure',[], 'updateptr',[], 'closeptr',[], 'saveptr',[]);
            obj.args = {};
            obj.visible = 'on';
            obj.lastpos = [];
            
            if nargin==0
                return;
            end
            
            if isempty(which(name))
                return;
            end

            if nargin==1
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

                    % Allow passing of up to 6 arguments.
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
                        case 6
                            obj.Launch(a{1}, a{2}, a{3}, a{4}, a{5}, a{6});
                    end
                end
            end
        end
        
        
        % -------------------------------------------------------------------
        function CopyHandles(obj, handles) %#ok<INUSL>
            props = propnames(handles);
            for ii = 1:length(props)               
                % If field does exist in handles, then chack that it's a
                % valid handle before copying it. 
                if eval( sprintf('ishandles(handles.%s)', props{ii}) )
                    eval( sprintf('obj.handles.%s = handles.%s;', props{ii}, props{ii}) )
                elseif eval( sprintf('isa(handles.%s, ''function_handle'')', props{ii}) )
                    eval( sprintf('obj.handles.%s = handles.%s;', props{ii}, props{ii}) )
                end
            end
        end
        
        
        % -------------------------------------------------------------------
        function Launch(obj, varargin)
            if isempty(obj)
                return;
            end
            
            if isempty(obj.name)
                return;
            end
            
            % If GUI already up and running, then don't relaunch it, simply exit
            if ishandle(obj.handles.figure)
                figure(obj.handles.figure);
                return;
            end
            if exist('varargin','var') && isempty(obj.args)
                obj.args = varargin;
            end
            
            % Allow up to 6 arguments to be passed to GUI
            a = obj.args;
            handles = []; %#ok<*PROPLC>
            switch(length(a))
                % Note that in addition to the guis known args we add as the last arg the last gui position. 
                % We do this because even we can set the position after launching gui, it is much nices when 
                % the gui is not seen to change position. If the position is set from within the GUI it 
                % appears only in the position we pass it since it is invisible until the gui's open function 
                % exits
                case 0
                    eval( sprintf('handles = %s(obj.lastpos);', obj.name) );
                case 1
                    eval( sprintf('handles = %s(a{1}, obj.lastpos);', obj.name) );
                case 2
                    eval( sprintf('handles = %s(a{1}, a{2}, obj.lastpos);', obj.name) );
                case 3
                    eval( sprintf('handles = %s(a{1}, a{2}, a{3}, obj.lastpos);', obj.name) );
                case 4
                    eval( sprintf('handles = %s(a{1}, a{2}, a{3}, a{4}, obj.lastpos);', obj.name) );
                case 5
                    eval( sprintf('handles = %s(a{1}, a{2}, a{3}, a{4}, a{5}, obj.lastpos);', obj.name) );
                case 6
                    eval( sprintf('handles = %s(a{1}, a{2}, a{3}, a{4}, a{5}, a{6}, obj.lastpos);', obj.name) );
            end
            
            obj.CopyHandles(handles);            
            
            if ishandle(obj.handles.figure)
                set(obj.handles.figure, 'visible',obj.visible, 'CloseRequestFcn',@obj.Close);
                set(obj.handles.figure, 'visible',obj.visible, 'DeleteFcn',@obj.Close);
%                 if ~isempty(obj.lastpos)
%                     % Even though we pass the last position arg to the GUI
%                     % there's no guarantee, the gui will take advantage of
%                     % it. Therefore we make sure to set last gui position if it
%                     % is available. 
%                     p = obj.lastpos;
%                     set(obj.handles.figure, 'position',[p(1),p(2),p(3),p(4)]);
%                 end
                obj.SetTitle();
            end
        end
        
               
        
        % -------------------------------------------------------------------
        function UpdateArgs(obj, varargin)
            if ~ishandle(obj.handles.figure)
                return;
            end
            if isempty(obj.name)
                return;
            end
            if ~exist('varargin','var')
                return;
            end
            obj.args = varargin;
        end

        
        
        % -------------------------------------------------------------------
        function Update(obj)
            if isempty(obj.name)
                return;
            end            
            if isempty(obj.handles)
                return;
            end
            if ~ishandle(obj.handles.figure)
                % If GUI is not already up and running, then exit
                return;
            end
            if ~isa(obj.handles.updateptr, 'function_handle')
                return;
            end
            
            % Allow up to 6 arguments to be passed to GUI
            a = obj.args;
            switch(length(a))
                % Note that in addition to the guis known args we add as the last arg the last gui position. 
                % We do this because even if we can set the position after launching gui, it is much nicer when 
                % the gui is not seen to change position. If the position is set from within the GUI it 
                % appears only in the position we pass it since it is invisible until the gui's open function 
                % exits
                case 0
                    eval( sprintf('obj.handles.updateptr(obj.handles);') );
                case 1
                    eval( sprintf('obj.handles.updateptr(obj.handles, a{1});') );
                case 2
                    eval( sprintf('obj.handles.updateptr(obj.handles, a{1}, a{2});') );
                case 3
                    eval( sprintf('obj.handles.updateptr(obj.handles, a{1}, a{2}, a{3});') );
                case 4
                    eval( sprintf('obj.handles.updateptr(obj.handles, a{1}, a{2}, a{3}, a{4});') );
                case 5
                    eval( sprintf('obj.handles.updateptr(obj.handles, a{1}, a{2}, a{3}, a{4}, a{5});') );
                case 6
                    eval( sprintf('obj.handles.updateptr(obj.handles, a{1}, a{2}, a{3}, a{4}, a{5}, a{6});') );
            end
        end
        
        
        
        % -------------------------------------------------------------------
        function Save(obj)
            if isempty(obj.name)
                return;
            end            
            if isempty(obj.handles)
                return;
            end
            if ~ishandle(obj.handles.figure)
                % If GUI is not already up and running, then exit
                return;
            end
            if ~isa(obj.handles.saveptr, 'function_handle')
                return;
            end            
            obj.handles.saveptr();            
        end
        
        
        
        % -------------------------------------------------------------------
        function Close(obj, hObject, eventdata) %#ok<INUSD>
            if isempty(obj.name)
                return;
            end
            obj.args = {};
            if ~ishandle(obj.handles.figure)
                return;
            end
            obj.lastpos = get(obj.handles.figure, 'position');
            delete(obj.handles.figure);
            
            % See if there's a private GUI close function to call
            if ~isa(obj.handles.closeptr, 'function_handle')
                return;
            end
            obj.handles.closeptr();
        end
        
        
        
        % -------------------------------------------------------------------
        function [title, vernum] = SetTitle(obj, option)
            %
            % Syntax:
            %    [title, vernum] = obj.SetTitle()
            %    [title, vernum] = obj.SetTitle(option)
            %
            % Example:
            %
            %    [verstr, vernum, title] = obj.SetTitle('exclpath')
            %            
            if isempty(obj.name)
                return;
            end
            if nargin==1 || ~ischar(option) || ~ismember(option, {'inclpath', 'exclpath'})
                option = '';
            end            
            if isempty(option)
                option = 'inclpath';
            end
            [verstr, vernum] = version2string();
            if strcmp(option, 'inclpath')
                title = sprintf('%s: (%s) - %s', obj.name, verstr, pwd);
            elseif strcmp(option, 'exclpath')
                title = sprintf('%s: (%s)', obj.name, verstr);
            end
            if ishandle(obj.handles.figure)
                set(obj.handles.figure,'name', title);
            end
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
            obj.handles.figure = val;
        end
        
        % -------------------------------------------------------------------
        function val = GetHandle(obj)
            val = obj.handles.figure;
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