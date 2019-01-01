classdef StimGuiClass < handle
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        handles
        Lines;
        iAux;
        dataTree;
        guiMain;
        status;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % -----------------------------------------------------------
        function obj = StimGuiClass(filename)
            obj.InitStimLines();
            obj.iAux = 0;
            obj.handles = [];
            obj.status = 0;

            if ~exist('filename','var')
                filename = '';
            end
            if ischar(filename)
                handles = stimGUI(obj);
                obj.InitHandles(handles);
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
            if ishandles(obj.handles.this)
                delete(obj.handles.this);
            end            
        end
        

        % -----------------------------------------------------------
        function Launch(obj)
            if isempty(obj.handles) || ~ishandles(obj.handles.this)
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
            if ishandles(obj.handles.this)
                delete(obj.handles.this);
            end
            obj.InitHandles();
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
                if ~isempty(hmr.guiMain)
                    obj.guiMain = hmr.guiMain;
                end
            elseif exist('arg','var') && ~isempty(arg)
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
            [~, fname, ext] = fileparts(filename);
            
            if isempty(obj.handles)
                return;
            end
            if ~ishandles(obj.handles.textFilename)
                return;
            end
            
            SetTextFilename(obj, [fname, ext, ' :']); 

            % Try to keep the same condition as old run
            [icond, conditions] = GetConditionIdxFromPopupmenu(obj);
            set(obj.handles.popupmenuConditions, 'value',icond);
            set(obj.handles.popupmenuConditions, 'string',conditions);
            obj.SetUitableStimInfo(conditions{icond});
        end


        % -----------------------------------------------------------
        function [icond, conditions] = GetConditionIdxFromPopupmenu(obj)           
            conditions =  obj.dataTree.currElem.procElem.GetConditions();
            conditions_menu = get(obj.handles.popupmenuConditions, 'string');
            idx = get(obj.handles.popupmenuConditions, 'value');
            if isempty(conditions_menu)
                icond = 1;
                return;
            end
            condition = conditions_menu{idx};
            icond = find(strcmp(conditions, condition));
            if isempty(icond)
                icond = 1;
            end
        end        
        
        
        
        % -----------------------------------------------------------
        function InitHandles(obj, handles)
            obj.handles = struct( ...
                'this',[], ...                
                'stimGUI',[], ...
                'axes1',[], ...
                'radiobuttonZoom',[], ...
                'radiobuttonStim',[], ...
                'tableUserData',[], ...
                'pushbuttonUpdate',[], ...
                'pushbuttonRenameCondition',[], ...
                'textTimePts',[], ...
                'stimMarksEdit',[], ...
                'textFilename',[], ...
                'popupmenuConditions',[], ...
                'uitableStimInfo',[] ...
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
            
            obj.handles.legend = -1;
            set(obj.handles.axes1,'ButtonDownFcn', @obj.ButtondownFcn);
            set(get(obj.handles.axes1,'children'), 'ButtonDownFcn', @obj.ButtondownFcn);
            obj.handles.this = obj.handles.stimGUI;
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
        function SetTextFilename(obj, name)
            n = length(name);
            set(obj.handles.textFilename, 'units','characters');
            p = get(obj.handles.textFilename, 'position');
            set(obj.handles.textFilename, 'position',[p(1), p(2), n+.50*n, p(4)]);
            set(obj.handles.textFilename, 'units','normalized');            
            set(obj.handles.textFilename, 'string',name);
        end
        
        
        % -----------------------------------------------------------
        function Reset(obj)
            obj.iAux = 0;
            delete(obj.dataTree);
            set(obj.handles.textFilename, 'string','');
            cla(obj.handles.axes1);
            InitHandles();
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
            set(obj.handles.axes1, 'ytick','');
            hold(obj.handles.axes1, 'on');

            currElem = obj.dataTree.currElem;
            
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
                if ~ismember(iCond, idxLg)
                    hLg(kk) = plot([1 1]*t(1), yy,'-','color',obj.Lines(ii).color,'visible','off', 'parent',obj.handles.axes1);
                    % idxLg(kk) = lstC(ii);
                    idxLg(kk) = iCond;
                    kk=kk+1;
                end
            end
            
            if get(obj.handles.radiobuttonZoom,'value')==1    % Zoom
                h=zoom;
                set(h,'ButtonDownFilter',@obj.myZoom_callback);
                set(h,'enable','on')
            elseif get(obj.handles.radiobuttonStim,'value')==1 % Stim
                zoom(obj.handles.this,'off');
            end
            
            % Update legend
            if(ishandle(obj.handles.legend))
                delete(obj.handles.legend);
                obj.handles.legend = -1;
            end
            [idxLg,k] = sort(idxLg);
            hLg = hLg(k);
            if ~isempty(hLg)
                % iCond = currElem.procElem.CondName2Group(idxLg);
                obj.handles.legend = legend(hLg, CondNamesGroup(idxLg));
            end
            set(obj.handles.axes1,'xlim', [t(1), t(end)]);
            
            % Update conditions popupmenu 
            set(obj.handles.popupmenuConditions, 'string', sort(currElem.procElem.CondNames));
            conditions = get(obj.handles.popupmenuConditions, 'string');
            idx = get(obj.handles.popupmenuConditions, 'value');
            condition = conditions{idx};
            obj.SetUitableStimInfo(condition);
        end
        
        
        % ------------------------------------------------
        function flag = myZoom_callback(obj, h, event_obj)
            if strcmpi( get(h,'Tag'), 'axes1' )
                flag = 0;
            else
                flag = 1;
            end
        end
       
        
        % ------------------------------------------------
        function stims_select = GetStimsFromTpts(obj, tPts_idxs_select)
            
            % Error checking
            if isempty(obj.dataTree)
                return;
            end
            if isempty(obj.dataTree.currElem)
                return;
            end
            if obj.dataTree.currElem.procType~=3
                return;
            end
            
            % Now that we made sure legit dataTree exists, we can match up
            % the selected stims to the stims in currElem
            currElem = obj.dataTree.currElem;
            s = currElem.procElem.GetStims();            
            s2 = sum(abs(s(tPts_idxs_select,:)),2);
            stims_select = find(s2>=1);
                        
        end
           
        
        % ------------------------------------------------
        function ButtondownFcn(obj, hObject, eventdata)
            
            [point1,point2] = extractButtondownPoints();            
            point1 = point1(1,1:2);              % extract x and y
            point2 = point2(1,1:2);
            p1 = min(point1,point2);
            p2 = max(point1,point2);
            t1 = p1(1);
            t2 = p2(1);
            
            t = obj.dataTree.currElem.procElem.GetTime();
            if ~all(t1==t2)
                tPts_idxs_select = find(t>=t1 & t<=t2);
            else
                tVals = (t(end)-t(1))/length(t);
                tPts_idxs_select = min(find(abs(t-t1)<tVals));
            end
            stims_select = obj.GetStimsFromTpts(tPts_idxs_select);
            if isempty(stims_select) & ~(t1==t2)
                menu( 'Drag a box around the stim to edit.','Okay');
                return;
            end
                       
            obj.AddEditDelete(tPts_idxs_select, stims_select);
            if obj.status==0
                return;
            end
            obj.Display();
            obj.DisplayGuiMain();
            figure(obj.handles.this);  % return focus to stimGUI
            
            % Reset status
            obj.status=0;
            
        end
        
        
        % ------------------------------------------------
        function EditSelectTpts(obj, tPts_select)

            t = obj.dataTree.currElem.procElem.GetTime();
            tPts_idxs_select = [];
            for ii=1:length(tPts_select)
                tPts_idxs_select(ii) = binaraysearchnearest(t, tPts_select(ii));
            end
            stims_select = obj.GetStimsFromTpts(tPts_idxs_select);
            obj.AddEditDelete(tPts_idxs_select, stims_select);
            if obj.status==0
                return;
            end
            obj.Display();
            obj.DisplayGuiMain();
            figure(obj.handles.this);  % return focus to stimGUI
            
            % Reset status
            obj.status=0;
            
        end
        
        
        % ------------------------------------------------
        function DisplayGuiMain(obj)
            global hmr
            if ~isempty(obj.guiMain)
                obj.dataTree.currElem.procElem.DisplayGuiMain(obj.guiMain)
            end
            if ~isempty(hmr)
                hmr.guiMain = UpdateAxesDataCondition(obj.guiMain, obj.dataTree);
            end
        end
        
        
        % ------------------------------------------------
        function AddEditDelete(obj, tPts_idxs_select, iS_lst)
            % Usage:
            %
            %     AddEditDelete(tPts_select, iS_lst)
            %
            % Inputs:
            %
            %     tPts  - time range selected in stim.currElem.procElem.t
            %     iS_lst - indices in tPts of existing stims
                                   
            if isempty(tPts_idxs_select)
                return;
            end
                       
            dataTree       = obj.dataTree;
            currElem       = dataTree.currElem;
            group          = dataTree.group;
            CondNamesGroup = group.GetConditions();
            tc             = currElem.procElem.GetTime();
            nCond          = length(CondNamesGroup);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            % Create menu actions list
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            actionLst = CondNamesGroup;
            actionLst{end+1} = 'New condition';
            if ~isempty(iS_lst)
                actionLst{end+1} = 'Toggle active on/off';
                actionLst{end+1} = 'Delete';
                menuTitleStr = sprintf('Edit/Delete stim mark(s) at t=%0.1f-%0.1f to...', ...
                                       tc(tPts_idxs_select(iS_lst(1))), ...
                                       tc(tPts_idxs_select(iS_lst(end))));
            else
                menuTitleStr = sprintf('Add stim mark at t=%0.1f...', tc(tPts_idxs_select(1)));
            end
            actionLst{end+1} = 'Cancel';
            nActions = length(actionLst);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            % Get user's responce to menu question
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            ch = menu(menuTitleStr, actionLst);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            % Cancel
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            if ch==nActions || ch==0
                return;
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            % New stim
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isempty(iS_lst)
                

                % If stim added to new condition update group conditions
                if ch==nCond+1
                    CondNameNew = inputdlg('','New Condition name');
                    if isempty(CondNameNew)
                        return;
                    end
                    while ismember(CondNameNew{1}, CondNamesGroup)
                        CondNameNew = inputdlg('Condition already exists. Choose another name.','New Condition name');
                        if isempty(CondNameNew)
                            return;
                        end
                    end
                    CondName = CondNameNew{1};
                else
                    CondName = CondNamesGroup{ch};
                end
                
                %%%% Add new stim to currElem's condition
                currElem.procElem.AddStims(tc(tPts_idxs_select), CondName);
                obj.status = 1;
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            % Existing stim
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                
                %%%% Delete stim
                if ch==nActions-1 & nActions==nCond+4
                    
                    % Delete stim entry from userdata first
                    % because it depends on stim.currElem.procElem.s
                    currElem.procElem.DeleteStims(tc(tPts_idxs_select));
                    
                %%%% Toggle active/inactive stim
                elseif ch==nActions-2 & nActions==nCond+4
                    
                    ;
                    
                %%%% Edit stim
                elseif ch<=nCond+1
                    
                    % Assign new condition to edited stim
                    if ch==nCond+1
                        CondNameNew = inputdlg('','New Condition name');
                        CondName = CondNameNew{1};
                    else
                        CondName = CondNamesGroup{ch};
                    end
                    currElem.procElem.MoveStims(tc(tPts_idxs_select), CondName);
                    
                end
                obj.status = 1;

            end
            
            group.SetConditions();

        end

        
        % ------------------------------------------------
        function SetStimDuration(obj, icond, duration)
            if isempty(obj)
                return;
            end
            if isempty(obj.dataTree)
                return;
            end
            if isempty(obj.dataTree.currElem)
                return;
            end            
            obj.dataTree.currElem.procElem.SetStimDuration(icond, duration);
        end
           
        
        % ------------------------------------------------
        function duration = GetStimDuration(obj, icond)
            if isempty(obj)
                return;
            end
            if isempty(obj.dataTree)
                return;
            end
            if isempty(obj.dataTree.currElem)
                return;
            end   
            duration = obj.dataTree.currElem.procElem.GetStimDuration(icond);
        end
        
        
        % ------------------------------------------------
        function SetUitableStimInfo(obj, condition)
            if ~exist('condition','var')
                return;
            end
            CondNames =  obj.dataTree.currElem.procElem.GetConditions();
            if isempty(CondNames)
                return;
            end
            icond = find(strcmp(CondNames, condition));
            if isempty(icond)
                return;
            end
            tpts     = obj.dataTree.currElem.procElem.GetStimTpts(icond);
            duration = obj.dataTree.currElem.procElem.GetStimDuration(icond);
            vals     = obj.dataTree.currElem.procElem.GetStimValues(icond);
            if isempty(tpts)
                set(obj.handles.uitableStimInfo, 'data',[]);
                return;
            end
            data = zeros(length(tpts),3);
            data(:,1) = tpts;
            data(:,2) = duration;
            data(:,3) = vals;            
            set(obj.handles.uitableStimInfo, 'data',data);
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


