classdef ProcInputClass < matlab.mixin.Copyable
    %
    % ProcInputClass stores processing stream input parameters that are independent 
    % of acquisition data or is derived from acquisition data but not stored there. 
    %
    properties
        func;       % Processing stream functions
        param;      % Processing stream user-settable input arguments and their current values
        CondName2Subj;  % Used by group processing stream
        CondName2Run;   % Used by subject processing stream      
        tIncMan;        % Manually include/excluded time points
        misc;
        changeFlag;     % Flag specifying if procInput+acquisition data is out 
                        %    of sync with procResult (currently not implemented)
    end
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = ProcInputClass()
            obj.param = struct([]);
            obj.func = struct([]);
            obj.CondName2Subj = [];
            obj.CondName2Run = [];            
            obj.tIncMan = [];
            obj.misc = [];
            obj.changeFlag = 0;
        end
                
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            if isproperty(obj2, 'param')
                obj.param = copyStructFieldByField(obj.param, obj2.param);
            end
            if isproperty(obj2, 'func')
                obj.func = obj2.func;
            end
            if isproperty(obj2, 'changeFlag')
                obj.changeFlag = obj2.changeFlag;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = isempty(obj)
            b = true;
            if isempty(obj.func)
                return
            end
            if isempty(obj.func(1).name)
                return;
            end
            b = false;
        end
        
        
        % ----------------------------------------------------------------------------------
        function str = EditParam(obj, iFunc, iParam, val)
            str = '';
            if isempty(iFunc)
                return;
            end
            if isempty(iParam)
                return;
            end
            obj.func(iFunc).paramVal{iParam} = val;
            eval( sprintf('obj.param.%s_%s = val;', ...
                          obj.func(iFunc).name, ...
                          obj.func(iFunc).param{iParam}) );
            str = sprintf(obj.func(iFunc).paramFormat{iParam}, val);
        end

        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)            
            b=0;           
            if isempty(obj.func)
                b=1;
                return;
            end
            
            % Now that we know we have a non-empty func, check to see if at least
            % one VALID function is present
            b=1;
            for ii=1:length(obj.func)
                if ~isempty(obj.func(ii).name) && ~isempty(obj.func(ii).argOut)
                    b=0;
                    return;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function args = GetInputArgs(obj, iFunc)
            args={};
            if isempty(obj.func)
                return;
            end
            if ~exist('iFunc', 'var') || isempty(iFunc)
                iFunc = 1:length(obj.func);
            end
            nFunc = length(obj.func);

            kk=1;
            for jj=1:length(iFunc)
                if iFunc(jj)>nFunc
                    continue;
                end
                if obj.func(iFunc(jj)).argIn(1) ~= '('
                    continue;
                end
                j=2;
                k = [findstr(obj.func(iFunc(jj)).argIn,',') length(obj.func(iFunc(jj)).argIn)+1];
                for ii=1:length(k)
                    args{kk} = obj.func(iFunc(jj)).argIn(j:k(ii)-1);
                    j = k(ii)+1;
                    kk=kk+1;
                end
            end
            args = unique(args, 'stable');
        end
        
        
        % ----------------------------------------------------------------------------------
        function found = FindVar(obj, varname)
            found = false;
            if isproperty(obj, varname)
                found = true;
            elseif isproperty(obj.misc, varname)
                found = true;
            end
        end

        
        % ----------------------------------------------------------------------------------
        function var = GetVar(obj, varname)
            var = [];
            if isproperty(obj, varname)
                eval(sprintf('var = obj.%s;', varname));
            elseif isproperty(obj.misc, varname)
                eval(sprintf('var = obj.misc.%s;', varname));
            end
        end

        
        % ----------------------------------------------------------------------------------
        function [sargin, p] = ParseInputParams(obj, iFunc)
            sargin = '';
            p = [];

            if isempty(obj.func)
                return;
            end
            if iFunc>length(obj.func)
                return;
            end
            
            sarginVal = '';
            for iP = 1:obj.func(iFunc).nParam
                if ~obj.func(iFunc).nParamVar
                    p{iP} = obj.func(iFunc).paramVal{iP};
                else
                    p{iP}.name = obj.func(iFunc).param{iP};
                    p{iP}.val = obj.func(iFunc).paramVal{iP};
                end
                if length(obj.func(iFunc).argIn)==1 & iP==1
                    sargin = sprintf('%sp{%d}', sargin, iP);
                    if isnumeric(p{iP})
                        if length(p{iP})==1
                            sarginVal = sprintf('%s%s', sarginVal, num2str(p{iP}));
                        else
                            sarginVal = sprintf('%s[%s]', sarginVal, num2str(p{iP}));
                        end
                    elseif ~isstruct(p{iP})
                        sarginVal = sprintf('%s,%s', sarginVal, p{iP});
                    else
                        sarginVal = sprintf('%s,[XXX]', sarginVal);
                    end
                else
                    sargin = sprintf('%s,p{%d}', sargin, iP);
                    if isnumeric(p{iP})
                        if length(p{iP})==1
                            sarginVal = sprintf('%s,%s', sarginVal, num2str(p{iP}));
                        else
                            sarginVal = sprintf('%s,[%s]', sarginVal, num2str(p{iP}));
                        end
                    elseif ~isstruct(p{iP})
                        sarginVal = sprintf('%s,%s', sarginVal, p{iP});
                    else
                        sarginVal = sprintf('%s,[XXX]',sarginVal);
                    end
                end
            end
        end     
        
        
        % ----------------------------------------------------------------------------------
        function sargout = ParseOutputArgs(obj, iFunc)
            sargout = '';
            if isempty(obj.func)
                return;
            end
            if iFunc>length(obj.func)
                return;
            end            
            sargout = obj.func(iFunc).argOut;
            for ii=1:length(obj.func(iFunc).argOut)
                if sargout(ii)=='#'
                    sargout(ii) = ' ';
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function name = GetFuncName(obj, iFunc)
            name = '';
            if isempty(obj.func)
                return;                
            end
            if iFunc>length(obj.func)
                return;
            end
            name = obj.func(iFunc).name;
        end
        
        
        % ----------------------------------------------------------------------------------
        function name = GetFuncNamePrettyPrint(obj, iFunc)
            name = '';
            if isempty(obj.func)
                return;                
            end
            if iFunc>length(obj.func)
                return;
            end
            k = find(obj.func(iFunc).name=='_');
            if isempty(k)
                name = obj.func(iFunc).name;
            else
                name = sprintf('%s\\%s...', obj.func(iFunc).name(1:k-1), obj.func(iFunc).name(k:end));
            end            
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetFuncNum(obj)
            n = length(obj.func);
        end

                
        % ----------------------------------------------------------------------------------
        function LoadVars(obj, vars)
            if ~isstruct(vars)
                return;
            end
            fields = fieldnames(vars); 
            for ii=1:length(fields) 
                eval( sprintf('obj.misc.%s = vars.%s;', fields{ii}, fields{ii}) );
            end
        end

        
        % ----------------------------------------------------------------------------------
        function SetTincMan(obj, val)
            obj.tIncMan = val;
        end
                
        % ----------------------------------------------------------------------------------
        function val = GetTincMan(obj)
             val = obj.tIncMan;
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize/Generate default functions and prcessOpt_default.cfg file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function [filename, pathname] = CreateDefaultConfigFile(obj)
            % This pause is a workaround for a matlab bug in version
            % 7.11 for Linux, where uigetfile won't block unless there's
            % a breakpoint.
            pause(.5);
            [filename, pathname] = uigetfile('*.cfg', 'Load Process Options File' );
            if filename==0
                ch = menu( sprintf('Loading default config file.'),'Okay');
                filename = './processOpt_default.cfg';
                success = true;
                if exist(filename,'file')
                    delete(filename);
                    if exist(filename,'file')
                        success = false;
                    end
                end
                if success
                    obj.FileGen(filename, 'group');
                    obj.FileGen(filename, 'subj');
                    obj.FileGen(filename, 'run');
                end
            else
                filename = [pathname filename];
            end
        end
        
                
        % ----------------------------------------------------------------------------------
        function FileGen(obj, filepath, type)            
            % Generates default processOpt.cfg file.
            % Note that fprintf outputs formatted text where some characters
            % are special characters - such as '%'. In order to write a
            % literal '%' you need to type '%%' in fprintf argument string
            % (2nd argument).
            %
            if ischar(filepath)
                slashes = [findstr(filepath,'/') findstr(filepath,'\')];
                if(~isempty(slashes))
                    filename = ['.' filepath(slashes(end):end)];
                end
                fid = fopen(filename,'a');
            else
                fid = filepath;
            end
            
            switch(type)
                case 'group'
                    contents = obj.DefaultFileGroup();
                case 'subj'
                    contents = obj.DefaultFileSubj();
                case 'run'
                    contents = obj.DefaultFileRun();
            end
            for ii=1:length(contents)
                fprintf(fid, contents{ii});
            end
            
            if ischar(filepath)
                fclose(fid);
            else
                fseek(fid,0,'bof');
            end
        end
                   
        
        % ----------------------------------------------------------------------------------
        function [contents, str] = DefaultFileGroup(obj, funcRun)
            % Choose default procStream group section based on the run procStream
            % output; if it's output ia dodAvg, choose the dodAvg default, otherwise
            % choose dcAvg.
            if ~exist('funcRun','var') | isempty(funcRun)
                funcRun(1).argOut = '';
            end
            datatype = 'dcAvg';
            for ii=1:length(funcRun)
                if ~isempty(strfind(funcRun(ii).argOut, 'dodAvg'))
                    datatype = 'dodAvg';
                    break;
                end
            end
            contents_dcAvg = {...
                '%% group\n', ...
                '@ hmrG_BlockAvg [dcAvg,dcAvgStd,tHRF,nTrials,grpAvgPass] (dcAvgSubjs,dcAvgStdSubjs,tHRFSubjs,SDSubjs,nTrialsSubjs,CondName2Subj trange %%0.1f_%%0.1f 5_10 thresh %%0.1f 5\n', ...
                '\n\n', ...
            };
            contents_dodAvg = {...
                '%% group\n', ...
                '@ hmrG_BlockAvg [dodAvg,dodAvgStd,tHRF,nTrials,grpAvgPass] (dodAvgSubjs,dodAvgStdSubjs,tHRFSubjs,SDSubjs,nTrialsSubjs,CondName2Subj trange %%0.1f_%%0.1f 5_10 thresh %%0.1f 5\n', ...
                '\n\n', ...
            };
            if strcmp(datatype, 'dcAvg')
                contents = contents_dcAvg;
            else
                contents = contents_dodAvg;
            end
            str = cell2str(contents);
        end
        
                
        % ----------------------------------------------------------------------------------
        function [contents, str] = DefaultFileSubj(obj, funcRun)
            % Choose default procStream group section based on the run procStream
            % output; if it's output ia dodAvg, choose the dodAvg default, otherwise
            % choose dcAvg.
            if ~exist('funcRun','var') | isempty(funcRun)
                funcRun(1).argOut = '';
            end
            datatype = 'dcAvg';
            for ii=1:length(funcRun)
                if ~isempty(strfind(funcRun(ii).argOut, 'dodAvg'))
                    datatype = 'dodAvg';
                    break;
                end
            end
            contents_dcAvg = {...
                '%% subj\n', ...
                '@ hmrS_BlockAvg [dcAvg,dcAvgStd,tHRF,nTrials] (dcAvgRuns,dcAvgStdRuns,dcSum2Runs,tHRFRuns,SDRuns,nTrialsRuns,CondName2Run\n', ...
                '\n\n', ...
            };
            contents_dodAvg = {...
                '%% subj\n', ...
                '@ hmrS_BlockAvg [dodAvg,dodAvgStd,tHRF,nTrials] (dodAvgRuns,dodAvgStdRuns,dodSum2Runs,tHRFRuns,SDRuns,nTrialsRuns,CondName2Run\n', ...
                '\n\n', ...
            };
            if strcmp(datatype, 'dcAvg')
                contents = contents_dcAvg;
            else
                contents = contents_dodAvg;
            end
            str = cell2str(contents);            
        end
        
        
        % ----------------------------------------------------------------------------------
        function [contents, str] = DefaultFileRun(obj)
            contents = {...
                '%% run\n', ...
                '@ hmrR_Intensity2OD dod (d\n', ...
                '@ hmrR_MotionArtifact tIncAuto (dod,t,SD,tIncMan tMotion %%0.1f 0.5 tMask %%0.1f 1 STDEVthresh %%0.1f 50 AMPthresh %%0.1f 5\n', ...
                '@ hmrR_BandpassFilt dod (dod,t hpf %%0.3f 0.01 lpf %%0.1f 0.5\n', ...
                '@ hmrR_OD2Conc dc (dod,SD ppf %%0.1f_%%0.1f 6_6\n', ...
                '@ hmrR_StimRejection [s,tRangeStimReject] (t,s,tIncAuto,tIncMan tRange %%0.1f_%%0.1f -5_10\n', ...
                '@ hmrR_BlockAvg [dcAvg,dcAvgStd,tHRF,nTrials,dcSum2,dcTrials] (dc,s,t trange %%0.1f_%%0.1f -2_20\n' ...
                '\n\n', ...
                };
            str = cell2str(contents);
        end
        
        
        % ----------------------------------------------------------------------------------
        function Default(obj, type)
            obj.param = struct([]);
            switch(type)
                case 'group'
                    [~, filecontents_str] = obj.DefaultFileGroup();
                case 'subj'
                    [~, filecontents_str] = obj.DefaultFileSubj();
                case 'run'
                    [~, filecontents_str] = obj.DefaultFileRun();
            end
            S = textscan(filecontents_str,'%s');
            [obj.func, obj.param] = parseSection(S{1});
            obj.SetHelp();
        end
        
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Help related methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function SetHelp(obj)
            for ii=1:length(obj.func)
                if ~isproperty(obj.func(ii), 'help')
                    obj.func(ii).help = InitHelp(0);
                end
                if isempty(obj.func(ii).help.callstr)
                    obj.func(ii).help = procStreamParseFuncHelp(obj.func(ii));
                end
            end
        end
        
    end
    
end

