classdef StimEditClass < handle
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        handles
        dataTree;
        guiMain;
        status;
        figPosLast;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % -----------------------------------------------------------
        function obj = StimEditClass(filename)
            obj.handles = struct('stimGUI',[]);
            obj.status = 0;
            obj.figPosLast = [];
            
            if ~exist('filename','var')
                filename = '';
            end
            obj.Load(filename);

            if ischar(filename)
                obj.handles.stimGUI = stimGUI(obj);
            end
            obj.EnableGuiObjects('on');
            obj.Display();
        end
        
        
        % -----------------------------------------------------------
        function delete(obj)
            if isempty(obj.handles)
                return;
            end
            if ~isempty(obj.handles.stimGUI)
                if ishandles(obj.handles.stimGUI.figure)
                    delete(obj.handles.stimGUI.figure);
                end
            end
        end
        

        % -----------------------------------------------------------
        function Launch(obj)
            obj.handles.stimGUI = stimGUI(obj);
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
                % If NOT in hmr Gui context then we're running StimEditClass standalone.
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
            stimGUI_Update(obj.handles.stimGUI);
        end


        % -----------------------------------------------------------
        function EnableGuiObjects(obj, onoff)
            if isempty(obj.handles)
                return;
            end
            if isempty(obj.dataTree)
                onoff = 'off';
            end
            if ~isempty(obj.handles.stimGUI)
                stimGUI_EnableGuiObjects(onoff, obj.handles.stimGUI);
            end
        end
        
        
        % -----------------------------------------------------------
        function Display(obj)
            if isempty(obj.dataTree)
                return;
            end
            currElem = obj.dataTree.currElem;            
            stimGUI_Display(obj.handles.stimGUI);
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
        function EditSelectRange(obj, t1, t2)
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
                        if isempty(CondNameNew)
                            return;
                        end
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
        
        
        % -------------------------------------------------------------------
        function name = GetName(obj)
            name = obj.dataTree.currElem.procElem.GetName();
        end
                
        % -------------------------------------------------------------------
        function conditions = GetConditions(obj)
            conditions = obj.dataTree.currElem.procElem.GetConditions();
        end
        
        % -------------------------------------------------------------------
        function SetConditions(obj)
            obj.dataTree.group.SetConditions();
        end
        
        % -------------------------------------------------------------------
        function SetStimData(obj, icond, data)
            obj.dataTree.currElem.procElem.SetStimTpts(icond, data(:,1));
            obj.dataTree.currElem.procElem.SetStimDuration(icond, data(:,2));
            obj.dataTree.currElem.procElem.SetStimValues(icond, data(:,3));
        end
        
        % -------------------------------------------------------------------
        function [tpts, duration, vals] = GetStimData(obj, icond)
            [tpts, duration, vals] = obj.dataTree.currElem.procElem.GetStimData(icond);
        end
        
        % -------------------------------------------------------------------
        function icond = GetCondName2Group(obj, icond)
            icond = obj.dataTree.currElem.procElem.CondName2Group(icond);
        end
        
        % -------------------------------------------------------------------
        function conditions = GetConditionsGroup(obj)
            conditions = obj.dataTree.group.GetConditions();
        end
        
        % -------------------------------------------------------------------
        function CondColTbl = GetCondColTbl(obj)
            CondColTbl = obj.dataTree.group.CondColTbl();
        end
        
        % -------------------------------------------------------------------
        function aux = GetAuxiliary(obj)
            aux = obj.dataTree.currElem.procElem.GetAuxiliary();
        end
        
        % -------------------------------------------------------------------
        function t = GetTime(obj)
            t = obj.dataTree.currElem.procElem.GetTime();
        end
        
        % -------------------------------------------------------------------
        function s = GetStims(obj)
            s = obj.dataTree.currElem.procElem.GetStims();
        end
        
        % -------------------------------------------------------------------
        function RenameCondition(obj, oldname, newname)
            obj.dataTree.group.RenameCondition(oldname, newname);
        end
        
        % -------------------------------------------------------------------
        function err = GetErrStatus(obj)
            err = obj.dataTree.group.GetErrStatus();
        end
        
    end
    
end


