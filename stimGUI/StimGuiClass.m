classdef StimGuiClass < handle
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        handles
        Lines;
        LegendHdl;
        iAux;
        dataTree;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % -----------------------------------------------------------
        function obj = StimGuiClass(filename)
            obj.InitStimLines();
            obj.LegendHdl = -1;
            obj.iAux = 0;
            obj.handles = [];

            if exist('filename','var') && ischar(filename)
                handles = stimGUI(obj);
                obj.InitHandles(handles);
            elseif ~exist('filename','var')
                filename = '';
            end
            
            obj.Load(filename);            
            obj.EnableGuiObjects('on');
            obj.Display();
        end
        
        
        % -----------------------------------------------------------
        function delete(obj)
            if isempty(obj.handles)
                return;
            end
            if ishandles(obj.handles.stimGUI)
                delete(obj.handles.stimGUI);
            end            
        end
        

        % -----------------------------------------------------------
        function Launch(obj)
            if isempty(obj.handles) || ~ishandles(obj.handles.stimGUI)
                h = stimGUI(obj);
                obj.InitHandles(h);
            end 
            obj.Load();            
            obj.EnableGuiObjects('on');
            obj.Display();
        end

        
        
        % -----------------------------------------------------------
        function Update(obj)
            obj.Load();            
            obj.Display();
        end

        
        % -----------------------------------------------------------
        function Close(obj)
            if ishandles(obj.handles.stimGUI)
                delete(obj.handles.stimGUI);
            end
            obj.Reset();
        end

        
        % -----------------------------------------------------------
        function Load(obj, arg)
            global hmr            
            if ~isempty(hmr)
                % If hmr Gui context but hmr.dataTree is not yet initialized
                % then dataTree will be passed in as an arg
                if isempty(hmr.dataTree)
                    obj.dataTree = arg;
                else
                    obj.dataTree = hmr.dataTree;
                end
            elseif exist('arg','var')
                % If NOT in hmr Gui context then we're running StimGuiClass standalone.
                % In that case there are two possible types of arguments we can
                % pass: either the name of a data file or a dataTree class object
                if ischar(arg) && exist(arg,'file')==2
                    files = DataFilesClass(arg).files;
                    obj.dataTree = DataTreeClass(files);
                elseif isobject(arg)
                    obj.dataTree = arg;
                end
            elseif isempty(obj.dataTree)
                obj.dataTree = DataTreeClass().empty();
                return;
            end
            filename = obj.dataTree.currElem.procElem.name;
            [pname, fname, ext] = fileparts(filename);
            
            if isempty(obj.handles)
                return;
            end
            if ~ishandles(obj.handles.textFilename)
                return;
            end
            set(obj.handles.textFilename, 'string',[fname,ext]);
        end
        
        
        % -----------------------------------------------------------
        function Reset(obj)
            obj.LegendHdl = -1;
            obj.iAux = 0;
            delete(obj.dataTree);
            set(obj.handles.textFilename, 'string','');
            cla(obj.handles.axes1);
            InitHandles();
        end
        
        
        
        % -----------------------------------------------------------
        function InitHandles(obj, handles)
            obj.handles = struct( ...
                'stimGUI',[], ...
                'axes1',[], ...
                'radiobuttonZoom',[], ...
                'radiobuttonStim',[], ...
                'tableUserData',[], ...
                'pushbuttonUpdate',[], ...
                'pushbuttonRenameCondition',[], ...
                'textTimePts',[], ...
                'stimMarksEdit',[], ...
                'textFilename',[] ...
                );
            
            if ~exist('handles','var')
                return;
            end
            
            fields = propnames(obj.handles);
            for ii=1:length(fields)
                if eval( sprintf('isproperty(handles, ''%s'')', fields{ii}) )
                    eval( sprintf('obj.handles.%s = handles.%s;', fields{ii}, fields{ii}) );
                end
            end
        end
        
        
        % -----------------------------------------------------------
        function EnableGuiObjects(obj, onoff)
            if isempty(obj.handles)
                return;
            end
            if isempty(obj.dataTree)
                onoff = 'off';
            end
            obj.enableHandle('radiobuttonZoom', onoff);
            obj.enableHandle('radiobuttonStim', onoff);
            obj.enableHandle('tableUserData', onoff);
            obj.enableHandle('pushbuttonRenameCondition', onoff);
            obj.enableHandle('textTimePts', onoff);
            obj.enableHandle('stimMarksEdit' ,onoff);
        end
        
        
        % -----------------------------------------------------------
        function InitStimLines(obj, n)
            if ~exist('n','var')
                n = 0;
            end
            obj.Lines = repmat( struct('handle',[], 'color',[], 'widthReg',2, 'widthHighl',4), n,1);
        end
        
        
        
        % -----------------------------------------------------------
        function Display(obj)
            
            if isempty(obj.handles)
                return;
            end
            if ~ishandles(obj.handles.axes1)
                return;
            end
            if isempty(obj.dataTree)
                return;
            end
            
            axes(obj.handles.axes1)
            cla(obj.handles.axes1);
            hold(obj.handles.axes1, 'on');

            currElem       = obj.dataTree.currElem;
            
            % As of now this operation is undefined for non-Run nodes (i.e., Subj and Group)
            % So we clear the axes and exit
            if currElem.procType ~= 3
                return;
            end
            
            CondNamesGroup = obj.dataTree.group.GetConditions();
            CondColTbl     = obj.dataTree.group.CondColTbl();

            aux        = currElem.procElem.GetAuxiliary();
            t          = currElem.procElem.GetTime();
            s          = currElem.procElem.GetStims();
            
            if(~isempty(aux))
                h = plot(t, aux.data(:,obj.iAux),'color','k', 'parent',obj.handles.axes1);
            end
            [lstR,lstC] = find(abs(s)==1);
            [lstR,k] = sort(lstR);
            lstC = lstC(k);
            nStim = length(lstR);
            yy = get(obj.handles.axes1, 'ylim');
            obj.InitStimLines(length(lstR));
            idxLg=[];
            hLg=[];
            kk=1;
            for ii=1:nStim
                if(s(lstR(ii),lstC(ii))==1)
                    obj.Lines(ii).handle = plot([1 1]*t(lstR(ii)), yy,'-', 'parent',obj.handles.axes1);
                elseif(s(lstR(ii),lstC(ii))==-1)
                    obj.Lines(ii).handle = plot([1 1]*t(lstR(ii)), yy,'--', 'parent',obj.handles.axes1);
                end
                
                iCond = currElem.procElem.CondName2Group(lstC(ii));
                obj.Lines(ii).color = CondColTbl(iCond,1:3);
                try
                    set(obj.Lines(ii).handle,'color',obj.Lines(ii).color);
                catch
                    fprintf('ERROR!!!!\n');
                end
                set(obj.Lines(ii).handle, 'linewidth',obj.Lines(ii).widthReg);

                % Check which conditions are represented in S for the conditions
                % legend display.
                if isempty(find(idxLg == iCond))
                    hLg(kk) = plot([1 1]*t(1), yy,'-','color',obj.Lines(ii).color,'visible','off', 'parent',obj.handles.axes1);
                    idxLg(kk) = iCond;
                    kk=kk+1;
                end
            end
            
            if get(obj.handles.radiobuttonZoom,'value')==1    % Zoom
                h=zoom;
                set(h,'ButtonDownFilter',@obj.myZoom_callback);
                set(h,'enable','on')
            elseif get(obj.handles.radiobuttonStim,'value')==1 % Stim
                zoom off
                set(obj.handles.axes1,'ButtonDownFcn', 'stimGUI_DisplayData_StimCallback()');
                set(get(obj.handles.axes1,'children'), 'ButtonDownFcn', 'stimGUI_DisplayData_StimCallback()');
            end
            
            % Update legend
            if(ishandle(obj.LegendHdl))
                delete(obj.LegendHdl);
                obj.LegendHdl = -1;
            end
            [idxLg,k] = sort(idxLg);
            hLg = hLg(k);
            if ~isempty(hLg)
                iCond = currElem.procElem.CondName2Group(idxLg);
                obj.LegendHdl = legend(hLg, CondNamesGroup(iCond));
            end
            set(obj.handles.axes1,'xlim', [t(1), t(end)]);
            
        end

        
        % ------------------------------------------------
        function flag = myZoom_callback(obj, h, event_obj)
            if strcmpi( get(h,'Tag'), 'axes1' )
                flag = 0;
            else
                flag = 1;
            end
        end
                
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = private)
        
        function enableHandle(obj, handle, onoff)
            if eval( sprintf('ishandles(obj.handles.%s)', handle) )
                eval( sprintf('set(obj.handles.%s, ''enable'',onoff);', handle) );
            end
        end
        
    end
    
    
end


