classdef ChildGuiClass < handle
    
    properties
        name
        handles
        args
        visible
        lastpos
        closeSupporting;
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
            obj.closeSupporting = 0;
            
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
            
            obj.closeSupporting = 0;
            
            % Allow up to 6 arguments to be passed to GUI
            a = obj.args;
            handles = []; %#ok<*PROPLC>
            switch(length(a))
                % Note that in addition to the guis known args we add as the last arg the last gui position. 
                % We do this because even if we can set the position after launching gui, it is much nices when 
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
                obj.SetTitle();
                
                % Try to make sure child gui is not obscured by prent gui
                obj.PositionFigures();
            end
        end
        
        
        % -------------------------------------------------------------------
        function LaunchWaitForExit(obj, varargin)
            argStr = obj.CreateArgString(varargin);
            if isempty(argStr)
                obj.Launch();
            else
                eval( sprintf('obj.Launch(%s)', argStr) );
            end
            waitForGui(obj.handles.figure);
        end
        
        
        % -------------------------------------------------------------------
        function argStr = CreateArgString(obj, args)
            argStr = '';
            for ii = 1:length(args)
                if isempty(argStr)
                    argStr = sprintf('varargin{%d}', ii);
                else
                    argStr = sprintf('%s, varargin{%d}', argStr, ii);
                end
            end
        end
        
        
        % -------------------------------------------------------------------
        function PositionFigures(obj)
            hp = findobj('tag', 'MainGUI');
            if ~ishandles(hp)
                return;
            end
                                                
            % Get initial units of parent and child guis
            us0 = get(0, 'units');  
            up0 = get(obj.handles.figure, 'units');
            uc0 = get(obj.handles.figure, 'units');
            
            % Normalize units of parent and child guis
            set(0,'units','normalized');
            set(hp, 'units', 'normalized');
            set(obj.handles.figure, 'units', 'normalized');

            % Get positions of parent and child guis
            % Set screen units to be same as GUI
            ps = get(0,'MonitorPositions');            
            pp = get(hp, 'position');
            pc = get(obj.handles.figure, 'position');

            % To work correctly for mutiple sceens, Ps must be sorted in ascending order
            ps = sort(ps,'ascend');
            
            % Find which monitor parent gui is in
            for ii = 1:size(ps,1)
                if (pp(1)+pp(3)/2) < (ps(ii,1)+ps(ii,3))
                    break;
                end
            end
            
            % Fix bug: if multiple monitors left-to-right physical arrangement does 
            % not match left-to-right virtual setting then subtract 1 from monitor number. 
            if ps(1)<0
                ii = ii-1;
            end
            
            % Re-position parent and child guis
            set(hp, 'position', [ii-pp(3), pp(2), pp(3), pp(4)])
            set(obj.handles.figure, 'position', [ii-1, pc(2), pc(3), pc(4)])

            
            % Reset parent and child guis' units
            set(0, 'units', us0);
            set(hp, 'units', up0);
            set(obj.handles.figure, 'units', uc0);
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
            if ~ishandles(obj.handles.figure)
                return;
            end
            if isempty(obj.name)
                return;
            end
            obj.args = {};
            obj.lastpos = get(obj.handles.figure, 'position');
            
            obj.CloseSupporting();
            
            % Now delete the parent GUI
            delete(obj.handles.figure);
            
            % See if there's a private GUI close function to call
            if ~isa(obj.handles.closeptr, 'function_handle')
                return;
            end
            obj.handles.closeptr();
        end
        
        
        
        % -------------------------------------------------------------------
        function CloseSupporting(obj)
            if ~ishandles(obj.handles.figure)
                return;
            end
            
            % Check to see if any figure associated with this GUI need  to
            % be closed as well
            msg = sprintf('Do you want to close all supporting figures associated with %s?', obj.name);
            figures = getappdata(obj.handles.figure, 'figures');            
            for ii = 2:length(figures)
                if ishandle(figures(ii))
                    if obj.closeSupporting == 2
                        break;
                    end
                    if obj.closeSupporting==0
                        obj.closeSupporting = MenuBox(msg, {'YES','NO'});
                    end
                    if obj.closeSupporting == 1
                        delete(figures(ii));
                    end
                end
            end
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