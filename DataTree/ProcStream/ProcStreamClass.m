classdef ProcStreamClass < handle
    
    properties
        fcalls;                  % Array of FuncCallClass objects representing function call chain i.e. processing stream
        fcallsIdxs;
        reg; 
        input;
        output;
        config;
    end
    
    properties (Access = private)
        datatypes;
    end
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = ProcStreamClass(acquired)
            global cfg
            
            cfg = InitConfig(cfg);           
            
            if nargin<1
                acquired=[];
            end
            obj.fcalls = FuncCallClass().empty();
            obj.fcallsIdxs = [];
            obj.config = struct('procStreamCfgFile','', 'defaultProcStream','','suffix','');
            obj.config.procStreamCfgFile    = cfg.GetValue('Processing Stream Config File');
            obj.config.regressionTestActive = cfg.GetValue('Regression Test Active');
            
            obj.InitDataTypes();
            
            % By the time this class constructor is called we should already have a saved registry 
            % to load. (Defintiely would not want to be generating the registry for each instance of this class!!)
            obj.reg = RegistriesClass();
            
            obj.input = ProcInputClass(acquired);
            obj.output = ProcResultClass();
            
            if nargin==0
                return;
            end
            obj.CreateDefault();
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2, filename)
            if isempty(obj.config.procStreamCfgFile)
                return;
            end
            if ~isa(obj, 'ProcStreamClass')
                return;
            end
            if ~exist('filename', 'var')
                filename = '';
            end
            
            if isempty(obj)
                obj = ProcStreamClass();
            end
            
            kk=1;
            for ii = 1:length(obj2.fcalls)                
                % If registry is empty, then add fcall entries unconditionally.
                % Otherwise only include ONLY those user function calls that exist in the registry.
                if obj.reg.IsEmpty() 
                    obj.fcalls(kk) = FuncCallClass(obj2.fcalls(ii), obj.reg);
                    kk = kk+1;
                elseif ~isempty(obj.reg.GetUsageName(obj2.fcalls(ii)))
                    obj.fcalls(kk) = FuncCallClass(obj2.fcalls(ii), obj.reg);
                    kk = kk+1;
                else
                    fprintf('Entry \"%s\" not found in registry ...\n', obj2.fcalls(ii).GetName())
                    fprintf('  Searching registry for equivalent or similar entry\n')
                    temp = obj.reg.FindClosestMatch(obj2.fcalls(ii));
                    if ~isempty(temp)
                        fprintf('  Found similar entry: %s\n', temp.encodedStr);
                        obj.fcalls(kk) = FuncCallClass(temp, obj.reg);
                        kk = kk+1;
                    else
                        fprintf('  Found no similar entries. Discarding %s\n', obj2.fcalls(ii).GetName())
                    end
                end            
            end
            
            % Delete any fcalls entries not ovewritten by the copy process
            if ~isempty(obj.fcalls)
                obj.fcalls(kk+1:end) = [];
            end
            
            obj.input.Copy(obj2.input);
            obj.output.Copy(obj2.output, filename);
        end
        
        
        % --------------------------------------------------------------
        function CopyStims(obj, obj2)
            if isa(obj2, 'ProcStreamClass')
                obj.input.CopyStims(obj2.input);
            else
                obj.input.CopyStims(obj2);
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function CopyFcalls(obj, obj2)
            if ~isa(obj, 'ProcStreamClass')
                return;
            end
            if obj == obj2
                return;
            end            
            delete(obj.fcalls);
            obj.fcalls = FuncCallClass().empty();
            for ii=1:length(obj2.fcalls)
                obj.fcalls(ii) = FuncCallClass();
                obj.fcalls(ii).Copy(obj2.fcalls(ii), obj.reg);
            end
        end
        
        

        % ----------------------------------------------------------------------------------
        function B = isequal(obj, obj2)
            B = false;
            if isa(obj2, 'ProcStreamClass')
                % Compare in both direction obj -> obj2  AND  obj2 -> obj
                for ii = 1:length(obj.fcalls)
                    if ii>length(obj2.fcalls)
                        return
                    end
                    if obj.fcalls(ii) ~= obj2.fcalls(ii)
                        return;
                    end
                end
                for ii = 1:length(obj2.fcalls)
                    if ii>length(obj.fcalls)
                        return
                    end
                    if obj.fcalls(ii) ~= obj2.fcalls(ii)
                        return;
                    end
                end
            elseif isstruct(obj2)
                if ~isproperty(obj2, 'procFunc')
                    return;
                end
                if ~isproperty(obj2.procFunc, 'funcName')
                    return;
                end
                if ~isproperty(obj2.procFunc, 'funcArgOut')
                    return;
                end
                if ~isproperty(obj2.procFunc, 'funcArgIn')
                    return;
                end
                if ~isproperty(obj2.procFunc, 'funcParam')
                    return;
                end
                if ~isproperty(obj2.procFunc, 'funcParamFormat')
                    return;
                end
                if ~isproperty(obj2.procFunc, 'funcParamVal')
                    return;
                end
                if length(obj.fcalls) ~= length(obj2.procFunc.funcName)
                    return;
                end
                
                % Compare in both direction obj -> obj2  AND  obj2 -> obj
                for ii = 1:length(obj.fcalls)
                    obj3.funcName        = obj2.procFunc.funcName{ii};
                    obj3.funcNameUI      = obj2.procFunc.funcNameUI{ii};
                    obj3.funcArgOut      = obj2.procFunc.funcArgOut{ii};
                    obj3.funcArgIn       = obj2.procFunc.funcArgIn{ii};
                    obj3.nFuncParam      = obj2.procFunc.nFuncParam(ii);
                    obj3.funcParam       = obj2.procFunc.funcParam{ii};
                    obj3.funcParamFormat = obj2.procFunc.funcParamFormat{ii};
                    obj3.funcParamVal    = obj2.procFunc.funcParamVal{ii};
                    B = obj.fcalls(ii) == obj3;
                    if B ~= 1
                        return;
                    end
                end
            else
                return
            end
            B = true;
        end

        
        % ----------------------------------------------------------------------------------
        function err = Load(obj, filename)
            err = 0;
            if ~exist('filename','var')
                return
            end
            err = obj.output.Load(filename);
        end


        
        % ----------------------------------------------------------------------------------
        function FreeMemory(obj, filename)
            if ~exist('filename','var')
                return
            end
            obj.output.FreeMemory(filename)
        end


        
        % ----------------------------------------------------------------------------------
        function str = EditParam(obj, iFcall, iParam, val)
            % Returns "" if the edit is rejected or the string 
            str = '';
            param = obj.fcalls(iFcall).paramIn(iParam);
            if isempty(iFcall)
                return;
            end
            if isempty(iParam)
                return;
            end
            if isempty(obj.fcalls)
                return;
            end
            if isempty(obj.fcalls(iFcall).paramIn)
                return;
            end
            param.Edit(val);
            str = sprintf(param.format, val);
        end


        % ----------------------------------------------------------------------------------
        function FcallsIdxs = GetFcallsIdxs(obj)
            nFcall = obj.GetFuncCallNum();
            if isempty(obj.fcallsIdxs)
                FcallsIdxs = 1:nFcall;
            else
                FcallsIdxs = obj.fcallsIdxs;
            end
        end        
        
        
        % ----------------------------------------------------------------------------------
        function fcall = GenerateFuncCallString(obj, iFcall)            
            funcName = obj.GetFuncCallName(iFcall);
            
            % Inoput arguments
            argIn = obj.ParseInputArgs(iFcall);
            
            % Users modifiable input parameters
            paramsIn = obj.ParseInputParams(iFcall);
            
            % Output arguments
            argOut = obj.ParseOutputArgs(iFcall);
            
            delimiter = '';
            if ~isempty(obj.fcalls(iFcall).argIn) && ~isempty(obj.fcalls(iFcall).paramIn)
                delimiter = ', ';
            end
            
            % call function
            fcall = sprintf('%s = %s(%s%s%s);', argOut, funcName, argIn, delimiter, paramsIn);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function fcalls = GetFuncCallChain(obj)
            N = length(obj.fcalls);
            fcalls = cell(N,1);            
            for ii = 1:N
                fcalls{ii} = obj.GenerateFuncCallString(ii);
            end
        end
        
        
        
        
        % ----------------------------------------------------------------------------------
        function fcalls = Calc(obj, filename)
            global logger
            
            if ~exist('filename','var')
                filename = '';
            end
            
            % loop over functions
            FcallsIdxs = obj.GetFcallsIdxs();
            nFcall = length(FcallsIdxs);
            
            paramsOutStruct = struct();
            hwait = waitbar_improved(0, 'Processing...' );
                
            paramOut = {};
            for iFcall = FcallsIdxs
                waitbar_improved( iFcall/nFcall, hwait, sprintf('Processing... %s', obj.fcalls(iFcall).GetName()) );
                
                % Instantiate all input variables required by function call
                argIn = obj.GetInputArgs(iFcall);
                for ii = 1:length(argIn)
                    if ~exist(argIn{ii},'var')
                        eval(sprintf('%s = obj.input.GetVar(''%s'');', argIn{ii}, argIn{ii}));
                    end
                end
                
                fcalls{iFcall} = obj.GenerateFuncCallString(iFcall);
                
                try
                    eval( fcalls{iFcall} );
                catch ME
                    msg = sprintf('Function %s generated error at line %d: %s', obj.fcalls(iFcall).name, ME.stack(1).line, ME.message);
                    if strcmp(obj.config.regressionTestActive, 'false')
                        MessageBox(msg);
                    end
                    logger.Write('%s\n', msg);
                    printStack(ME);
                    waitbar_improved(hwait, 'close');
                    rethrow(ME)
                end
                
                %%%% Parse output parameters
                
                % remove '[', ']', and ','
                foos = obj.fcalls(iFcall).argOut.str;
                for ii = 1:length(foos)
                    if foos(ii)=='[' || foos(ii)==']' || foos(ii)==',' || foos(ii)=='#'
                        foos(ii) = ' ';
                    end
                end
                
                % get parameters for Output to obj.output
                lst = strfind(foos,' ');
                lst = [0, lst, length(foos)+1]; %#ok<*AGROW>
                for ii = 1:length(lst)-1
                    foo2 = foos(lst(ii)+1:lst(ii+1)-1);
                    lst2 = strmatch( foo2, paramOut, 'exact' ); %#ok<MATCH3>
                    idx = strfind(foo2,'foo');
                    if isempty(lst2) && (isempty(idx) || idx>1) && ~isempty(foo2)
                        paramOut{end+1} = foo2;
                    end
                end
            end
            
            % Copy paramOut to output
            for ii = 1:length(paramOut)
                eval( sprintf('paramsOutStruct.%s = %s;', paramOut{ii}, paramOut{ii}) );
            end
            
            obj.output.Save(paramsOutStruct, filename);
            
            % Save processing stream function calls
            obj.ExportProcStream(filename, fcalls);
            
            obj.input.misc = [];
            waitbar_improved(hwait, 'close');
            
        end
        
        
        
        % ----------------------------------------------------------------------------------        
        function SaveInitOutput(obj, pathname, filename)
            obj.output.SaveInit(pathname, filename)
        end
        
        
        % ----------------------------------------------------------------------------------        
        function mlActMan = CompressMlActMan(obj)
            mlActMan = [];

            % We don't need to compress mlAct man because it is usually not that big 
            % But even did then we have to modify compressLogicalArray to handle 2d arrays 
            % instead of just vectors.
            % mlActMan = compressLogicalArray(obj.input.mlActMan{1});
            temp = obj.GetVar('mlActMan');
            if isempty(temp)
                return
            end
            mlActMan = temp{1};
        end
        
        
        % ----------------------------------------------------------------------------------        
        function tIncMan = CompresstIncMan(obj)
            tIncMan = [];
            if isempty(obj.input.tIncMan)
                return
            end
            tIncMan = compressLogicalArray(obj.input.tIncMan{1});
        end
                
                
                
        % ----------------------------------------------------------------------------------        
        function ExportProcStream(obj, filename, fcalls)
            global logger
            global cfg
            temp = obj.output.SetFilename(filename);
            if isempty(temp)
                return;
            end
            [p,f] = fileparts(temp); 
            fname = [filesepStandard(p), f, '_processing.json'];
            if strcmpi(cfg.GetValue('Export Processing Stream Functions'), 'yes')
                logger.Write('Saving processing stream  %s:\n', fname);
                appname = sprintf('%s', getNamespace());
                vernum  = sprintf('v%s', getVernum(appname));
                dt      = sprintf('%s', char(datetime(datetime, 'Format','MMMM d, yyyy,   HH:mm:ss')));
                mlActManCompressed = obj.CompressMlActMan();
                tIncManCompressed = obj.CompresstIncMan();
                jsonstruct = struct('ProcessingElement',f, 'ApplicationName',appname, 'Version',vernum, ...
                                    'Dependencies',obj.ExportProcStreamDependencies(), 'DateTime',dt, 'tIncMan',tIncManCompressed, ...
                                    'mlActMan',mlActManCompressed, 'FunctionCalls',{fcalls});
                jsonStr = savejson('Processing', jsonstruct);
                fid = fopen(fname, 'w');
                fwrite(fid, jsonStr, 'uint8');
                fclose(fid);
            else
                if ispathvalid(fname)
                    logger.Write('Deleting processing stream  %s:\n', fname);
                    try
                        delete(fname)
                    catch
                    end
                end
            end
        end
        
        
        
        
        % ----------------------------------------------------------------------------------
        function depStruct = ExportProcStreamDependencies(obj)
            depStruct = struct();
            [d, v] = dependencies();
            for ii = 1:length(d)
                eval( sprintf('depStruct.%s = ''v%s'';', d{ii}, v{ii}) );
            end
        end

        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes(1) = obj.input.MemoryRequired();
            nbytes(2) = obj.output.MemoryRequired();
            for ii = 1:length(obj.fcalls)
                nbytes(2+ii) = obj.fcalls(ii).MemoryRequired();
            end
            nbytes = sum(nbytes);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function FcallsIdxsReset(obj)
            obj.fcallsIdxs=[];
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)
            b=0;
            if isempty(obj)
                return
            end
            if isempty(obj.fcalls)
                b=1;
                return;
            end
            if isempty(obj.input)
                b=1;
                return;
            end
            if isempty(obj.output)
                b=1;
                return;
            end
            
            % Now that we know we have a non-empty fcalls, check to see if at least
            % one VALID function is present
            b=1;
            for ii=1:length(obj.fcalls)
                if ~isempty(obj.fcalls(ii).name) && ~isempty(obj.fcalls(ii).argOut.str)
                    b=0;
                    return;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = IsEmptyOutput(obj)
            b = true;
            if obj.output.IsEmpty()
                return;
            end
            b = false;
        end


        % ----------------------------------------------------------------------------------
        function b = AcquiredDataModified(obj)
            b = obj.input.AcquiredDataModified();
        end
        
        
    end
    
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function args = GetInputArgs(obj, iFcall)
            args={};
            if isempty(obj.fcalls)
                return;
            end
            if ~exist('iFcall', 'var') || isempty(iFcall)
                iFcall = obj.GetFcallsIdxs();
            end
            for jj = iFcall
                args{jj} = obj.fcalls(jj).argIn.Extract();
            end
            args = unique([args{:}], 'stable');
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function sargin = ParseInputParams(obj, iFcall)
            sargin = '';
            if ~exist('iFcall', 'var') || isempty(iFcall)
                iFcall = 1;
            end
            nParam = length(obj.fcalls(iFcall).paramIn);            
            if isempty(obj.fcalls)
                return;
            end
            if iFcall>length(obj.fcalls)
                return;
            end
            for iP = 1:nParam
                if isempty(sargin)
                    sargin = obj.fcalls(iFcall).paramIn(iP).DisplayValue();
                else
                    sargin = sprintf('%s, %s', sargin, obj.fcalls(iFcall).paramIn(iP).DisplayValue());
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function argInStr = ParseInputArgs(obj, iFcall)
            argInStr = '';
            if ~exist('iFcall', 'var') || isempty(iFcall)
                iFcall = 1;
            end
            if isempty(obj.fcalls)
                return;
            end
            if iFcall>length(obj.fcalls)
                return;
            end            
            argInStr = obj.fcalls(iFcall).argIn.Display();
        end
        
        
        % ----------------------------------------------------------------------------------
        function argOutStr = ParseOutputArgs(obj, iFcall)
            argOutStr = '';
            if ~exist('iFcall', 'var') || isempty(iFcall)
                iFcall = 1;
            end
            if isempty(obj.fcalls)
                return;
            end
            if iFcall>length(obj.fcalls)
                return;
            end            
            argOutStr = obj.fcalls(iFcall).argOut.Display();
        end
        
        
        % ----------------------------------------------------------------------------------
        function name = GetFuncCallName(obj, iFcall)
            name = '';
            if isempty(obj.fcalls)
                return;                
            end
            if iFcall>length(obj.fcalls)
                return;
            end
            name = obj.fcalls(iFcall).name;
        end
        
        
        % ----------------------------------------------------------------------------------
        function idx = GetFuncCallIdx(obj, name)
            % Find first occurrence of function call with function name
            % <name>
            idx = [];
            if ~ischar(name)
                return;                
            end
            for ii=1:length(obj.fcalls)
                if strcmp(obj.fcalls(ii).name, name)
                    idx=ii;
                    break;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function name = GetFcallNamePrettyPrint(obj, iFcall)
            name = '';
            if isempty(obj.fcalls)
                return;                
            end
            if iFcall>length(obj.fcalls)
                return;
            end
            name = sprintf_waitbar(obj.fcalls(iFcall).name);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function  Print(obj, indent)
            obj.input.Print(indent);
            obj.output.Print(indent);
        end

        
        
        % ----------------------------------------------------------------------------------
        function n = GetFuncCallNum(obj)
            n = length(obj.fcalls);
        end
                        
        
        
        % ----------------------------------------------------------------------------------
        function [maxnamelen, numUsages] = GetMaxCallNameLength(obj)
            maxnamelen = 0;
            numUsages = zeros(length(obj.fcalls),1);
            for iFcall = 1:length(obj.fcalls)
                % Look up number of usages for function associated with current function call. If it equals 1 
                % then set length to just thew length of the function name and exclude the usage portion. 
                % If there are multiple usages then include the whole function call name length; 
                % that is, <function name>: <usage name>
                numUsages(iFcall) = obj.reg.GetNumUsages(obj.fcalls(iFcall).GetName());
                if numUsages(iFcall) > 1
                    lenName = length(obj.fcalls(iFcall).GetUsageName());
                else
                    lenName = length(obj.fcalls(iFcall).GetName());
                end
                
                % If current usage name string length is greater than maxnamelen then set maxnamelen 
                % to current usage name string length 
                if lenName > maxnamelen
                    maxnamelen = lenName+1;
                end                
            end
        end
        
        
        % -----------------------------------------------------------------
        function maxnamelen = GetMaxParamNameLength(obj)
            maxnamelen = 0;
            for iFcall = 1:length(obj.fcalls)
                if obj.fcalls(iFcall).GetMaxParamNameLength() > maxnamelen
                    maxnamelen = obj.fcalls(iFcall).GetMaxParamNameLength();
                end
            end
        end
        
        
        % -----------------------------------------------------------------
        function n = GetParamNum(obj)
            n = zeros(1,length(obj.fcalls));
            for iFcall = 1:length(obj.fcalls)
                n(iFcall) = obj.fcalls(iFcall).GetParamNum();
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function ClearFcalls(obj)
            delete(obj.fcalls);
            obj.fcalls = FuncCallClass().empty();
        end
    
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for loading / saving proc stream config file.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        % ----------------------------------------------------------------------------------
        function [fname, autoGenDefault] = GetConfigFileName(obj, procStreamCfgFile, pathname)
            autoGenDefault = false;
            if ~exist('procStreamCfgFile','var')
                procStreamCfgFile = '';
            end
            if ~exist('pathname','var')
                pathname = filesepStandard(pwd);
            else
                pathname = filesepStandard(pathname, 'full');
            end
            
            % If procStream config filename wasn't passed down as an argument, check the 
            % parent application AppSettings.cfg config file to see if it set there. 
            if isempty(procStreamCfgFile)
                if ~isempty(obj.config.procStreamCfgFile)
                    procStreamCfgFile = obj.config.procStreamCfgFile;
                else
                    procStreamCfgFile = 'processOpt_default.cfg';
                end
            end

            % Check if file with name procStreamCfgFile exists
            temp = FileClass();
            if temp.Exist([pathname, procStreamCfgFile])
                fname = [pathname, procStreamCfgFile];
                fprintf('Default config file exists. Processing stream will be loaded from %s\n', fname);
                return;
            end
            fname = OpenFileGUI(procStreamCfgFile, pathname,'Load Processing Options File','.cfg');
            if isempty(fname)
                fname = [pathname, procStreamCfgFile];
                fprintf('Loading default config file.\n');
                autoGenDefault = true;
            end            
            
        end
        
        
        % ----------------------------------------------------------------------------------
        function err = LoadConfigFile(obj, fname, type)
            % Syntax:
            %   err = obj.LoadConfigFile(fname)
            %   err = obj.LoadConfigFile(fname, type)
            %
            % Description:
            %   Load proc stream function call chain from config file with name fname
            %   into ProcStreamClass object. If type argument isn't provided the class 
            %   defaults to run-level (type = 'run') and will load that section's call chain. 
            %
            % Example:
            %
            %   % Load function call chains at all levels from the config file 
            %   % processOpt_default_homer3.cfg to three instances of ProcStreamClass 
            %   pGroup = ProcStreamClass();
            %   pGroup.LoadConfigFile('processOpt_default_homer3.cfg', [], 'group');
            %   pSubj = ProcStreamClass();
            %   pSubj.LoadConfigFile('processOpt_default_homer3.cfg', [], 'subj');
            %   pRun = ProcStreamClass();
            %   pRun.LoadConfigFile('processOpt_default_homer3.cfg', [], 'run');
            %
            %   Here's what pSubj looks like:
            %
            %   pSubj =
            %
            %      ProcStreamClass with properties:
            %
            %            fcalls: [1x1 FuncCallClass]
            %           tIncMan: []
            %              misc: []
            %        changeFlag: 0
            %
            %   pSubj.fcalls = 
            %
            %       FuncCallClass with properties:
            %
            %              name: 'hmrS_RunAvg'
            %            nameUI: 'hmrS_RunAvg'
            %            argOut: '[dcAvg,dcAvgStd,tHRF,nTrials]'
            %             argIn: '(dcAvgRuns,dcAvgStdRuns,dcSum2Runs,tHRFRuns,mlActRuns,nTrialsRuns'
            %           paramIn: [0x0 ParamClass]
            %              help: '  Calculate the block average for all subjects, for all common stimuli�'
            %
            err = -1;
            if ~exist('fname', 'var')
                fname = '';
            end
            if ~exist('type', 'var') || isempty(type)
                type = 'run';
            end
            fid = fopen(fname);
            if fid<0
                return;
            end
            
            % Reinitialize fcalls since we're going to overwrite them anyway
            obj.fcalls = FuncCallClass().empty();
            err = obj.ParseFile(fid, type);
            fclose(fid);
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function err = SaveConfigFile(obj, fname, type)
            % Syntax:
            %   err = obj.SaveConfigFile(fname)
            %   err = obj.SaveConfigFile(fname, type)
            %
            % Description:
            %   Save this ProcStreamClass function call chain to config file fname. If type argument 
            %   isn't provided the class defaults to run-level (type = 'run'). The ProcStreamClass 
            %   object is not associated with a processing level - all it knows is it's 
            %   function call chain. It needs the type argument when saving
            %   to know how to label  
            %   the section it's saving in the file. It writes that header as '% <section name>' before
            %   the list of function call strings beginning with '@ '.
            %
            %   If the file already exists and has a config section for the same processing level, it 
            %   completetly replaces that section of the config file, leaving the other sections 
            %   untouched. 
            %
            % Example:
            %
            %   Create a processing config file for all processing levels. 
            %
            %   pInputR = ProcStreamClass();
            %   pInputR.LoadConfigFile('processOpt.cfg', 'run');
            %
            %   pInputS = ProcStreamClass();
            %   pInputS.LoadConfigFile('processOpt.cfg', 'subj');
            %
            %   pInputG = ProcStreamClass();
            %   pInputG.LoadConfigFile('processOpt.cfg', 'group');
            %
            %   pInputG.SaveConfigFile('./processOpt_new.cfg', 'group');
            %   pInputS.SaveConfigFile('./processOpt_new.cfg', 'subj');
            %   pInputR.SaveConfigFile('./processOpt_new.cfg', 'run');
            %
            err = -1;
            if ~exist('fname', 'var')
                fname = '';
            end
            if ~exist('type', 'var') || isempty(type)
                type = 'run';
            end
            versionstamp = sprintf('%% \n');

            % First read in and parse existing file contents
            if ~exist(fname, 'file')
                readoption = 'w+';
            else
                readoption = 'r';                
            end            
            fid = fopen(fname,readoption);
            if fid<0
                return;
            end
            [Group, Subj, Sess, Run] = obj.FindSections(fid, 'nodefault');
            fclose(fid);
            
            % Construct new contents
            switch(lower(type))
                case {'group', 'groupclass', 'grp'}
                    Group = [ sprintf('%% group'); obj.GenerateSection(); sprintf('\n') ]; %#ok<*SPRINTFN>
                    Subj = [ sprintf('%% subj');  Subj; sprintf('\n') ];
                    Sess = [ sprintf('%% sess');  Sess; sprintf('\n') ];
                    Run = [ sprintf('%% run');   Run; sprintf('\n') ];
                case {'subj', 'subjclass'}
                    Group = [ sprintf('%% group');  Group; sprintf('\n') ];
                    Subj = [ sprintf('%% subj');  obj.GenerateSection(); sprintf('\n') ];
                    Sess = [ sprintf('%% sess');  Sess; sprintf('\n') ];
                    Run = [ sprintf('%% run');   Run; sprintf('\n') ];
                case {'sess', 'sessclass'}
                    Group = [ sprintf('%% group'); Group; sprintf('\n') ];
                    Subj = [ sprintf('%% subj');  Subj; sprintf('\n') ];
                    Sess = [ sprintf('%% sess');  obj.GenerateSection(); sprintf('\n')  ];
                    Run = [ sprintf('%% run');   Run; sprintf('\n') ];
                case {'run', 'runclass'}
                    Group = [ sprintf('%% group'); Group; sprintf('\n') ];
                    Subj = [ sprintf('%% subj');  Subj; sprintf('\n') ];
                    Sess = [ sprintf('%% sess');  Sess; sprintf('\n') ];
                    Run = [ sprintf('%% run');   obj.GenerateSection(); sprintf('\n') ];
                otherwise
                    return;
            end
            newcontents = [versionstamp; Group; Subj; Sess; Run];
            
            % Write new contents to file 
            fid = fopen(fname,'w');
            for ii=1:length(newcontents)
                fprintf(fid, '%s\n', newcontents{ii});
            end
            fclose(fid);
            
            err=0;
        end
        
        
        % ---------------------------------------------------------------------
        % Function to extract the 3 proc stream sections - group, subj, and run -
        % from a processing stream config cell array.
        % ---------------------------------------------------------------------
        function [Group, Subj, Sess, Run] = FindSections(obj, fid, mode)
            %
            % Syntax:
            %    [Group, Subj, Sess, Run] = obj.FindSections(fid, mode)
            %
            % Description:
            %    Read in proc stream config file with file descriptor fid and returns the 
            %    group (G), subject (S) and run (R) sections. A section is a cell array of 
            %    encoded function call strings. If mode is 'default' then for a missing 
            %    section a default section is generated, otherwise it is left empty. 
            %
            % Example: 
            %    fid = fopen('processOpt_ShortSep.cfg');
            %    p = ProcStreamClass();
            %    [Group, Subj, Sess, Run] = p.FindSections(fid);
            %    fclose(fid);
            %
            %    Here's the output:
            %
            %     Group = {
            %          '@ hmrG_SubjAvg [dcAvg,dcAvgStd,nTrials,grpAvgPass] (dcAvgSubjs,dcAvgStdSubjs,SDSubjs,nTrialsSubjs tRange %0.1f�'
            %         }
            %     Subj = {
            %          '@ hmrS_RunAvg [dcAvg,dcAvgStd,nTrials] (dcAvgRuns,dcAvgStdRuns,dcSum2Runs,mlActRuns,nTrialsRuns'
            %         }
            %     Sess = {
            %          ''
            %         }
            %     Run = {
            %         '@ hmrR_Intensity2OD dod (d'
            %         '@ hmrR_MotionArtifact tIncAuto (dod,t,SD,tIncMan tMotion %0.1f 0.5 tMask %0.1f 1.0 STDEVthresh %0.1f 50.0 AMPthresh %0.1f 5.0'
            %         '@ hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.010 lpf %0.3f 0.500'
            %         '@ hmrR_OD2Conc dc (dod,SD ppf %0.1f_%0.1f 6.0_6.0'
            %         '@ hmrR_DeconvHRF_DriftSS [dcAvg,dcAvgstd,tHRF,nTrials,ynew,yresid,ysum2,beta,R] (dc,s,t,SD,aux,tIncAuto trange %0.1f_%0.1f -2.0_20.0 glmSolv�'
            %         }
            % 
            if ~exist('mode','var') || isempty(mode) || ~ischar(mode)
                mode = 'default';
            end
            
            Group = {};
            Subj = {};
            Sess = {};
            Run = {};
            if ~iswholenum(fid) || fid<0
                return;
            end
            iGroup=1; iSubj=1; iSess=1; iRun=1;
            section = 'run';   % Run is the default if sections aren't labeled
            while ~feof(fid)
                ln = fgetl(fid);
                if isempty(ln) || ~ischar(ln)
                    continue;
                end
                ln = strtrim(ln);
                if ln(1)=='%'
                    str = strtrim(ln(2:end));
                    switch(lower(str))
                        case {'group','grp'}
                            section = str;
                        case {'subj','subject'}
                            section = str;
                        case {'session','sess'}
                            section = str;
                        case {'run'}
                            section = str;
                    end
                elseif ln(1)=='@'
                    switch(lower(section))
                        case {'group','grp'}
                            Group{iGroup,1} = strtrim(ln); iGroup=iGroup+1;
                        case {'subj','subject'}
                            Subj{iSubj,1} = strtrim(ln); iSubj=iSubj+1;
                        case {'session','sess'}
                            Sess{iSess,1} = strtrim(ln); iSess=iSess+1;
                        case {'run'}
                            Run{iRun,1} = strtrim(ln); iRun=iRun+1;
                    end
                end
            end
            
            % Generate default contents for all sections which are missing
            if strcmp(mode, 'default')
                if isempty(Group)
                    Group = obj.fcallStrEncodedGroup;
                end
                if isempty(Subj)
                    Subj = obj.fcallStrEncodedSubj;
                end
                if isempty(Sess)
                    Sess = obj.fcallStrEncodedSess;
                end
                if isempty(Run)
                    Run = obj.fcallStrEncodedRun;
                end
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function section = GenerateSection(obj)
            %
            % Syntax:
            %    section = obj.GenerateSection()
            %
            % Description:

            %
            % Example: 
            %
            %    % Load run section into p from processOpt_default.cfg
            %    p = ProcStreamClass();
            %    p.LoadConfigFile('processOpt_default.cfg')
            %    R = obj.GenerateSection();
            %
            %    Here's the output:
            %
            %     R = {
            %         '@ hmrR_Intensity2OD dod (d'
            %         '@ hmrR_MotionArtifact tIncAuto (dod,t,SD,tIncMan tMotion %0.1f 0.5 tMask %0.1f 1.0 STDEVthresh %0.1f 50.0 AMPthresh %0.1f 5.0'
            %         '@ hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.010 lpf %0.3f 0.500'
            %         '@ hmrR_OD2Conc dc (dod,SD ppf %0.1f_%0.1f 6.0_6.0'
            %         '@ hmrR_DeconvHRF_DriftSS [dcAvg,dcAvgstd,tHRF,nTrials,ynew,yresid,ysum2,beta,R] (dc,s,t,SD,aux,tIncAuto trange %0.1f_%0.1f -2.0_20.0 glmSolv�'
            %         }
            %
            section = cell(length(obj.fcalls), 1);
            for ii=1:length(obj.fcalls)
                section{ii} = obj.fcalls(ii).Encode();
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function err = ParseFile(obj, fid, type)
            %
            % Processing stream config file parser. This function handles
            % group, subj and run processing stream parameters
            %
            % Example:
            %  
            %    Create a ProcStreamClass object and load the function calls
            %    from the proc stream config file './processOpt_default.cfg'
            % 
            %    fid = fopen('./processOpt_default.cfg');
            %    p = ProcStreamClass();
            %    p.ParseFile(fid, 'run');
            %    fclose(fid);
            %
            %    Here's some of the output 
            %
            %    p
            %
            %        ===> ProcStreamClass with properties:
            %
            %            fcalls: [1x6 FuncCallClass]
            %           tIncMan: []
            %              misc: []
            %        changeFlag: 0
            % 
            %    p.fcalls(2)
            %     
            %        ===> FuncCallClass with properties:
            %
            %              name: 'hmrR_MotionArtifact'
            %            nameUI: 'hmrR_MotionArtifact'
            %            argOut: 'tIncAuto'
            %             argIn: '(dod,t,SD,tIncMan'
            %           paramIn: [1x4 ParamClass]
            %              help: '  Excludes stims that fall within the time points identified as �'
            %
            %    p.fcalls(3)
            %     
            %        ===> FuncCallClass with properties:
            %
            %              name: 'hmrR_StimRejection'
            %            nameUI: 'hmrR_StimRejection'
            %            argOut: '[s,tRangeStimReject]'
            %             argIn: '(t,s,tIncAuto,tIncMan'
            %           paramIn: [1x1 ParamClass]
            %              help: '  Excludes stims that fall within the time points identified as �'
            %
            
            err = -1;
            if ~exist('fid','var') || ~iswholenum(fid) || fid<0
                return;
            end
            if ~exist('type','var')
                return;
            end
            [Group, Subj, Sess, Run] = obj.FindSections(fid);
            switch(lower(type))
                case {'group', 'groupclass', 'grp'}
                    err = obj.Decode(Group);
                case {'subj', 'subjclass'}
                    err = obj.Decode(Subj);
                case {'sess', 'sessclass'}
                    err = obj.Decode(Sess);
                case {'run', 'runclass'}
                    err = obj.Decode(Run);
                otherwise
                    return;
            end
        end
                   
    end

       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for decoding encoded function calls and substituting fixing error 
    % if the encoded call does not exists or has changed in registry. If the 
    % function call doen not exist but another call with the same function name 
    % exists then these methods look for the most similar entry to substitute 
    % for the non-existent call. 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
                
        % ----------------------------------------------------------------------------------
        function err = Decode(obj, section)
            % Syntax:
            %    obj.Decode(section)
            %    
            % Description:
            %    Parse a cell array of strings, each string an encoded hmr*.m function call
            %    and into the FuncCallClass array of this ProcStreamClass object. 
            %
            % Input: 
            %    A section contains encoded strings for one or more hmr* user function calls.
            %   
            % Example:
            %
            %    fcallStrs{1} = '@ hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.010 lpf %0.3f 0.500';
            %    fcallStrs{2} = '@ hmrR_OD2Conc dc (dod,SD ppf %0.1f_%0.1f 6_6';
            %
            %    p = ProcStreamClass();
            %    p.Decode(fcallStrs);
            % 
            %    Here's the output:
            % 
            %    p.fcalls(1)
            %
            %      ===> FuncCallClass with properties:
            %
            %          name: 'hmrR_BandpassFilt'
            %        nameUI: 'hmrR_BandpassFilt'
            %        argOut: 'dod'
            %         argIn: '(dod,t'
            %       paramIn: [1x2 ParamClass]
            %          help: '  Perform a bandpass filter�'
            %
            %    p.fcalls(2)
            %
            %      ===> FuncCallClass with properties:
            %
            %          name: 'hmrR_OD2Conc'
            %        nameUI: 'hmrR_OD2Conc'
            %        argOut: 'dc'
            %         argIn: '(dod,SD'
            %       paramIn: [1x1 ParamClass]
            %          help: '  Convert OD to concentrations�'
            % 
            err = 0;
            
            if nargin<2
                return
            end
            
            if ~iscell(section)
                if ~ischar(section)
                    return;
                else
                    section = {section};
                end
            end

            kk=1;
            for ii=1:length(section)
                if section{ii}(1)=='%'
                    continue;
                end
                if section{ii}(1)=='@'
                    temp = FuncCallClass(section{ii});
                    
                    % If registry is empty, then add fcall entries unconditionally. 
                    % Otherwise only include those user function calls that exist in the registry. 
                    if obj.reg.IsEmpty()
                        obj.fcalls(kk) = FuncCallClass(temp, obj.reg);
                        kk=kk+1;
                    elseif temp.GetErr()==0 && ~isempty(obj.reg.GetUsageName(temp))
                        obj.fcalls(kk) = FuncCallClass(temp, obj.reg);
                        kk=kk+1;
                    else
                        fprintf('Entry \"%s\" not found in registry ...\n', section{ii})
                        fprintf('  Searching registry for equivalent or similar entry\n')
                        temp = obj.reg.FindClosestMatch(temp);
                        if ~isempty(temp)
                            fprintf('  Found similar entry: %s\n', temp.encodedStr);
                            obj.fcalls(kk) = FuncCallClass(temp, obj.reg);
                            kk=kk+1;
                        else
                            fprintf('  Found no similar entries. Discarding %s\n', section{ii})
                            err = -1;
                        end
                    end
                end
            end
        end
        
    end
    
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function Add(obj, new)
            idx = length(obj.fcalls)+1;
            obj.fcalls(idx) = FuncCallClass(new, obj.reg);
        end
        
        
        % ----------------------------------------------------------------------------------
        function section = Encode(obj)
            % Syntax:
            %    section = obj.Encode()
            % 
            % Description:
            %    Generate a cell array of encoded string function calls from 
            %    the FuncCallClass array of this ProcStreamClass object. 
            %
            % Input:
            %    A section contains encoded strings for one or more hmr* user function calls.
            %   
            % Example:
            %
            %    fcallStrs{1} = '@ hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.010 lpf %0.3f 0.500';
            %    fcallStrs{2} = '@ hmrR_OD2Conc dc (dod,SD ppf %0.1f_%0.1f 6_6';
            %
            %    p = ProcStreamClass();
            %    p.Decode(fcallStrs);
            %    fcallStrs2 = p.Encode();
            %
            %
            section = cell(length(obj.fcalls), 1);
            for ii=1:length(obj.fcalls)
                section{ii} = obj.fcalls(ii).Encode();
            end
        end
        
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for dealing with default proc input 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        % ----------------------------------------------------------------------------------
        function CreateDefault(obj)
            obj.fcallStrEncodedGroup('init');
            obj.fcallStrEncodedSubj('init');
            obj.fcallStrEncodedSess('init');
            obj.fcallStrEncodedRun('init');
        end
        
        
        % ----------------------------------------------------------------------------------
        function obj2 = GetDefault(obj, type)
            obj2 = ProcStreamClass();
            switch(lower(type))
                case {'group', 'groupclass'}
                    obj2.Decode(obj.fcallStrEncodedGroup);
                case {'subj', 'subjclass'}
                    obj2.Decode(obj.fcallStrEncodedSubj);
                case {'sess', 'sessclass'}
                    obj2.Decode(obj.fcallStrEncodedSess);
                case {'run', 'runclass'}
                    obj2.Decode(obj.fcallStrEncodedRun);
                otherwise
                    return;
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Static methods 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = private, Static = true)

        % ----------------------------------------------------------------------------------
        function suffix = getDefaultProcStream()
            global cfg             
            suffix = '';
            defaultProcStream = cfg.GetValue('Default Processing Stream Style');
            if includes(lower(defaultProcStream),'nirs')
                suffix = '_Nirs';
            end
        end
            
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods implementing static variables for this class. The static variable 
    % for this class are the default function call chains for group, subject and run. 
    % There is only one instance of each of these because these variables are the 
    % same for all instances of the ProcStreamClass class
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function val = fcallStrEncodedGroup(obj, init)
            persistent v;
            if exist('init','var') && strcmp(init,'init') && ~obj.reg.IsEmpty
                iG = obj.reg.igroup;
                suffix = obj.getDefaultProcStream();
                tmp = {...
                    obj.reg.funcReg(iG).GetUsageStrDecorated(['hmrG_SubjAvg',suffix],'dcAvg'); ...
                    obj.reg.funcReg(iG).GetUsageStrDecorated(['hmrG_SubjAvgStd',suffix],'dcAvg'); ...
                };
                k=[]; kk=1;
                for ii=1:length(tmp)
                    if isempty(tmp{ii})
                        k(kk)=ii;
                        kk=kk+1;
                    end
                end
                tmp(k) = [];
                if ~isempty(tmp)
                    v = tmp;
                end
            end
            val = v;
        end
        
        
        % ----------------------------------------------------------------------------------
        function val = fcallStrEncodedSubj(obj, init)
            persistent v;
            if exist('init','var') && strcmp(init,'init') && ~obj.reg.IsEmpty
                iS = obj.reg.isubj;
                suffix = obj.getDefaultProcStream();
                tmp = {...
                    obj.reg.funcReg(iS).GetUsageStrDecorated(['hmrS_SessAvg',suffix],'dcAvg'); ...
                    obj.reg.funcReg(iS).GetUsageStrDecorated(['hmrS_SessAvgStd2',suffix],'dcAvg'); ...
                };
                k=[]; kk=1;
                for ii=1:length(tmp)
                    if isempty(tmp{ii})
                        k(kk)=ii;
                        kk=kk+1;
                    end
                end
                tmp(k) = [];
                if ~isempty(tmp)
                    v = tmp;
                end
            end
            val = v;
        end

        
        % ----------------------------------------------------------------------------------
        function val = fcallStrEncodedSess(obj, init)
            persistent v;
            if exist('init','var') && strcmp(init,'init') && ~obj.reg.IsEmpty
                iS = obj.reg.isess;
                suffix = obj.getDefaultProcStream();
                tmp = {...
                    obj.reg.funcReg(iS).GetUsageStrDecorated(['hmrE_RunAvg',suffix],'dcAvg'); ...
                    obj.reg.funcReg(iS).GetUsageStrDecorated(['hmrE_RunAvgStd2',suffix],'dcAvg'); ...
                };
                k=[]; kk=1;
                for ii=1:length(tmp)
                    if isempty(tmp{ii})
                        k(kk)=ii;
                        kk=kk+1;
                    end
                end
                tmp(k) = [];
                if ~isempty(tmp)
                    v = tmp;
                end
            end
            val = v;
        end

        
        % ----------------------------------------------------------------------------------
        function val = fcallStrEncodedRun(obj, init)
            persistent v;
            if exist('init','var') && strcmp(init,'init') && ~obj.reg.IsEmpty
                iR = obj.reg.irun;
                suffix = obj.getDefaultProcStream();
                tmp = {...
                    obj.reg.funcReg(iR).GetUsageStrDecorated(['hmrR_Intensity2OD',suffix]); ...
                    obj.reg.funcReg(iR).GetUsageStrDecorated(['hmrR_BandpassFilt',suffix],'aux'); ...
                    obj.reg.funcReg(iR).GetUsageStrDecorated(['hmrR_BandpassFilt',suffix],'dod'); ...
                    obj.reg.funcReg(iR).GetUsageStrDecorated(['hmrR_OD2Conc',suffix]); ...
                    obj.reg.funcReg(iR).GetUsageStrDecorated(['hmrR_BlockAvg',suffix],'dcAvg'); ...
                };
                k=[]; kk=1;
                for ii=1:length(tmp)
                    if isempty(tmp{ii})
                        k(kk)=ii;
                        kk=kk+1;
                    end
                end
                tmp(k) = [];
                if ~isempty(tmp)
                    v = tmp;
                end
            end
            val = v;
        end
                
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for getting/setting derived parameters 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function varval = GetVar(obj, varname, iBlk)
            if ~exist('iBlk','var')
                varval = obj.input.GetVar(varname);
                if isempty(varval)
                    varval = obj.output.GetVar(varname);
                end
            else
                varval = obj.input.GetVar(varname, iBlk);
                if isempty(varval)
                    varval = obj.output.GetVar(varname, iBlk);
                end
            end
            
            % Search function call chain as well if the requested variable 
            % is acually a user-settable parameter
            if isempty(varval)
                for ii = 1:length(obj.fcalls)
                    varval = obj.fcalls(ii).GetVar(varname);
                    if ~isempty(varval)
                        break;
                    end
                end
            end
            
        end
        
        
        
        % ---------------------------------------------------------
        function ml = GetMeasurementList(obj, matrixMode, iBlk, dataType)
            %  
            %  Syntax: 
            %     ml = GetMeasurementList(obj, matrixMode, iBlks, dataType)
            %
            %  Description:
            %     To specify the type of data associated with the measurement list use the last argument,
            %     dataType:
            %
            %        Optical Density     :  'od'
            %        Concentration       :  'conc' | 'hb' | 'hbo' | 'hbr' | 'hbt'
            %        HRF Optical Density :  'od hrf' | 'od_hrf' | 'hrf od' | 'hrf_od'
            %        HRF Concentration   :  'hb hrf' | 'conc hrf' | 'hb_hrf' | 'conc_hrf' | 'hrf hb' | 'hrf conc' | 'hrf_hb' | 'hrf_conc'
            %
            ml = [];
            if ~exist('matrixMode','var')
                matrixMode = '';
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            if ~exist('dataType','var')
                dataType = obj.datatypes.CONCENTRATION{1};
            end
            switch(lower(dataType))
                case obj.datatypes.OPTICAL_DENSITY
                    if iBlk <= length(obj.output.dod)
                        ml = obj.output.dod(iBlk).GetMeasurementList(matrixMode);
                    end
                case obj.datatypes.CONCENTRATION
                    if iBlk <= length(obj.output.dc)
                        ml = obj.output.dc(iBlk).GetMeasurementList(matrixMode);
                    end
                case [obj.datatypes.HRF_OPTICAL_DENSITY, obj.datatypes.HRF_OPTICAL_DENSITY_STD]
                    if iBlk <= length(obj.output.dodAvg)
                        ml = obj.output.dodAvg(iBlk).GetMeasurementList(matrixMode);
                    end
                case [obj.datatypes.HRF_CONCENTRATION, obj.datatypes.HRF_CONCENTRATION_STD]
                    if iBlk <= length(obj.output.dcAvg)
                        ml = obj.output.dcAvg(iBlk).GetMeasurementList(matrixMode);
                    end
            end
        end        



        % ---------------------------------------------------------
        function t = GetTHRF(obj, iBlk)
            t = [];
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            t = obj.output.tHRF;
        end
        
        
        
        % ---------------------------------------------------------
        function [dataTimeSeries, time, measurementList] = GetDataTimeSeries(obj, options, iBlk)
            %  
            %  Syntax: 
            %     dataTimeSeries = GetDataTimeSeries(obj, options, iBlk)
            %
            %  Description:
            %     To specify the type of data use the argument options:
            %
            %        Optical Density     :  'od'
            %        Concentration       :  'conc' | 'hb' | 'hbo' | 'hbr' | 'hbt'
            %        HRF Optical Density :  'od hrf' | 'od_hrf'
            %        HRF Concentration   :  'hb hrf' | 'conc hrf' | 'hb_hrf' | 'conc_hrf'
            %
            dataTimeSeries = [];
            time = [];
            measurementList = [];
            if ~exist('options','var')
                options = obj.datatypes.CONCENTRATION{1};
            end
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            switch(lower(options))
                case obj.datatypes.OPTICAL_DENSITY
                    if iBlk <= length(obj.output.dod)
                        dataTimeSeries = obj.output.dod(iBlk).dataTimeSeries;
                        time = obj.output.dod(iBlk).time;
                        measurementList = obj.output.dod(iBlk).GetMeasurementList('matrix');
                    end
                case obj.datatypes.CONCENTRATION
                    if iBlk <= length(obj.output.dc)
                        dataTimeSeries = obj.output.dc(iBlk).dataTimeSeries;
                        time = obj.output.dc(iBlk).time;
                        measurementList = obj.output.dc(iBlk).GetMeasurementList('matrix');
                    end
                case obj.datatypes.HRF_OPTICAL_DENSITY
                    if iBlk <= length(obj.output.dodAvg)
                        dataTimeSeries = obj.output.dodAvg(iBlk).dataTimeSeries;
                        time = obj.output.dodAvg(iBlk).time;
                        measurementList = obj.output.dodAvg(iBlk).GetMeasurementList('matrix');
                    end
                case obj.datatypes.HRF_CONCENTRATION
                    if iBlk <= length(obj.output.dcAvg)
                        dataTimeSeries = obj.output.dcAvg(iBlk).dataTimeSeries;
                        time = obj.output.dcAvg(iBlk).time;
                        measurementList = obj.output.dcAvg(iBlk).GetMeasurementList('matrix');
                    end
                case obj.datatypes.HRF_CONCENTRATION_STD
                    if iBlk <= length(obj.output.dodAvg)
                        dataTimeSeries = obj.output.dodAvgStd(iBlk).dataTimeSeries;
                        time = obj.output.dodAvgStd(iBlk).time;
                        measurementList = obj.output.dodAvgStd(iBlk).GetMeasurementList('matrix');
                    end
                case obj.datatypes.HRF_OPTICAL_DENSITY_STD
                    if iBlk <= length(obj.output.dcAvg)
                        dataTimeSeries = obj.output.dcAvgStd(iBlk).dataTimeSeries;
                        time = obj.output.dcAvgStd(iBlk).time;
                        measurementList = obj.output.dcAvgStd(iBlk).GetMeasurementList('matrix');
                    end
            end
        end
        

        
        % ----------------------------------------------------------------------------------
        function SetTincMan(obj, val, iBlk)
            if ~exist('iBlk','var')
                iBlk = [];
            end
            obj.input.SetTincMan(val, iBlk);
        end
        

        % ----------------------------------------------------------------------------------
        function tIncMan = GetTincMan(obj, iBlk)
            if ~exist('iBlk','var')
                iBlk = 1;
            end
            tIncMan = obj.input.GetTincMan(iBlk);
        end
        

        % ----------------------------------------------------------------------------------
        function tIncAuto = GetTincAuto(obj, iBlk)
            if ~exist('iBlk','var')
                iBlk = [];
            end
            tIncAuto = obj.output.GetVar('tIncAuto', iBlk);
        end
        

        % ----------------------------------------------------------------------------------
        function tIncAutoCh = GetTincAutoCh(obj, iBlk)
            if ~exist('iBlk','var')
                iBlk = [];
            end
            tIncAutoCh = obj.output.GetVar('tIncAutoCh', iBlk);
        end
        

        % ----------------------------------------------------------------------------------
        function mlActMan = GetMeasListActMan(obj, iBlk)
            if ~exist('iBlk','var')
                iBlk = [];
            end
            mlActMan = obj.input.GetVar('mlActMan',iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function mlActAuto = GetMeasListActAuto(obj, iBlk)
            if ~exist('iBlk','var')
                iBlk = [];
            end
            mlActAuto = obj.output.GetVar('mlActAuto',iBlk);
        end

        
        % ----------------------------------------------------------------------------------
        function pValues = GetPvalues(obj, iBlk)
            if ~exist('iBlk','var')
                iBlk = [];
            end
            pValues = obj.output.GetVar('pValues',iBlk);
        end
    
        
        % ----------------------------------------------------------------------------------
        function n = GetNumChForOneCondition(obj, iBlk)
            if nargin<2
                iBlk = 1;
            end            
            n = obj.output.GetNumChForOneCondition(iBlk);
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for getting/setting editable acquisition parameters such as
    % stimulus and source/detector geometry
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function AddStims(obj, tPts, condition, duration, amp, more)
            if isempty(tPts)
                return;
            end
            if isempty(condition)
                return;
            end
            obj.input.AddStims(tPts, condition, duration, amp, more);
        end

        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var')
                condition = '';
            end
            obj.input.DeleteStims(tPts, condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function ToggleStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var')
                condition = '';
            end
            obj.input.ToggleStims(tPts, condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function MoveStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var')
                condition = '';
            end
            obj.input.MoveStims(tPts, condition);
        end
        
        
        % ----------------------------------------------------------------------------------
        function AddStimColumn(obj, name, initValue)
            if ~exist('name', 'var')
                return;
            end
            obj.input.AddStimColumn(name, initValue);
        end

        
        % ----------------------------------------------------------------------------------
        function DeleteStimColumn(obj, idx)
            if ~exist('idx', 'var') || idx <= 3
                return;
            end
            obj.input.DeleteStimColumn(idx);
        end
        
        % ----------------------------------------------------------------------------------
        function RenameStimColumn(obj, oldname, newname)
            if ~exist('oldname', 'var') || ~exist('newname', 'var')
                return;
            end
            obj.input.RenameStimColumn(oldname, newname);
        end
        
        % ----------------------------------------------------------------------------------
        function data = GetStimData(obj, icond)
            data = obj.input.GetStimData(icond);
        end
        
    
        % ----------------------------------------------------------------------------------
        function val = GetStimDataLabels(obj, icond)
            val = obj.input.GetStimDataLabels(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimTpts(obj, icond, tpts)
            obj.input.SetStimTpts(icond, tpts);
        end
        
    
        % ----------------------------------------------------------------------------------
        function tpts = GetStimTpts(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            tpts = obj.input.GetStimTpts(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimDuration(obj, icond, duration, tpts)
            obj.input.SetStimDuration(icond, duration, tpts);
        end
        
    
        % ----------------------------------------------------------------------------------
        function duration = GetStimDuration(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            duration = obj.input.GetStimDuration(icond);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimAmplitudes(obj, icond, vals, tpts)
            obj.input.SetStimAmplitudes(icond, vals, tpts);
        end
        
    
        % ----------------------------------------------------------------------------------
        function vals = GetStimAmplitudes(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            vals = obj.input.GetStimAmplitudes(icond);
        end
                       
        
        % ----------------------------------------------------------------------------------
        function vals = GetAmplitudes(obj, icond)
            if ~exist('icond','var')
                icond=1;
            end
            vals = obj.input.GetStimAmplitudes(icond);
        end
                       
        
        % ---------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = obj.input.GetConditions();
        end
        

        % ----------------------------------------------------------------------------------
        function SetConditions(obj, CondNames)
            if nargin==1
                return;
            end
            obj.input.SetConditions(CondNames);
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStims_MatInput(obj, s, t, CondNames)
            obj.input.SetStims_MatInput(s, t, CondNames);
        end
        
        
        % ---------------------------------------------------------------------------------
        function StimReject(obj, t, iBlk)
            obj.input.StimReject(t, iBlk)
        end
        
        
        % ----------------------------------------------------------------------------------
        function StimInclude(obj, t, iBlk)
            obj.input.StimInclude(t, iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function RenameCondition(obj, oldname, newname)
            % Function to rename a condition. Important to remeber that changing the
            % condition involves 2 distinct well defined steps:
            %   a) For the current element change the name of the specified (old)
            %      condition for ONLY for ALL the acquired data elements under the
            %      currElem, be it run, subj, or group . In this step we DO NOT TOUCH
            %      the condition names of the run, subject or group .
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
            obj.input.RenameCondition(oldname, newname);
        end
        

        
        % ---------------------------------------------------------------
        function InitDataTypes(obj)
            obj.datatypes = struct(...
                'RAW',{{'raw','raw data','intensity'}}, ...
                'OPTICAL_DENSITY',{{'od'}}, ...
                'CONCENTRATION',{{'conc','hb','hbo','hbr','hbt'}}, ...
                'HRF_CONCENTRATION',{{'hrf conc','hrf_conc','hb hrf','conc hrf','hb_hrf','conc_hrf'}}, ...
                'HRF_OPTICAL_DENSITY',{{'hrf od','hrf_od','od hrf','od_hrf'}}, ...
                'HRF_CONCENTRATION_STD',{{'hrf conc std','hrf_conc_std','hb hrf std','conc hrf std','hb_hrf_std','conc_hrf_std'}}, ...
                'HRF_OPTICAL_DENSITY_STD',{{'hrf od std','hrf_od_std','od hrf std','od_hrf_std'}} ...
                );
        end
            
        
        
        % ---------------------------------------------------------------
        function datatypes = GetDataTypes(obj)
            datatypes = obj.datatypes;           
        end
            
        
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Export related methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods        
        
        % ----------------------------------------------------------------------------------
        function tblcells = GenerateTableCells_MeanHRF_Alt(obj, name, CondNames, trange, width, iBlk)
            if nargin<4
                width = 12;
            end
            if nargin<5
                iBlk = 1;
            end
            tblcells = obj.output.GenerateTableCells_MeanHRF_Alt(name, CondNames, trange, width, iBlk);
        end

            
        % ----------------------------------------------------------------------------------
        function [tblcells, maxwidth] = GenerateTableCellsHeader_MeanHRF(obj, iBlk)
            if nargin<2
                iBlk = 1;
            end
            [tblcells, maxwidth] = obj.output.GenerateTableCellsHeader_MeanHRF(iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function tblcells = GenerateTableCells_MeanHRF(obj, name, CondNames, trange, width, iBlk)
            if nargin<4
                width = 12;
            end
            if nargin<5
                iBlk = 1;
            end
            tblcells = obj.output.GenerateTableCells_MeanHRF(name, CondNames, trange, width, iBlk);
        end

            
        % ----------------------------------------------------------------------------------
        function tblcells = GenerateTableCells_HRF(obj, CondNames, iBlk)
            if nargin<3
                iBlk = 1;
            end
            tblcells = obj.output.GenerateTableCells_HRF(name, CondNames, iBlk);
        end
                
        
        % ----------------------------------------------------------------------------------
        function ExportHRF(obj, filename, CondNames, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            obj.output.ExportHRF(filename, CondNames, iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function filename = ExportHRF_GetFilename(obj, filename)
            filename = obj.output.ExportHRF_GetFilename(filename);
        end
        
        
        % ----------------------------------------------------------------------------------
        function ExportMeanHRF(obj, filename, CondNames, trange, iBlk)
            if ~exist('iBlk','var') || isempty(iBlk)
                iBlk = 1;
            end
            obj.output.ExportMeanHRF(filename, CondNames, trange, iBlk);
        end
        
        
        % ----------------------------------------------------------------------------------
        function ExportMeanHRF_Alt(obj, filename, tblcells)
            obj.output.ExportMeanHRF_Alt(filename, tblcells);
        end
        
    end
        
end


