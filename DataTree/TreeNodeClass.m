classdef TreeNodeClass < handle
    
    properties % (Access = private)        
        name;
        type;
        iGroup;
        iSubj;
        iRun;
        iFile;
        procStream;
        err;
        CondNames;        
        updateParentGui;
    end
     
    properties
        outputVars
        DEBUG
        path
    end
        
    methods
        
        
        % ---------------------------------------------------------------------------------
        function obj = TreeNodeClass(arg)
            obj.DEBUG = 0;
            
            obj.name = '';
            obj.iGroup = 0;
            obj.iSubj = 0;
            obj.iRun = 0;
            obj.type = '';
            obj.procStream = ProcStreamClass();
            obj.err = 0;
            obj.CondNames = {};
            obj.path = filesepStandard(pwd);
            
            
            obj.InitParentAppFunc();
            
            % If this constructor is called from this class' copy method,
            % then we want to exit before we obliterate the persistent
            % variables (only one copy of which is shared across all objects 
            % of this class, like a static var in C++). 
            % 
            % Essentially if a copy arg is passed this constructor
            % is used as a copy constructor (to borrow C++ terminology)
            %
            if nargin==1
                if iscell(arg) && ~isempty(arg) 
                    arg = arg{1};
                end
                if ischar(arg) && strcmp(arg,'copy')
                    return;
                end
            end
            obj.CondColTbl('init');
                                   
        end
        
    end
    
    
    methods
        
        % ---------------------------------------------------------------------------------
        function LoadProcStreamConfigFile(obj, filename)
            obj.procStream.LoadConfigFile(filename, class(obj));
        end        
        
                
        % ---------------------------------------------------------------------------------
        function SaveProcStreamConfigFile(obj, filename)
            obj.procStream.SaveConfigFile(filename, class(obj));
        end        
                
        
        % ---------------------------------------------------------------------------------
        function CreateProcStreamDefault(obj)
            obj.procStream.CreateDefault()
        end
        
        
        % ---------------------------------------------------------------------------------
        function procStream = GetProcStreamDefault(obj)
            procStream = obj.procStream.GetDefault(class(obj));
        end 
       
    end
    
    
    methods
        
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
            objnew.name = obj.name;
            objnew.type = obj.type;
            objnew.err = obj.err;
            objnew.CondNames = obj.CondNames;
            objnew.procStream.Copy(obj.procStream, obj.GetFilename);
        end
        
               
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and procResult) from
        % obj2 to obj
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2, conditional)
            if ~isempty(obj2.procStream)
                obj.procStream.Copy(obj2.procStream, obj.GetFilename);
            end
            if nargin==2 || strcmp(conditional, 'unconditional')
                obj.name = obj2.name;
                obj.type = obj2.type;
                obj.iGroup = obj2.iGroup;
                obj.iSubj = obj2.iSubj;
                obj.iRun = obj2.iRun;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function Reset(obj)
            obj.procStream.output.Reset(obj.GetFilename);
            delete([obj.path, obj.name, '*.txt']);
            delete([obj.path, obj.name, '*.mat']);
            delete([obj.path, 'tCCAfilter_*.txt'])
        end
        
        
        % ----------------------------------------------------------------------------------
        % 
        % ----------------------------------------------------------------------------------
        function options_s = parseSaveOptions(~, options)
            options_s = struct('derived',false, 'acquired',false);
            C = str2cell(options, {':',',','+',' '});
            
            for ii=1:length(C)
                if isproperty(options_s, C{ii})
                    eval( sprintf('options_s.%s = true;', C{ii}) );
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function InitParentAppFunc(obj)
            global maingui
            if ~isempty(maingui)
                obj.updateParentGui = maingui.Update;
            end
        end
        

        % ----------------------------------------------------------------------------------
        function SetIndexID(obj, iG, iS, iR)
            if nargin>1
                obj.iGroup = iG;
            end            
            if nargin>2
                obj.iSubj = iS;
            end
            if nargin>3
                obj.iRun = iR;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetProcFlag(obj)
            if obj.procStream.output.IsEmpty()
                return;
            end
            if isa(obj, 'GroupClass')
                obj.GroupsProcFlags(obj.iGroup, 1);
            elseif isa(obj, 'SubjClass')
                obj.SubjsProcFlags(obj.iGroup, obj.iSubj, 1);
            elseif isa(obj, 'RunClass')
                obj.RunsProcFlags(obj.iGroup, obj.iSubj, obj.iRun, 1);
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function idx = GetIndexID(obj)
            idx = [obj.iGroup, obj.iSubj, obj.iRun];
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsGroup(obj)
            if strcmp('group', obj.type)
                b = true;
            else
                b = false;
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = IsSubj(obj)
            if strcmp('subj', obj.type)
                b = true;
            else
                b = false;
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = IsRun(obj)
            if strcmp('run', obj.type)
                b = true;
            else
                b = false;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsSame(obj, iG, iS, iR)
            b = false;
            if isempty(obj)
                return;
            end
            if iG==obj.iGroup && iS==obj.iSubj && iR==obj.iRun
                b = true;
            end                
        end
                
    end
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for setting/getting TreeNode procStream output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
               
        % ----------------------------------------------------------------------------------
        function t = GetTHRF(obj, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            t = obj.procStream.output.GetTHRF(iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function d = GetRawData(~)            
            d = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function dod = GetDod(obj, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            dod = obj.procStream.output.GetDataTimeCourse('dod',iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dc = GetDc(obj, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            dc = obj.procStream.output.GetDataTimeCourse('dc',iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dodAvg = GetDodAvg(obj, condition, iBlk)
            if ~exist('condition','var') || isempty(condition)
                icond = 1:length(obj.GetConditions());
            elseif ischar(condition)
                icond = obj.GetConditionIdx(condition);
            else
                icond = condition;
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            dodAvg = obj.procStream.output.GetDodAvg('dodAvg', icond, iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dcAvg = GetDcAvg(obj, condition, iBlk)
            if ~exist('condition','var') || isempty(condition)
                icond = 1:length(obj.GetConditions());
            elseif ischar(condition)
                icond = obj.GetConditionIdx(condition);
            else
                icond = condition;
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            dcAvg = obj.procStream.output.GetDcAvg('dcAvg', icond, iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dodAvgStd = GetDodAvgStd(obj, condition, iBlk)
            if ~exist('condition','var') || isempty(condition)
                condition = 1:length(obj.GetConditions());
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            dodAvgStd = obj.procStream.output.GetDodAvg('dodAvgStd', condition, iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dcAvgStd = GetDcAvgStd(obj, condition, iBlk)
            if ~exist('condition','var') || isempty(condition)
                condition = 1:length(obj.GetConditions());
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            dcAvgStd = obj.procStream.output.GetDcAvg('dcAvgStd', condition, iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dodSum2 = GetDodSum2(obj, condition, iBlk)
            if ~exist('condition','var') || isempty(condition)
                condition = 1:length(obj.GetConditions());
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            dodSum2 = obj.procStream.output.GetDodSum2('dodSum2', condition, iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dcSum2 = GetDcSum2(obj, condition, iBlk)
            if ~exist('condition','var') || isempty(condition)
                condition = 1:length(obj.GetConditions());
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            dcSum2 = obj.procStream.output.GetDcSum2('dcSum2', condition, iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function nTrials = GetNtrials(obj, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            nTrials = obj.procStream.output.GetNtrials(iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function pValues = GetPvalues(obj, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = [];
            end
            pValues = obj.procStream.output.GetVar('pValues');
            if ~isempty(iBlk) && iBlk<=length(pValues)
                pValues = pValues{iBlk};
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for retrieving TreeNode params
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function s = GetStims(~, ~)
            s = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = obj.CondNames;
        end

        
        % ----------------------------------------------------------------------------------
        function idx = GetConditionIdx(obj, CondName)
            C = obj.GetConditions();
            idx = find(strcmp(C, CondName));
        end
        
        
        % ----------------------------------------------------------------------------------
        function varval = GetVar(obj, varname)
            varval = [];
            if isproperty(obj, varname)
                varval = eval( sprintf('obj.%s', varname) );
            end
            if isempty(varval)
                varval = obj.procStream.GetVar(varname);
            end
        end
        
               
        % ----------------------------------------------------------------------------------
        function AddStims(~, ~, ~)
            return;
        end        
        
        
        % ----------------------------------------------------------------------------------
        function DeleteStims(~, ~)
            return;
        end
        
        
        % ----------------------------------------------------------------------------------
        function ToggleStims(~, ~)
            return;
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimDuration(~, ~, ~)
            return;
        end
    
        
        % ----------------------------------------------------------------------------------
        function duration = GetStimDuration(~, ~)
            duration = [];            
        end
        
        
        % ----------------------------------------------------------------------------------
        function [tpts, duration, vals] = GetStimData(~, ~)
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
            msg2 = sprintf('Condition name is not valid. New name must be character string. Do you want to choose another name?');
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

            if ndims(y)==2 %#ok<*ISMAT>
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
            name = '';
            if isempty(obj)
                return;
            end
            name = obj.name;
        end
        
        
        % ----------------------------------------------------------------------------------
        function name = GetFileName(obj)
            name = '';
            if isempty(obj)
                return;
            end
            [~, fname, ext] = fileparts(obj.name);
            name = [fname, ext];
        end
        
        
        % ----------------------------------------------------------------------------------
        function d = GetDataTimeSeries(~, ~, ~)
            d = [];
        end

        
        % ----------------------------------------------------------------------------------
        function t = GetTime(~, ~)
            t = [];
        end

        
        % ----------------------------------------------------------------------------------
        function t = GetTimeCombined(~)
            t = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function t = GetTincAuto(~, ~)
            t = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function t = GetTincAutoCh(~, ~)
            t = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function t = GetTincMan(~, ~)
            t = [];
        end

        
        % ----------------------------------------------------------------------------------
        function SetTincMan(~, ~, ~, ~)
            
        end
               
    end
        
    
    methods
        
        % ----------------------------------------------------------------------------------
        function err = Load(obj)
            err = -1;
            if isempty(obj)
                return
            end
            err = obj.LoadSubBranch(); %#ok<*MCNPN>
            obj.procStream.Load(obj.GetFilename);
        end
        
        
        % ----------------------------------------------------------------------------------
        function FreeMemory(obj)
            if isempty(obj)
                return
            end
            obj.FreeMemorySubBranch();
            obj.procStream.FreeMemory(obj.GetFilename);
        end
        
        
        % ----------------------------------------------------------------------------------
        function tblcells = ExportMeanHRF(~, ~, ~)
            tblcells = {};
        end
        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            if isempty(obj)
                return;
            end            
            nbytes = obj.procStream.MemoryRequired();
        end
        
        
        % ----------------------------------------------------------------------------------
        function filename = GetFilename(obj)
            filename = '';
            if isempty(obj)
                return;
            end
            filename = obj.SaveMemorySpace(obj.name);
        end
        
                        
    end

    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Static class methods implementing runs, subjs, groups processing 
    % flags for quickly calculating required memory and color table
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
   
        
        % --------------------------------------------------------------------------------
        function out = SaveMemorySpace(arg)
            persistent v;
            out = [];
                        
            % If first time we call SaveMemorySpace is with a filename argument, that is arg is a char string 
            % rather than a numeric, then we want to set v to true to make sure not to load everything into memory 
            % by default. Later in the Homer3 initalization if we detect our data set is small, we can reverse that 
            % and set the SaveMemorySpace to false to improve responce time. 
            if isempty(v)
                v = true;
            end
            
            if islogical(arg) || isnumeric(arg)
                v = arg;
                out = v;
            elseif ischar(arg)                
                if v
                    out = arg;
                else
                    out = '';
                end
            end
        end
   
                
    end
    
end

