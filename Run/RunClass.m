classdef RunClass < TreeNodeClass
    
    properties % (Access = private)
        iSubj;
        iRun;
        rnum;
        acquired;        
    end
    
    methods
                
        % ----------------------------------------------------------------------------------
        function obj = RunClass(varargin)
            obj@TreeNodeClass(varargin);

            obj.type  = 'run';
            if nargin==4
                obj.name  = varargin{1};
                obj.iSubj = varargin{2};
                obj.iRun  = varargin{3};
                obj.rnum  = varargin{4};
            elseif nargin==1
                if ischar(varargin{1}) && strcmp(varargin{1},'copy')
                    return;
                end
            else
                obj.name  = '';
                obj.iSubj = 0;
                obj.iRun  = 0;
                obj.rnum  = 0;
            end            

            if obj.IsNirs()
                obj.acquired = NirsClass(obj.name);
            else
                obj.acquired = SnirfClass(obj.name);
            end            
            obj.CondName2Group = [];
            obj.Load();
        end
                
        
            
        % ----------------------------------------------------------------------------------
        function Load(obj)
            obj.acquired.Load();
        end
        
        
        % ----------------------------------------------------------------------------------
        function Save(obj, options)
            if ~exist('options','var')
                options = 'acquired:derived';
            end
            options_s = obj.parseSaveOptions(options);
            
            % Save derived data
            if options_s.derived
                if exist('./groupResults.mat','file')
                    load( './groupResults.mat' );
                    if strcmp(class(group.subjs(obj.iSubj).runs(obj.iRun)), class(obj))
                        group.subjs(obj.iSubj).runs(obj.iRun) = obj;
                    end
                    save( './groupResults.mat','group' );
                end
            end
            
            % Save acquired data
            if options_s.acquired
                obj.acquired.Save();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        % Deletes derived data in procResult
        % ----------------------------------------------------------------------------------
        function Reset(obj)
            obj.procResult = ProcResultClass();
        end
        
        
        
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and procResult) from
        % N2 to N1 if N1 and N2 are same nodes
        % ----------------------------------------------------------------------------------
        function copyProcParams(obj, R)
            if obj == R
                obj.copyProcParamsFieldByField(R);
            end
        end
        
            
        % ----------------------------------------------------------------------------------
        % Subjects obj1 and obj2 are considered equivalent if their names
        % are equivalent and their sets of runs are equivalent.
        % ----------------------------------------------------------------------------------
        function B = equivalent(obj1, obj2)
            B=1;
            [p1,n1] = fileparts(obj1.name);
            [p2,n2] = fileparts(obj2.name);
            if ~strcmp([p1,'/',n1],[p2,'/',n2])
                B=0;
                return;
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Data Display methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
            
        % ----------------------------------------------------------------------------------
        function b = IsNirs(obj)
            b = false;
            [~,~,ext] = fileparts(obj.name);
            if strcmp(ext,'.nirs')
                b = true;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function DisplayGuiMain(obj, guiMain)
            hAxes = guiMain.axesData.handles.axes;
            if ~ishandles(hAxes)
                return;
            end
            
            axes(hAxes)
            cla;
            legend off
            set(hAxes,'ygrid','on');
            
            
            linecolor  = guiMain.axesData.linecolor;
            linestyle  = guiMain.axesData.linestyle;
            datatype   = guiMain.datatype;
            condition  = guiMain.condition;
            iCh        = guiMain.ch;
            iWl        = guiMain.wl;
            hbType     = guiMain.hbType;
            buttonVals = guiMain.buttonVals;
            sclConc    = guiMain.sclConc;        % convert Conc from Molar to uMolar
            showStdErr = guiMain.showStdErr;
            
            condition = find(obj.CondName2Group == condition);
            
            d       = [];
            dStd    = [];
            t       = [];
            nTrials = [];
            
            if datatype == buttonVals.RAW
                d = obj.GetDataMatrix();
                t = obj.GetTime();
            elseif datatype == buttonVals.OD
                d = obj.procResult.dod;
                t = obj.GetTime();
            elseif datatype == buttonVals.CONC
                d = obj.procResult.dc;
                t = obj.GetTime();
            elseif datatype == buttonVals.OD_HRF
                d = obj.procResult.dodAvg;
                t = obj.procResult.tHRF;
                if showStdErr
                    dStd = obj.procResult.dodAvgStd;
                end
                nTrials = obj.procResult.nTrials;
                if isempty(condition)
                    return;
                end
            elseif datatype == buttonVals.CONC_HRF
                d = obj.procResult.dcAvg;
                t = obj.procResult.tHRF;
                if showStdErr
                    dStd = obj.procResult.dcAvgStd * sclConc;
                end
                nTrials = obj.procResult.nTrials;
                if isempty(condition)
                    return;
                end
            end
            ch      = obj.GetMeasList();
            Lambda  = obj.GetWls();
            
            %%% Plot data
            if ~isempty(d)
                xx = xlim();
                yy = ylim();
                if strcmpi(get(hAxes,'ylimmode'),'manual')
                    flagReset = 0;
                else
                    flagReset = 1;
                end
                hold on
                
                % Set the axes ranges
                if flagReset==1
                    set(hAxes,'xlim',[floor(min(t)) ceil(max(t))]);
                    set(hAxes,'ylimmode','auto');
                else
                    xlim(xx);
                    ylim(yy);
                end
                
                chLst = find(ch.MeasListVis(iCh)==1);
                
                % Plot data
                if datatype == buttonVals.RAW || datatype == buttonVals.OD
                    if  datatype == buttonVals.OD_HRF
                        d = d(:,:,condition);
                    end
                    d = reshape_y(d, ch.MeasList, Lambda);
                    DisplayDataRawOrOD(t, d, dStd, iWl, iCh, chLst, nTrials, condition, linecolor, linestyle);
                elseif datatype == buttonVals.CONC || datatype == buttonVals.CONC_HRF                    
                    if  datatype == buttonVals.CONC_HRF
                        d = d(:,:,:,condition);
                    end
                    d = d * sclConc;                    
                    DisplayDataConc(t, d, dStd, hbType, iCh, chLst, nTrials, condition, linecolor, linestyle);
                end
            end
            guiMain.axesSDG = DisplayAxesSDG(guiMain.axesSDG, obj);
            obj.DisplayStim(guiMain);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function DisplayStim(obj, guiMain)
            hAxes = guiMain.axesData.handles.axes;
            if ~ishandles(hAxes)
                return;
            end
            axes(hAxes);
            hold on;
            
            buttonVals = guiMain.buttonVals;
            
            if guiMain.datatype == buttonVals.RAW_HRF
                return;
            end
            if guiMain.datatype == buttonVals.OD_HRF
                return;
            end
            if guiMain.datatype == buttonVals.CONC_HRF
                return;
            end
            
            procResult = obj.procResult;
            
            %%% Plot stim marks. This has to be done before plotting exclude time
            %%% patches because stim legend doesn't work otherwise.
            if ~isempty(obj.GetStims())
                t = obj.acquired.GetTime();
                s = obj.acquired.GetStims();
                
                % Plot included and excluded stims                
                yrange = GetAxesYRangeForStimPlot(hAxes);                
                hLg=[];
                idxLg=[];
                kk=1;
                CondColTbl = obj.CondColTbl;              
                for iS = 1:size(s,2)
                    iCond = obj.CondName2Group(iS);
                    
                    lstS          = find(s(:,iS)==1 | s(:,iS)==-1);
                    lstExclS_Auto = [];
                    lstExclS_Man  = find(s(:,iS)==-1);
                    if isproperty(procResult,'s') && ~isempty(procResult.s)
                        lstExclS_Auto = find(s(:,iS)==1 & sum(procResult.s,2)<=-1);
                    end
                    
                    for iS2=1:length(lstS)
                        if ~isempty(find(lstS(iS2) == lstExclS_Auto))
                            hl = plot(t(lstS(iS2))*[1 1],yrange,'-.');
                            set(hl,'linewidth',1);
                            set(hl,'color',CondColTbl(iCond,:));
                        elseif ~isempty(find(lstS(iS2) == lstExclS_Man))
                            hl = plot(t(lstS(iS2))*[1 1],yrange,'--');
                            set(hl,'linewidth',1);
                            set(hl,'color',CondColTbl(iCond,:));
                        else
                            hl = plot(t(lstS(iS2))*[1 1],yrange,'-');
                            set(hl,'linewidth',1);
                            set(hl,'color',CondColTbl(iCond,:));
                        end
                    end
                    
                    % Get handles and indices of each stim condition
                    % for legend display
                    if ~isempty(lstS)
                        % We don't want dashed lines appearing in legend, so
                        % we draw invisible solid stims over all stims to
                        % trick the legend into only showing solid lines.
                        hLg(kk) = plot(t(lstS(iS2))*[1 1],yrange,'-', 'linewidth',4, 'visible','off');
                        set(hLg(kk),'color',CondColTbl(iCond,:));
                        idxLg(kk) = iCond;
                        kk=kk+1;
                    end
                end
                obj.DisplayCondLegend(hLg, idxLg);
            end
            hold off
            set(hAxes,'ygrid','on');
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function DisplayCondLegend(obj, hLg, idxLg)
            [idxLg, k] = sort(idxLg);
            CondNamesAll = obj.CondNamesAll;
            if ishandles(hLg)
                legend(hLg(k), CondNamesAll(idxLg));
            end
        end

        

        % ----------------------------------------------------------------------------------
        function varval = FindVar(obj, varname)
            if isproperty(obj, varname)
                varval = eval( sprintf('obj.%s', varname) );
            else
                varval = obj.acquired.FindVar(varname);
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function Calc(obj, hListbox, listboxFuncPtr)
            if ~exist('hListbox','var')
                hListbox = [];
            end
            if ~exist('listboxFuncPtr','var')
                listboxFuncPtr = [];
            end
            
            % Change and display position of current processing
            if ~isempty(listboxFuncPtr)
                listboxFuncPtr(hListbox, [obj.iSubj, obj.iRun]);
            end
            
            % Calculate processing stream
            procStreamCalc(obj);
        end
        
    end    % Public methods
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pubic Set/Get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
            
        % ----------------------------------------------------------------------------------
        function t = GetTime(obj, idx)
            if nargin==1
                idx=1;
            end
            t = obj.acquired.GetTime(idx);
        end
        
        
        % ----------------------------------------------------------------------------------
        function d = GetDataMatrix(obj, idx)
            if nargin<2
                idx = 1;
            end
            d = obj.acquired.GetDataMatrix(idx);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SD = GetSDG(obj)
            SD.SrcPos = obj.acquired.GetSrcPos();
            SD.DetPos = obj.acquired.GetDetPos();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetMeasList(obj)
            obj.ch.Lambda      = obj.acquired.GetWls();
            obj.ch.MeasList    = obj.acquired.GetMeasList();
            obj.ch.MeasListAct = ones(size(obj.ch.MeasList,1), 1);
            obj.ch.MeasListVis = ones(size(obj.ch.MeasList,1), 1);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ch = GetMeasList(obj)
            ch.Lambda      = obj.acquired.GetWls();
            ch.MeasList    = obj.acquired.GetMeasList();
            ch.MeasListAct = ones(size(ch.MeasList,1), 1);
            ch.MeasListVis = ones(size(ch.MeasList,1), 1);
        end

        
        % ----------------------------------------------------------------------------------
        function SetStims_MatInput(obj,s,t,CondNames)
            obj.acquired.SetStims_MatInput(s,t,CondNames);
        end
        
        
        % ----------------------------------------------------------------------------------
        function s = GetStims(obj)            
            s = obj.acquired.GetStims();
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetConditions(obj)
            obj.CondNames = unique(obj.acquired.GetConditions());
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = obj.acquired.GetConditions();
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditionsActive(obj)
            CondNames = obj.CondNames;
            s = obj.GetStims();
            for ii=1:size(s,2)
                if ismember(abs(1), s(:,ii))
                    CondNames{ii} = ['-- ', CondNames{ii}];
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetCondName2Group(obj, CondNamesGroup)
            obj.CondName2Group = zeros(1, length(obj.CondNames));
            for ii=1:length(obj.CondNames)
                obj.CondName2Group(ii) = find(strcmp(CondNamesGroup, obj.CondNames{ii}));
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.acquired.GetWls();
        end
        
        
        % ----------------------------------------------------------------------------------
        function bbox = GetSdgBbox(obj)
            bbox = obj.acquired.GetSdgBbox();
        end
        
        
        % ----------------------------------------------------------------------------------
        function aux = GetAux(obj)
            aux = obj.acquired.GetAux();            
        end
        
    end        % Public Set/Get methods
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % All other public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        
        % ----------------------------------------------------------------------------------
        function AddStims(obj, tPts, condition)
            if isempty(tPts)
                return;
            end
            if isempty(condition)
                return;
            end
            obj.acquired.AddStims(tPts, condition);
        end

        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var')
                condition = '';
            end
            obj.acquired.DeleteStims(tPts, condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function MoveStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var')
                condition = '';
            end
            obj.acquired.MoveStims(tPts, condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function [tpts, duration, vals] = GetStimData(obj, icond)
            tpts     = obj.GetStimTpts(icond);
            duration = obj.GetStimDuration(icond);
            vals     = obj.GetStimValues(icond);
        end
        
    
        % ----------------------------------------------------------------------------------
        function SetStimTpts(obj, icond, tpts)
            obj.acquired.SetStimTpts(icond, tpts);
        end
        
    
        % ----------------------------------------------------------------------------------
        function tpts = GetStimTpts(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            tpts = obj.acquired.GetStimTpts(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimDuration(obj, icond, duration)
            obj.acquired.SetStimDuration(icond, duration);
        end
        
    
        % ----------------------------------------------------------------------------------
        function duration = GetStimDuration(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            duration = obj.acquired.GetStimDuration(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimValues(obj, icond, vals)
            obj.acquired.SetStimValues(icond, vals);
        end
        
    
        % ----------------------------------------------------------------------------------
        function vals = GetStimValues(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            vals = obj.acquired.GetStimValues(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function RenameCondition(obj, oldname, newname)
            % Function to rename a condition. Important to remeber that changing the
            % condition involves 2 distinct well defined steps:
            %   a) For the current element change the name of the specified (old)
            %      condition for ONLY for ALL the acquired data elements under the
            %      currElem, be it run, subj, or group. In this step we DO NOT TOUCH
            %      the condition names of the run, subject or group.
            %   b) Rebuild condition names and tables of all the tree nodes group, subjects
            %      and runs same as if you were loading during Homer3 startup from the
            %      acquired data.
            %
            if ~exist('oldname','var') || ~ischar(oldname)
                return;
            end
            if ~exist('newname','var')  || ~ischar(newname)
                return;
            end
            newname = obj.ErrCheckNewCondName(newname);
            if obj.err ~= 0
                return;
            end
            obj.acquired.RenameCondition(oldname, newname);
        end
                
    end
    
end
