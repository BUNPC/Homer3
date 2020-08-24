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
        
    properties (Access=private)
        filename
    end
    
    
    methods
        
        % ---------------------------------------------------------------------------
        function obj = ProcResultClass()
            obj.Initialize();
            obj.filename = '';
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
        function tHRF_common = GeneratetHRFCommon(obj, tHRF_common)
            nDataBlks = obj.GetDataBlocksNum();
            if isempty(tHRF_common)
                tHRF_common = cell(nDataBlks,1);
            end
            
            % Find smallest tHRF among the runs. We should make this the common one.
            for iBlk = 1:nDataBlks
                if isempty(tHRF_common{iBlk})
                    tHRF_common{iBlk} = obj.GetTHRF(iBlk);
                elseif length(obj.GetTHRF(iBlk)) < length(tHRF_common{iBlk})
                    tHRF_common{iBlk} = obj.GetTHRF(iBlk);
                end
            end
        end
        
        
        
        % ---------------------------------------------------------------------------
        function SettHRFCommon(obj, tHRF_common, name, type)
            for iBlk = 1:length(tHRF_common)
                if size(tHRF_common{iBlk},2)<size(tHRF_common{iBlk},1)
                    tHRF_common{iBlk} = tHRF_common{iBlk}';
                end
                t = obj.GetTHRF(iBlk);
                if isempty(t)
                    return;
                end
                n = length(tHRF_common{iBlk});
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
                obj.tHRF = tHRF_common{iBlk};
            end
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
        
    end
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function SetFilename(obj, filename)
            if isempty(filename)
                return;
            end
            [pname, fname] = fileparts(filename);
            if isempty(pname)
                pname = '.';
            end
            obj.filename = [pname, '/', fname, '.mat'];
        end
        
        
        % ----------------------------------------------------------------------------------
        function Save(obj, vars, filename, options)
            % options possible values:  
            %    freememory
            %    keepinmemory
            
            if ~exist('options', 'var') || isempty(options)
                options = 'keepinmemory';
            end
            
            obj.SetFilename(filename)
            
            output = obj; %#ok<NASGU>
            props = propnames(vars);
            for ii=1:length(props)
                if eval( sprintf('isproperty(output, ''%s'');', props{ii}) )
                    eval( sprintf('output.%s = vars.%s;', props{ii}, props{ii}) );
                else
                    eval( sprintf('output.misc.%s = vars.%s;', props{ii}, props{ii}) );
                end
            end
            
            % If file name is not an empty string, save results to file and free memory
            % to save memory space
            if ~isempty(obj.filename)
                save(obj.filename, '-mat', 'output');
                
                % Free memory for this object
                if ~isempty(findstr('freememory', options)) %#ok<FSTR>
                    obj.FreeMemory();
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function err = Load(obj, filename)
            err = 0;
            obj.SetFilename(filename)
            if isempty(obj.filename)
                return;
            end

            % If object is not empty it means we already have loaded data. No
            % need to waste time loading it from file.
            if ~obj.IsEmpty()
                return;
            end
            
            % Error check file
            if ~exist(obj.filename,'file')
                return
            end
            
            % If file name is not an empty string, load proc stream output from file
            load(obj.filename, '-mat');
            
            % Error check output
            if ~exist('output','var')
                return
            end
            if ~isa(output,'ProcResultClass')
                return
            end
            obj.Copy(output);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function FreeMemory(obj, filename)            
            if ~exist('filename','var')
                filename = '';
            end
            
            % If file name is not passed and is not already set within this
            % object it means we are not saving output to seperate files
            % and therefore not freeing memory for the processed output. 
            % Therefore we simply return to avoid re-initialzing the object
            if isempty(obj.filename) && isempty(filename)
                return;
            end            
            
            % Free memory for this object
            obj.Initialize();
        end
        
        
        % ----------------------------------------------------------------------------------
        function Reset(obj, filename)
            obj.Initialize();

            obj.SetFilename(filename)
            if isempty(obj.filename)
                return;
            end
            
            % Check that data file associated with this processing element exists
            if exist(obj.filename,'file')
                % Delete file containing the actual datas
                delete(obj.filename);
            end
            

            % Check that exported data file associated with this processing element exists
            [pname, fname] = fileparts(obj.filename);
            if exist([pname, '/', fname, '_HRF.txt'], 'file')
                delete([pname, '/', fname, '_HRF.txt']);
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
        function yavg = GetDodAvg(obj, type, condition, iBlk) %#ok<*INUSL>
            yavg = [];
            
            % Check type argument
            if ~exist('type','var') || isempty(type)
                type = 'dodAvg';
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1; %#ok<NASGU>
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
                iBlk = 1; %#ok<NASGU>
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
            options = ''; %#ok<NASGU>
            
            % Check type argument
            if ~exist('type','var') || isempty(type)
                type = 'dcAvg';
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1; %#ok<NASGU>
            end
            
            if ~ischar(type)
                return;
            end
            
            if isa(eval(sprintf('obj.%s', type)), 'DataClass')
                if isempty(eval(sprintf('obj.%s', type)))
                    return;
                end
                if strcmp(type, 'dc') || strcmp(type, 'dcAvg') || strcmp(type, 'dodAvg')
                    options = 'reshape'; %#ok<NASGU>
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
                if isnumeric(obj.dcAvg)
                    n = 1;
                else
                    n = length(obj.dcAvg);
                end
            elseif ~isempty(obj.dodAvg)
                if isnumeric(obj.dodAvg)
                    n = 1;
                else
                    n = length(obj.dodAvg);
                end
            elseif ~isempty(obj.dc)
                if isnumeric(obj.dc)
                    n = 1;
                else
                    n = length(obj.dc);
                end
            elseif ~isempty(obj.dod)
                if isnumeric(obj.dod)
                    n = 1;
                else
                    n = length(obj.dod);
                end
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2, filename)
          
            if ~isa(obj, 'ProcResultClass')
                return;
            end
            if ~exist('filename', 'var')
                filename = '';
            end            
            obj.SetFilename(filename)
            
            % If file name is set and exists then load data from file
            if ~isempty(filename) && exist(obj.filename, 'file')
            
                obj.FreeMemory(filename);
                
            % If file name is set but does not exist then we should NOT
            % copy from obj2 but instead save it to a file
            elseif ~isempty(filename) && ~exist(obj.filename, 'file')
                
                obj.Save(obj2, filename, 'freememory');
                
            elseif isempty(filename)
            
	            obj.dod = obj2.dod;
	            obj.dc = obj2.dc;
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
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b = false;
            if isempty(obj)
                b = true;
                return
            end
            if ~isempty(obj.dod)
                return
            end
            if ~isempty(obj.dc)
                return
            end
            if ~isempty(obj.dodAvg)
                return
            end
            if ~isempty(obj.dcAvg)
                return
            end
            if ~isempty(obj.dodAvgStd)
                return
            end
            if ~isempty(obj.dcAvgStd)
                return
            end
            if ~isempty(obj.dodSum2)
                return
            end
            if ~isempty(obj.dcSum2)
                return
            end
            if ~isempty(obj.tHRF)
                return
            end
            if ~isempty(obj.nTrials)
                return
            end
            if ~isempty(obj.grpAvgPass)
                return
            end
            if ~isempty(obj.misc)
                return
            end
            b = true;
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
                if ~isempty(fieldstr)
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
                h = waitbar_improved(0, sprintf('Generating table cells for export ... 0%% complete.'));
                % Data rows
                for iCond = 1:length(CondNames)
                    waitbar_improved(iCond/length(CondNames), h, sprintf('Generating table cells for export ... %d%% complete.', uint32(100 * iCond/length(CondNames))));
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
                close(h);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function tblcells = GenerateTableCells_HRF(obj, CondNames, iBlk)
            if nargin<3
                iBlk = 1;
            end
            tblcells = TableCell.empty();
            if isa(obj.dcAvg, 'DataClass')
                dataTimeSeries  = obj.dcAvg(iBlk).GetDataTimeSeries();
                time            = obj.dcAvg(iBlk).GetTime();
                measList        = obj.dcAvg(iBlk).measurementList;
                
                % Header: row containing stim condition name
                tblcells(2,1) = TableCell('', 12);      % Make space for time column
                for iCh = 1:length(measList)
                    tblcells(1,iCh+1) = TableCell(sprintf('%s', CondNames{measList(iCh).dataTypeIndex}), 12);
                end
                
                % Header: row containing time label followed by Hb type 
                tblcells(2,1) = TableCell('time', 12);      
                for iCh = 1:length(measList)
                    tblcells(2,iCh+1) = TableCell(sprintf('%s,%d,%d', measList(iCh).dataTypeLabel, measList(iCh).sourceIndex, measList(iCh).detectorIndex), 12);
                end
                
                % Data rows
                h = waitbar_improved(0, sprintf('Generating table cells for export ... 0%% complete.'));
                for t = 1:size(dataTimeSeries,1)
                    waitbar_improved(t/size(dataTimeSeries,1), h, sprintf('Generating table cells for export ... %d%% complete.', uint32(100 * t/size(dataTimeSeries,1))));
                    
                    % time 
                    cname = sprintf('%s%0.3f', blanks(time(t)>=0), time(t));
                    tblcells(t+2,1) = TableCell(cname, 12);
                    
                    % data
                    for iCh = 1:length(measList)
                        if isnan(dataTimeSeries(t,iCh))
                            cname  = 'NaN';
                        else
                            cname = sprintf('%s%0.5e', blanks(dataTimeSeries(t,iCh)>=0), dataTimeSeries(t,iCh));
                        end
                        tblcells(t+2,iCh+1) = TableCell(cname, 12);
                    end
                end
                close(h);
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

