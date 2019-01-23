classdef TreeNodeClass < handle
    
    properties % (Access = private)        
        name;
        type;
        procStream;
        err;
        ch;
        CondNames;        
        CondName2Group;   % Global table used at subject and run levels to convert 
                          % condition index to global (or group-level) condition index.
    end
        
    methods
        
        
        % ---------------------------------------------------------------------------------
        function obj = TreeNodeClass(arg)
            obj.name = '';
            obj.type = '';
            obj.procStream = ProcStreamClass();
            obj.err = 0;
            obj.CondNames = {};
            obj.ch = struct('MeasList',[],'MeasListVis',[],'MeasListAct',[], 'Lambda',[]);
            
            % If this constructor is called from this class' copy method,
            % then we want to exit before we obliterate the persistent
            % variables (only one copy of which is shared across all objects 
            % of this class, like a static var in C++). 
            % 
            % Essentially if a copy arg is passed this constructor
            % is used as a copy constructor (to borrow C++ terminology)
            %
            if nargin==1
                if strcmp(arg,'copy')
                    return;
                end
            end
            obj.CondColTbl('init');
            obj.CondNamesAll('init');
        end
        
        
        % ---------------------------------------------------------------------------------
        function [procInput, filename] = GetProcInputDefault(obj, filename)
            
            procInput = struct([]);
            if ~exist('filename','var') || isempty(filename)
                filename = '';
            end
            
            err1=0; err2=0;
            if procStreamIsEmpty(obj.procStream.input)
                err1=1; err2=1;
            else
                procInput = obj.procStream.input;
            end
            
            
            %%%%% Otherwise try loading procInput from a config file, but first
            %%%%% figure out the name of the config file
            while ~all(err1==0) || ~all(err2==0)
                
                % Load Processing stream file
                if isempty(filename)
                    [filename, pathname] = createDefaultConfigFile();
                    
                    % Load procInput from config file
                    fid = fopen(filename,'r');
                    [procInput, err1] = procStreamParse(fid, obj);
                    fclose(fid);
                elseif ~isempty(filename)
                    % Load procInput from config file
                    fid = fopen(filename,'r');
                    [procInput, err1] = procStreamParse(fid, obj);
                    fclose(fid);
                else
                    err1=0;
                end
                                
                % Check loaded procInput for syntax and semantic errors
                if procStreamIsEmpty(procInput) && err1==0
                    ch = menu('Warning: config file is empty.','Okay');
                elseif err1==1
                    ch = menu('Syntax error in config file.','Okay');
                end
                
                [err2, iReg] = procStreamErrCheck(obj);
                if ~all(~err2)
                    i=find(err2==1);
                    str1 = 'Error in functions\n\n';
                    for j=1:length(i)
                        str2 = sprintf('%s%s',procInput.func(i(j)).name,'\n');
                        str1 = strcat(str1,str2);
                    end
                    str1 = strcat(str1,'\n');
                    str1 = strcat(str1,'Do you want to keep current proc stream or load another file?...');
                    ch = menu(sprintf(str1), 'Fix and load this config file','Create and use default config','Cancel');
                    if ch==1
                        [procInput, err2] = procStreamFixErr(err2, procInput, iReg);
                    elseif ch==2
                        filename = './processOpt_default.cfg';
                        procStreamFileGen(filename);
                        fid = fopen(filename,'r');
                        procInput = procStreamParse(fid, run);
                        fclose(fid);
                        break;
                    elseif ch==3
                        filename = '';
                        return;
                    end
                end
                
            end  % while ~all(err1==0) || ~all(err2==0)
            
        end  % function [procInput, filename] = GetProcInputDefault(obj, filename)
       

        % ----------------------------------------------------------------------------------
        % Override == operator: 
        % ----------------------------------------------------------------------------------
        function B = eq(obj1, obj2)
            B = equivalent(obj1, obj2);
        end

        
        % ----------------------------------------------------------------------------------
        % Override ~= operator
        % ----------------------------------------------------------------------------------
        function B = ne(obj1, obj2)
            B = ~equivalent(obj1, obj2);
        end
        
        
        % ----------------------------------------------------------------------------------
        % Copy function to do deep copy
        % ----------------------------------------------------------------------------------
        function objnew = copy(obj)
            switch(class(obj))
                case 'RunClass'
                    objnew = RunClass('copy');
                case 'SubjClass'
                    objnew = SubjClass('copy');
                case 'GroupClass'
                    objnew = GroupClass('copy');
                case ''
            end
            objnew.procStream.input = obj.procStream.input.copy();
        end
        
               
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and procResult) from
        % obj2 to obj
        % ----------------------------------------------------------------------------------
        function copyProcParamsFieldByField(obj, obj2)
            % procInput
            if isproperty(obj2.procStream,'input') && ~isempty(obj2.procStream.input)
                if isproperty(obj2.procStream.input,'func') && ~isempty(obj2.procStream.input.func)
                    obj.procStream.input.Copy(obj2.procStream.input);
                else
                    [obj.procStream.input.func, obj.procStream.input.param] = procStreamDefault(obj.type);
                end
            end
            
            % procResult
            if isproperty(obj2.procStream,'output') && ~isempty(obj2.procStream.output)
                obj.procStream.output = copyStructFieldByField(obj.procStream.output, obj2.procStream.output);
            end            
        end
        
                
        % ----------------------------------------------------------------------------------
        % 
        % ----------------------------------------------------------------------------------
        function options_s = parseSaveOptions(obj, options)
            options_s = struct('derived',false, 'acquired',false);
            C = str2cell(options, {':',',','+',' '});
            
            for ii=1:length(C)
                if isproperty(options_s, C{ii})
                    eval( sprintf('options_s.%s = true;', C{ii}) );
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = obj.CondNames;
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
            
            condition = obj.GetCondNameIdx(condition);
            
            d       = [];
            dStd    = [];
            t       = [];
            nTrials = [];
            
            if datatype == buttonVals.OD_HRF
                t = obj.procStream.output.tHRF;
                d = obj.procStream.output.dodAvg;
                if showStdErr
                    dStd = obj.procStream.output.dodAvgStd;
                end
                nTrials = obj.procStream.output.nTrials;
            elseif datatype == buttonVals.CONC_HRF
                t = obj.procStream.output.tHRF;
                d = obj.procStream.output.dcAvg;
                if showStdErr
                    dStd = obj.procStream.output.dcAvgStd * sclConc;
                end
                nTrials = obj.procStream.output.nTrials;
            end
            ch     = obj.GetMeasList();
            
            if isempty(condition)
                return;
            end
            
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
                if datatype == buttonVals.OD_HRF
                    d = d(:,:,condition);
                    d = obj.reshape_y(d, ch.MeasList);
                    DisplayDataRawOrOD(t, d, dStd, iWl, iCh, chLst, nTrials, condition, linecolor, linestyle);
                elseif datatype == buttonVals.CONC_HRF
                    d = d(:,:,:,condition) * sclConc;
                    DisplayDataConc(t, d, dStd, hbType, iCh, chLst, nTrials, condition, linecolor, linestyle);
                end
                
            end
            guiMain.axesSDG = DisplayAxesSDG(guiMain.axesSDG, obj);
        end
        
        
        % ----------------------------------------------------------------------------------
        function plotprobe = DisplayPlotProbe(obj, plotprobe, datatype, buttonVals, condition)
            SD          = obj.GetSDG();
            ch          = obj.GetMeasList();
            condition   = find(obj.CondName2Group == condition);
            tMarkAmp    = plotprobe.GetTmarkAmp();
            
            y = [];
            tMarkUnits = '';
            if datatype == buttonVals.OD_HRF && ~isempty(obj.procStream.output.dodAvg)
                y = obj.procStream.output.dodAvg(:, :, condition);
                tMarkUnits='(AU)';
            elseif datatype == buttonVals.CONC_HRF && ~isempty(obj.procStream.output.dcAvg)
                y = obj.procStream.output.dcAvg(:, :, :, condition);
                plotprobe.SetTmarkAmp(tMarkAmp/1e6);
                tMarkUnits='(micro-molars)';
            end
            tHRF = obj.procStream.output.tHRF;
            plotprobe.Display(y, tHRF, SD, ch, tMarkUnits);
        end
        
        
        % ----------------------------------------------------------------------------------
        function varval = FindVar(obj, varname)
            varval = [];
        end

                
        % ----------------------------------------------------------------------------------
        function str = EditProcParam(obj, iFunc, iParam, val)
            if isempty(iFunc)
                return;
            end
            if isempty(iParam)
                return;
            end
            obj.procStream.input.func(iFunc).paramVal{iParam} = val;
            eval( sprintf('obj.procStream.input.param.%s_%s = val;', ...
                          obj.procStream.input.func(iFunc).name, ...
                          obj.procStream.input.func(iFunc).param{iParam}) );
            str = sprintf(obj.procStream.input.func(iFunc).paramFormat{iParam}, val);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function AddStims(obj, tPts, condition)
            return;
        end        
        
        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts)
            return;
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimDuration(obj, icond, duration)
            return;
        end
    
        
        % ----------------------------------------------------------------------------------
        function duration = GetStimDuration(obj, icond)
            duration = [];            
        end
        
        
        % ----------------------------------------------------------------------------------
        function [tpts, duration, vals] = GetStimData(obj, icond)
            tpts     = [];
            duration = [];
            vals     = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function newname = ErrCheckNewCondName(obj, newname)
            msg1 = sprintf('Condition name ''%s'' already exists. New name must be unique. Do you want to choose another name?', newname);
            while ismember(newname, obj.CondNames)                
                q = menu(msg1,'YES','NO');
                if q==2
                    obj.err = -1;
                    return;
                end
                newname = inputdlg({'New Condition Name'}, 'New Condition Name');
                if isempty(newname) || isempty(newname{1})
                    obj.err = 1;
                    return;
                end
                newname = newname{1};
            end
            msg2 = sprintf('Condition name is not valid. New name must be character string. Do you want to choose another name?', newname);
            while ~ischar(newname)                
                q = menu(msg2,'YES','NO');
                if q==2
                    obj.err = -1;
                    return;
                end
                newname = inputdlg({'New Condition Name'}, 'New Condition Name');
                if isempty(newname) || isempty(newname{1})
                    obj.err = 1;
                    return;
                end
                newname = newname{1};
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function err = GetErrStatus(obj)
            err = obj.err;
            
            % Reset error status
            obj.err = 0;
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function y = reshape_y(obj, y, MeasList)
            yold = y;
            lst1 = find(MeasList(:,4)==1);
            Lambda = obj.GetWls();

            if ndims(y)==2
                y = zeros(size(yold,1),length(lst1),length(Lambda));
            elseif ndims(y)==3
                y = zeros(size(yold,1),length(lst1),length(Lambda),size(yold,3));
            end
            
            for iML = 1:length(lst1)
                for iLambda = 1:length(Lambda)
                    idx = find(MeasList(:,1)==MeasList(lst1(iML),1) & ...
                               MeasList(:,2)==MeasList(lst1(iML),2) & ...
                               MeasList(:,4)==iLambda );
                    if ndims(yold)==2
                        y(:,iML,iLambda) = yold(:,idx);
                    elseif ndims(yold)==3
                        y(:,iML,iLambda,:) = yold(:,idx,:);
                    end
                end
            end            
        end
        
        
        % ----------------------------------------------------------------------------------
        function name = GetName(obj)
            name = obj.name;
        end        
        
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Static class methods implementing static class variables
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static)
                
        % ----------------------------------------------------------------------------------
        function out = CondColTbl(arg)
            persistent tbl;
            if nargin==0
                out = tbl;
                return;
            end
            if ~strcmp(arg,'init')
                return
            end
            tbl = distinguishable_colors(20);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function out = CondNamesAll(arg)
            persistent cond;
            if nargin==0
                out = cond;
                return;
            elseif nargin==1
                if ischar(arg)
                    cond = {};
                else
                    cond = arg;
                end
            end          
        end
        
        
        % ----------------------------------------------------------------------------------
        function aux = GetAuxiliary(obj)
            aux = [];
        end
        
    end
    
end