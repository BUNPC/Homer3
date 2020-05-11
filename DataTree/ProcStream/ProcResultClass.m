classdef ProcResultClass < handle
    
    properties
        dod;
        dc;
        dodAvg;
        dcAvg;
        dodAvgStd;
        dcAvgStd;
        dodSum2;
        dcSum2;
        tHRF;
        nTrials;
        ch;
        grpAvgPass;
        misc;
    end
    
    methods
        
        % ---------------------------------------------------------------------------
        function obj = ProcResultClass()
            obj.Initialize();
        end
        
        % ---------------------------------------------------------------------------
        function Initialize(obj)
            obj.dod = [];
            obj.dc = [];
            obj.dodAvg = [];
            obj.dcAvg = [];
            obj.dodAvgStd = [];
            obj.dcAvgStd = [];
            obj.dodSum2 = [];
            obj.dcSum2 = [];
            obj.tHRF = [];
            obj.nTrials = {};
            obj.grpAvgPass = [];
            obj.misc = [];
        end
        
        
        % ---------------------------------------------------------------------------
        function SettHRFCommon(obj, tHRF_common, name, type, iBlk)
            if size(tHRF_common,2)<size(tHRF_common,1)
                tHRF_common = tHRF_common';
            end
            t = obj.GetTHRF(iBlk);
            if isempty(t)
                return;
            end
            n = length(tHRF_common);
            m = length(t);
            d = n-m;
            if d<0
                fprintf('WARNING: tHRF for %s %s is larger than the common tHRF.\n',type, name);
                if ~isempty(obj.dodAvg)
                    if isa(obj.dodAvg, 'DataClass')
                        obj.dodAvg(iBlk).TruncateTpts(abs(d));
                    else
                        obj.dodAvg(n+1:m,:,:) = [];
                    end
                end
                if ~isempty(obj.dodAvgStd)
                    if isa(obj.dodAvgStd, 'DataClass')
                        obj.dodAvgStd(iBlk).TruncateTpts(abs(d));
                    else
                        obj.dodAvgStd(n+1:m,:,:) = [];
                    end
                end
                if ~isempty(obj.dodSum2)
                    if isa(obj.dodSum2, 'DataClass')
                        obj.dodSum2(iBlk).TruncateTpts(abs(d));
                    else
                        obj.dodSum2(n+1:m,:,:) = [];
                    end
                end
                if ~isempty(obj.dcAvg)
                    if isa(obj.dcAvg, 'DataClass')
                        obj.dcAvg(iBlk).TruncateTpts(abs(d));
                    else
                        obj.dcAvg(n+1:m,:,:,:) = [];
                    end
                end
                if ~isempty(obj.dcAvgStd)
                    if isa(obj.dcAvgStd, 'DataClass')
                        obj.dcAvgStd(iBlk).TruncateTpts(abs(d));
                    else
                        obj.dcAvgStd(n+1:m,:,:) = [];
                    end
                end
                if ~isempty(obj.dcSum2)
                    if isa(obj.dcSum2, 'DataClass')
                        obj.dcSum2(iBlk).TruncateTpts(abs(d));
                    else
                        obj.dcSum2(n+1:m,:,:,:) = [];
                    end
                end
            end
            obj.tHRF = tHRF_common;
        end
        
        
        % ----------------------------------------------------------------------------------
        function var = GetVar(obj, varname, iBlk)
            var = [];
            if exist('iBlk','var') && isempty(iBlk)
                iBlk=1;
            end
            if isproperty(obj, varname)
                eval(sprintf('var = obj.%s;', varname));
            elseif isproperty(obj.misc, varname)
                eval(sprintf('var = obj.misc.%s;', varname));
            end
            if ~isempty(var) && exist('iBlk','var')
                if iscell(var)
                    var = var{iBlk};
                else
                    var = var(iBlk);
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function Flush(obj)
            obj.Initialize();
        end
        
        
        % ----------------------------------------------------------------------------------
        function Print(obj, indent)
            if ~exist('indent', 'var')
                indent = 6;
            end
            fprintf('%sOutput:\n', blanks(indent));
            fprintf('%snTrials:\n', blanks(indent+4));
            pretty_print_matrix(obj.nTrials, indent+4, sprintf('%%d'))
        end
        
    end
    
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function SetTHRF(obj, t)
            obj.tHRF = t;
        end
        
        
        % ----------------------------------------------------------------------------------
        function t = GetTHRF(obj, iBlk)
            t = [];
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            
            if ~isempty(obj.dcAvg) && isa(obj.dcAvg, 'DataClass')
                t = obj.dcAvg(iBlk).GetT;
            elseif ~isempty(obj.dodAvg) && isa(obj.dodAvg, 'DataClass')
                t = obj.dodAvg(iBlk).GetT;
            else
                t = obj.tHRF;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetDodAvg(obj, val)
            obj.dodAvg = val;
        end
        
        % ----------------------------------------------------------------------------------
        function SetDcAvg(obj, val)
            obj.dcAvg = val;
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetDodAvgStd(obj, val)
            obj.dodAvgStd = val;
        end
        
        % ----------------------------------------------------------------------------------
        function SetDcAvgStd(obj, val)
            obj.dcAvgStd = val;
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetDodSum2(obj, val)
            obj.dodSum2 = val;
        end
        
        % ----------------------------------------------------------------------------------
        function SetDcSum2(obj, val)
            obj.dcSum2 = val;
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetDod(obj, val)
            obj.dod = val;
        end
        
        % ----------------------------------------------------------------------------------
        function SetDc(obj, val)
            obj.dc = val;
        end
        
        
        % ----------------------------------------------------------------------------------
        function yavg = GetDodAvg(obj, type, condition, iBlk)
            yavg = [];
            
            % Check type argument
            if ~exist('type','var') || isempty(type)
                type = 'dodAvg';
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            
            if ~ischar(type)
                return;
            end
            
            % Get data matrix
            if isa(eval(sprintf('obj.%s', type)), 'DataClass')
                if isempty(eval(sprintf('obj.%s', type)))
                    return;
                end
                yavg = eval(sprintf('obj.%s(iBlk).GetDataTimeSeries(''reshape'')', type));
            else
                yavg = eval(sprintf('obj.%s', type));
            end
            
            % Get condition
            if ~exist('condition','var')
                condition = 1:size(yavg,3);
            end
            if isempty(condition)
                yavg = [];
            end
            if isempty(yavg)
                return;
            end
            if max(condition)>size(yavg,3)
                yavg = [];
                return;
            end
            if all(isnan(yavg(:,:,condition)))
                yavg = [];
                return;
            end
            yavg = yavg(:,:,condition);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function yavg = GetDcAvg(obj, type, condition, iBlk)
            yavg = [];
            
            % Check type argument
            if ~exist('type','var') || isempty(type)
                type = 'dcAvg';
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            
            if ~ischar(type)
                return;
            end
            
            % Get data matrix
            if isa(eval(sprintf('obj.%s', type)), 'DataClass')
                if isempty(eval(sprintf('obj.%s', type)))
                    return;
                end
                yavg = eval(sprintf('obj.%s(iBlk).GetDataTimeSeries(''reshape'')', type));
            else
                yavg = eval(sprintf('obj.%s', type));
            end
            
            % Get condition
            if ~exist('condition','var')
                condition = 1:size(yavg,4);
            end
            if isempty(condition)
                yavg = [];
            end
            if isempty(yavg)
                return;
            end
            if max(condition)>size(yavg,4)
                yavg = [];
                return;
            end
            if all(isnan(yavg(:,:,:,condition)))
                yavg = [];
                return;
            end
            yavg = yavg(:,:,:,condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function y = GetDataTimeCourse(obj, type, iBlk)
            y = [];
            options = '';
            
            % Check type argument
            if ~exist('type','var') || isempty(type)
                type = 'dcAvg';
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            
            if ~ischar(type)
                return;
            end
            
            if isa(eval(sprintf('obj.%s', type)), 'DataClass')
                if isempty(eval(sprintf('obj.%s', type)))
                    return;
                end
                if strcmp(type, 'dc') || strcmp(type, 'dcAvg') || strcmp(type, 'dodAvg')
                    options = 'reshape';
                end
                y = eval(sprintf('obj.%s(iBlk).GetDataTimeSeries(options)', type));
            else
                y = eval(sprintf('obj.%s', type));
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetNtrials(obj, val)
            obj.nTrials = val;
        end
        
        
        % ----------------------------------------------------------------------------------
        function nTrials = GetNtrials(obj, iBlk)
            nTrials = {};
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            if isempty(obj.nTrials)
                return;
            end
            if iscell(obj.nTrials)
                nTrials = obj.nTrials{iBlk};
            else
                nTrials = obj.nTrials;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function s = GetStims(obj, t)
            if nargin==1
                t = [];
            end
            s = obj.GetVar('s');
            if isempty(s)
                if isempty(obj.dod) || ~isa(obj.dod, 'DataClass')
                    return;
                end
                stim = obj.GetVar('stim');
                if isempty(stim)
                    return;
                end
                snirf = SnirfClass(obj.dod, stim);
                s = snirf.GetStims(t);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function val = GetTincAuto(obj, iBlk)
            val = {};
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            if isproperty(obj.misc, 'tIncAuto')
                if iscell(obj.misc.tIncAuto)
                    val = obj.misc.tIncAuto{iBlk};
                else
                    val = obj.misc.tIncAuto;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function val = GetTincAutoCh(obj, iBlk)
            val = {};
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            if isproperty(obj.misc, 'tIncAutoCh')
                if iscell(obj.misc.tIncAutoCh)
                    val = obj.misc.tIncAutoCh{iBlk};
                else
                    val = obj.misc.tIncAutoCh;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function mlActAuto = GetMeasListActAuto(obj, iBlk)
            mlActAuto = {};
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk=1;
            end
            mlActAutoAll = obj.GetVar('mlActAuto');
            mlActAuto = mlActAutoAll{iBlk};
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(obj)
            n = 0;
            if ~isempty(obj.dcAvg)
                n = length(obj.dcAvg);
            elseif ~isempty(obj.dodAvg)
                n = length(obj.dodAvg);
            elseif ~isempty(obj.dc)
                n = length(obj.dc);
            elseif ~isempty(obj.dod)
                n = length(obj.dod);
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2, option)
            if ~isa(obj, 'ProcResultClass')
                return;
            end
            if nargin==2
                option = '';
            end
            
            % Ok to shallow copy since ProcResult objects are read only
            % Also we don't want to transfer space hogging time course
            % data dc and dod
            
            if ~strcmp(option, 'spacesaver')
                obj.dod = obj2.dod;
                obj.dc = obj2.dc;
            end
            obj.dodAvg = obj2.dodAvg;
            obj.dcAvg = obj2.dcAvg;
            obj.dodAvgStd = obj2.dodAvgStd;
            obj.dcAvgStd = obj2.dcAvgStd;
            obj.dodSum2 = obj2.dodSum2;
            obj.dcSum2 = obj2.dcSum2;
            obj.tHRF = obj2.tHRF;
            if iscell(obj2.nTrials)
                obj.nTrials = obj2.nTrials;
            else
                obj.nTrials = {obj2.nTrials};
            end
            obj.ch = obj2.ch;
            obj.misc = obj2.misc;
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = HaveBlockAvgOutput(obj)
            b=0;
            if isempty(obj)
                return;
            end
            if ~isempty(obj.dcAvg)
                b=1;
            end
            if ~isempty(obj.dodAvg)
                b=1;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = HaveTimeCourseOutput(obj)
            b=0;
            if isempty(obj)
                return;
            end
            if ~isempty(obj.dc)
                b=1;
            end
            if ~isempty(obj.dod)
                b=1;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b=0;
            if obj.HaveTimeCourseOutput()
                return;
            end
            if obj.HaveBlockAvgOutput()
                return;
            end
            b=1;
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetNumChForOneCondition(obj, iBlk)
            n = 0;
            if nargin<2
                iBlk = 1;
            end
            if isa(obj.dcAvg, 'DataClass')
                n = length(obj.dcAvg(iBlk).GetMeasurementListIdxs(1));
            end            
        end

        
        % ----------------------------------------------------------------------------------        
        function nbytes = MemoryRequired(obj)
            fields = properties(obj);
            nbytes = zeros(length(fields),1);
            for ii = 1:length(fields)
                fieldstr = sprintf('obj.%s', fields{ii});
                if ~eval('isempty(fieldstr)')
                    if isa(eval(fieldstr), 'DataClass')
                        nbytes(ii) =  eval(sprintf('%s.MemoryRequired();', fieldstr));
                    else
                        nbytes(ii) =  eval(sprintf('sizeof(%s);', fieldstr));
                    end
                end
            end
            nbytes = sum(nbytes);
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Export related methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods        
        
        % ----------------------------------------------------------------------------------
        function [tblcells, maxwidth] = GenerateTableCellsHeader_MeanHRF(obj, iBlk)
            if nargin<5
                iBlk = 1;
            end
            tblcells = TableCell.empty();
            maxwidth = length('HRF HbX,999,999');
            if isa(obj.dcAvg, 'DataClass')
                measList = obj.dcAvg(iBlk).measurementList;
                measListIdxs = obj.dcAvg(iBlk).GetMeasurementListIdxs(1);
                for iCh = measListIdxs
                    tblcells(1,iCh) = TableCell(sprintf('%s,%d,%d', measList(iCh).dataTypeLabel, measList(iCh).sourceIndex, measList(iCh).detectorIndex), maxwidth);
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function tblcells = GenerateTableCells_MeanHRF(obj, name, CondNames, trange, width, iBlk)
            if ~exist('trange','var') || isempty(trange) || all(trange==0)
                trange = [obj.tHRF(1), obj.tHRF(end)];
            end
            if ~exist('width','var') || isempty(width)
                width = 12;
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            tblcells = TableCell.empty();
            if isa(obj.dcAvg, 'DataClass')
                dataTimeSeries = obj.dcAvg(iBlk).GetDataTimeSeries('');                
                
                % Data rows
                for iCond = 1:length(CondNames)
                    measListIdxs = obj.dcAvg(iBlk).GetMeasurementListIdxs(iCond);
                    for iCh = measListIdxs
                        iT = (obj.dcAvg.time >= trange(1)) & (obj.dcAvg.time <= trange(2));
                        meanData = mean(dataTimeSeries(iT,iCh));
                        if isnan(meanData)
                            cname  = 'N/A';
                        else
                            cname = sprintf('%s%0.5e', blanks(meanData>=0), meanData);
                        end                        
                        tblcells(iCond, mod(iCh-1, length(measListIdxs))+1) = TableCell(cname, width);
                    end
                end
            end
        end

            
        % ----------------------------------------------------------------------------------
        function tblcells = GenerateTableCells_HRF(obj, CondNames, iBlk)
            if nargin<3
                iBlk = 1;
            end
            tblcells = TableCell.empty();
            if isa(obj.dcAvg, 'DataClass')
                dataTimeSeries = obj.dcAvg(iBlk).GetDataTimeSeries('');
                measList = obj.dcAvg(iBlk).measurementList;
                
                % Header: stim condition name row
                for iCh = 1:length(measList)
                    tblcells(1,iCh) = TableCell(sprintf('%s', CondNames{measList(iCh).dataTypeIndex}), 12);
                end
                
                % Header: Hb type row
                for iCh = 1:length(measList)
                    tblcells(2,iCh) = TableCell(sprintf('%s,%d,%d', measList(iCh).dataTypeLabel, measList(iCh).sourceIndex, measList(iCh).detectorIndex), 12);
                end
                
                % Data rows
                for t = 1:size(dataTimeSeries,1)
                    for iCh = 1:length(measList)
                        if isnan(dataTimeSeries(t,iCh))
                            cname  = 'NaN';
                        else
                            cname = sprintf('%s%0.5e', blanks(dataTimeSeries(t,iCh)>=0), dataTimeSeries(t,iCh));
                        end
                        tblcells(t+2,iCh) = TableCell(cname, 12);
                    end
                end
            else
                
            end
        end
                
        
        % ----------------------------------------------------------------------------------
        function tbl = ExportHRF(obj, filename, CondNames, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            
            % Generate table cells
            tblcells = obj.GenerateTableCells_HRF(CondNames, iBlk);
            
            % Create table export data to file
            tbl = ExportTable(filename, 'HRF', tblcells);
        end
        
    end
    
end

