classdef TreeNodeClass < handle
    
    properties % (Access = private)        
        name;
        type;
        iGroup;
        iSubj;
        iRun;
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
            obj.iGroup = 0;
            obj.iSubj = 0;
            obj.iRun = 0;
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
                if iscell(arg) && ~isempty(arg) 
                    arg = arg{1};
                end
                if ischar(arg) && strcmp(arg,'copy')
                    return;
                end
            end
            obj.CondColTbl('init');
            obj.CondNamesAll('init');
        end
        
    end
    
    
    methods
        
        % ---------------------------------------------------------------------------------
        function LoadProcInputConfigFile(obj, filename, reg)
            obj.procStream.input.LoadConfigFile(filename, reg, class(obj));
        end        
        
                
        % ---------------------------------------------------------------------------------
        function SaveProcInputConfigFile(obj, filename)
            obj.procStream.input.SaveConfigFile(filename, class(obj));
        end        
                
        
        % ---------------------------------------------------------------------------------
        function CreateProcInputDefault(obj, reg)
            obj.procStream.input.CreateDefault(reg)
        end
        
        
        % ---------------------------------------------------------------------------------
        function procInput = GetProcInputDefault(obj)
            procInput = obj.procStream.input.GetDefault(class(obj));
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
            objnew.ch = obj.ch;
            objnew.CondNames = obj.CondNames;
            objnew.CondName2Group = obj.CondName2Group;
            objnew.procStream.input.Copy(obj.procStream.input);
        end
        
               
        % ----------------------------------------------------------------------------------
        % Copy processing params (procInut and procResult) from
        % obj2 to obj
        % ----------------------------------------------------------------------------------
        function copyProcParamsFieldByField(obj, obj2)
            % procInput
            if ~isempty(obj2.procStream.input)
                obj.procStream.input.Copy(obj2.procStream.input);
            end
            
            % procResult
            if ~isempty(obj2.procStream.output)
                obj.procStream.output.Copy(obj2.procStream.output);
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
        
    end
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for setting/getting TreeNode procStream output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
               
        % ----------------------------------------------------------------------------------
        function t = GetTHRF(obj)
            t = obj.procStream.output.GetTHRF();
        end
        
        
        % ----------------------------------------------------------------------------------
        function dod = GetDod(obj)
            dod = obj.procStream.output.GetDataTimeCourse('dod');
        end
        
        
        % ----------------------------------------------------------------------------------
        function dc = GetDc(obj)
            dc = obj.procStream.output.GetDataTimeCourse('dc');
        end
        
        
        % ----------------------------------------------------------------------------------
        function dodAvg = GetDodAvg(obj, condition)
            if ~exist('condition','var')
                condition = 1:length(obj.GetConditions());
            end
            dodAvg = obj.procStream.output.GetDodAvg('dodAvg', condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dcAvg = GetDcAvg(obj, condition)
            if ~exist('condition','var')
                condition = 1:length(obj.GetConditions());
            end
            dcAvg = obj.procStream.output.GetDcAvg('dcAvg', condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dodAvgStd = GetDodAvgStd(obj, condition)
            if ~exist('condition','var')
                condition = 1:length(obj.GetConditions());
            end
            dodAvgStd = obj.procStream.output.GetDodAvg('dodAvgStd', condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dcAvgStd = GetDcAvgStd(obj, condition)
            if ~exist('condition','var')
                condition = 1:length(obj.GetConditions());
            end
            dcAvgStd = obj.procStream.output.GetDcAvg('dcAvgStd', condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dodSum2 = GetDodSum2(obj, condition)
            if ~exist('condition','var')
                condition = 1:length(obj.GetConditions());
            end
            dodSum2 = obj.procStream.output.GetDodSum2('dodSum2', condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function dcSum2 = GetDcSum2(obj, condition)
            if ~exist('condition','var')
                condition = 1:length(obj.GetConditions());
            end
            dcSum2 = obj.procStream.output.GetDcSum2('dcSum2', condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function nTrials = GetNtrials(obj)
            nTrials = obj.procStream.output.GetNtrials();
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for retrieving TreeNode params
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = obj.CondNames;
        end

        % ----------------------------------------------------------------------------------
        function found = FindVar(obj, varname)
            found = false;
            if isproperty(obj, varname)
                found = true;
            end
        end
        
               
        % ----------------------------------------------------------------------------------
        function varval = GetVar(obj, varname)
            varval = [];
            if isproperty(obj, varname)
                varval = eval( sprintf('obj.%s', varname) );
            end
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
        
        % ----------------------------------------------------------------------------------
        function d = GetDataMatrix(obj)
            d = [];
        end
        
        % ----------------------------------------------------------------------------------
        function t = GetTime(obj)
            t = [];
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