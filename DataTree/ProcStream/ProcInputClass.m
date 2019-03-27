classdef ProcInputClass < handle
    %
    % ProcInputClass stores processing stream input parameters that are independent 
    % of acquisition data or is derived from acquisition data but not stored there. 
    %
    properties
        fcalls;                  % Array of FuncCallClass objects representing function call chain i.e. processing stream
        CondName2Subj;           % Used by group processing stream
        CondName2Run;            % Used by subject processing stream      
        tIncMan;                 % Manually include/excluded time points
        stimValSettings;         % Derived stim values 
        misc;
        changeFlag;              % Flag specifying if procInput+acquisition data is out 
                                 %    of sync with procResult (currently not implemented)
        config;
    end
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = ProcInputClass(reg)
            obj.fcalls = FuncCallClass().empty();
            obj.CondName2Subj = [];
            obj.CondName2Run = [];
            obj.tIncMan = [];
            obj.misc = [];
            obj.changeFlag = 0;
            obj.config = struct('procStreamCfgFile','');
            obj.stimValSettings = struct('none',0, 'incl',1, 'excl_manual',-1, 'excl_auto',-2);
            if nargin==0
                return;
            end
            obj.CreateDefault(reg)
            cfg = ConfigFileClass();
            obj.config.procStreamCfgFile = cfg.GetValue('Processing Stream Config File');
        end
                
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2, reg)
            if nargin<3
                reg = RegistriesClass.empty();
            end
            if isempty(obj)
                obj = ProcInputClass();
            end
            for ii=1:length(obj2.fcalls)
                if ii>length(obj.fcalls)
                    obj.fcalls(ii) = FuncCallClass();
                end
                obj.fcalls(ii).Copy(obj2.fcalls(ii), reg);
            end
            obj.CondName2Subj = obj2.CondName2Subj;
            obj.CondName2Run = obj2.CondName2Run;
            obj.tIncMan = obj2.tIncMan;
            
            % misc could contain handle objects, which use the Copy methods to transfer their contents 
            fields = properties(obj.misc);
            for ii=1:length(fields)
                if ~eval(sprintf('isproperty(obj2.misc, ''%s'')', fields{ii}))
                    continue;
                end
                if isa(eval(sprintf('obj.misc.%s', fields{ii})), 'handle')
                    eval( sprintf('obj.misc.%s.Copy(obj2.misc.%s);', fields{ii}, fields{ii}) );
                else
                    eval( sprintf('obj.misc.%s = obj2.misc.%s;', fields{ii}, fields{ii}) );
                end
            end
            
            obj.changeFlag = obj2.changeFlag;
        end
        
        
        % ----------------------------------------------------------------------------------
        function CopyFcalls(obj, procInput)
            delete(obj.fcalls);
            obj.fcalls = FuncCallClass().empty();
            for ii=1:length(procInput.fcalls)
                obj.fcalls(ii) = FuncCallClass(procInput.fcalls(ii));
            end
        end
        
        

        % ----------------------------------------------------------------------------------
        function str = EditParam(obj, iFcall, iParam, val)
            str = '';
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
            obj.fcalls(iFcall).paramIn(iParam).value = val;
            str = sprintf(obj.fcalls(iFcall).paramIn(iParam).format, val);
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
        function Print(obj, indent)
            if ~exist('indent', 'var')
                indent = 6;
            end
            fprintf('%sInput:\n', blanks(indent));
            fprintf('%sCondName2Subj:\n', blanks(indent+4));
            pretty_print_matrix(obj.CondName2Subj, indent+4, sprintf('%%d'))
            fprintf('%sCondName2Run:\n', blanks(indent+4));
            pretty_print_matrix(obj.CondName2Run, indent+4, sprintf('%%d'))
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function ClearFcalls(obj)
            delete(obj.fcalls);
            obj.fcalls = FuncCallClass().empty();
        end
        
        
        % ----------------------------------------------------------------------------------
        function [args, type] = GetInputArgs(obj, iFcall)
            args={};
            type={};
            if isempty(obj.fcalls)
                return;
            end
            if ~exist('iFcall', 'var') || isempty(iFcall)
                iFcall = 1:length(obj.fcalls);
            end
            nFcall = length(obj.fcalls);

            kk=1;
            for jj=1:length(iFcall)
                if iFcall(jj)>nFcall
                    continue;
                end
                if obj.fcalls(iFcall(jj)).argIn.str(1) ~= '('
                    continue;
                end
                j=2;
                k = [strfind(obj.fcalls(iFcall(jj)).argIn.str,',') length(obj.fcalls(iFcall(jj)).argIn.str)+1];
                for ii=1:length(k)
                    args{kk} = obj.fcalls(iFcall(jj)).argIn.str(j:k(ii)-1);
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
        function [sargin, p, sarginVal] = ParseInputParams(obj, iFcall)
            sargin = '';
            sarginVal = '';
            nParam = length(obj.fcalls(iFcall).paramIn);            
            p = cell(nParam, 1);

            if isempty(obj.fcalls)
                return;
            end
            if iFcall>length(obj.fcalls)
                return;
            end            
            for iP = 1:nParam
                p{iP} = obj.fcalls(iFcall).paramIn(iP).value;
                if length(obj.fcalls(iFcall).argIn.str)==1 & iP==1
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
        function sargout = ParseOutputArgs(obj, iFcall)
            sargout = '';
            if isempty(obj.fcalls)
                return;
            end
            if iFcall>length(obj.fcalls)
                return;
            end            
            sargout = obj.fcalls(iFcall).argOut.str;
            for ii=1:length(obj.fcalls(iFcall).argOut.str)
                if sargout(ii)=='#'
                    sargout(ii) = ' ';
                end
            end
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
        function n = GetFuncCallNum(obj)
            n = length(obj.fcalls);
        end
                
        
        % ----------------------------------------------------------------------------------
        function maxnamelen = GetMaxCallNameLength(obj)
            maxnamelen = 0;
            for iFcall = 1:length(obj.fcalls)
                if length(obj.fcalls(iFcall).GetNameUserFriendly()) > maxnamelen
                    maxnamelen = length(obj.fcalls(iFcall).nameUI)+1;
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
        function LoadVars(obj, vars)
            if ~isstruct(vars)
                return;
            end
            fields = fieldnames(vars); 
            for ii=1:length(fields) 
                eval( sprintf('obj.misc.%s = vars.%s;', fields{ii}, fields{ii}) );
            end
        end
        
    end
        
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function vals = GetStimValSettings(obj)
            vals = obj.stimValSettings;
        end
        
        
        % ----------------------------------------------------------------------------------
        function s = GetStims(obj)
            s = [];
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
    % Methods for loading / saving proc stream config file.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        % ----------------------------------------------------------------------------------
        function fname = GetConfigFileName(obj, procStreamCfgFile)
            if ~exist('procStreamCfgFile','var')
                procStreamCfgFile = '';
            end
            
            % If procStream config filename wasn't passed down as an argument, check the 
            % parent application AppSettings.cfg config file to see if it set there. 
            if isempty(procStreamCfgFile)
                procStreamCfgFile = obj.config.procStreamCfgFile;
            end

            % Check if file with name procStreamCfgFile exists
            temp = FileClass();
            if temp.Exist(procStreamCfgFile)
                fname = procStreamCfgFile;
                fprintf('Default config file exists. Processing stream will be loaded from %s\n', procStreamCfgFile, procStreamCfgFile);
                return;
            end
            
            % This pause is a workaround for a matlab bug in version
            % 7.11 for Linux, where uigetfile won't block unless there's
            % a breakpoint.
            pause(.5);
            [fname, pname] = uigetfile('*.cfg', 'Load Process Options File' );
            if fname==0
                menu( sprintf('Loading default config file.'),'Okay');
                fname = [pwd, '/processOpt_default.cfg'];
            else
                fname = [pname, '/', fname];
            end
            fname(fname=='\')='/';
        end
        
        
        % ----------------------------------------------------------------------------------
        function err = LoadConfigFile(obj, fname, reg, type)
            % Syntax:
            %   err = obj.LoadConfigFile(fname)
            %   err = obj.LoadConfigFile(fname, reg)
            %   err = obj.LoadConfigFile(fname, reg, type)
            %
            % Description:
            %   Load proc stream function call chain from config file with name fname
            %   into ProcInputClass object. If reg argument is not provided the class will 
            %   generate its own local registry. If type argument isn't provided the class 
            %   defaults to run-level (type = 'run') and will load that section's call chain. 
            %
            % Example:
            %
            %   % Load function call chains at all levels from the config file 
            %   % processOpt_default_homer3.cfg to three instances of ProcInputClass 
            %   pGroup = ProcInputClass();
            %   pGroup.LoadConfigFile('processOpt_default_homer3.cfg', [], 'group');
            %   pSubj = ProcInputClass();
            %   pSubj.LoadConfigFile('processOpt_default_homer3.cfg', [], 'subj');
            %   pRun = ProcInputClass();
            %   pRun.LoadConfigFile('processOpt_default_homer3.cfg', [], 'run');
            %
            %   Here's what pSubj looks like:
            %
            %   pSubj =
            %
            %      ProcInputClass with properties:
            %
            %            fcalls: [1x1 FuncCallClass]
            %     CondName2Subj: []
            %      CondName2Run: []
            %           tIncMan: []
            %              misc: []
            %        changeFlag: 0
            %
            %   pSubj.fcalls = 
            %
            %       FuncCallClass with properties:
            %
            %              name: 'hmrS_BlockAvg'
            %            nameUI: 'hmrS_BlockAvg'
            %            argOut: '[dcAvg,dcAvgStd,tHRF,nTrials]'
            %             argIn: '(dcAvgRuns,dcAvgStdRuns,dcSum2Runs,tHRFRuns,SDRuns,nTrialsRuns,CondName2Run'
            %           paramIn: [0x0 ParamClass]
            %              help: '  Calculate the block average for all subjects, for all common stimuli…'
            %
            err = -1;
            if ~exist('fname', 'var')
                fname = '';
            end
            if ~exist('reg', 'var') || isempty(reg)            
                reg = RegistriesClass();
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
            obj.ParseFile(fid, type, reg);
            fclose(fid);
            err=0;            
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function err = SaveConfigFile(obj, fname, type)
            % Syntax:
            %   err = obj.SaveConfigFile(fname)
            %   err = obj.SaveConfigFile(fname, type)
            %
            % Description:
            %   Save this ProcInputClass function call chain to config file fname. If type argument 
            %   isn't provided the class defaults to run-level (type = 'run'). The ProcInputClass 
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
            %   reg = RegistriesClass();
            %
            %   pInputR = ProcInputClass(reg);
            %   pInputR.LoadConfigFile('processOpt.cfg', reg, 'run');
            %
            %   pInputS = ProcInputClass(reg);
            %   pInputS.LoadConfigFile('processOpt.cfg', reg, 'subj');
            %
            %   pInputG = ProcInputClass(reg);
            %   pInputG.LoadConfigFile('processOpt.cfg', reg, 'group');
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
            versionstamp = sprintf('%% %s\n', Homer3_version('exclpath'));

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
            [G, S, R] = obj.FindSections(fid, 'nodefault');
            fclose(fid);
            
            % Construct new contents
            switch(lower(type))
                case {'group', 'groupclass', 'grp'}
                    G = [ sprintf('%% group'); obj.GenerateSection(); sprintf('\n') ];
                    S = [ sprintf('%% subj');  S; sprintf('\n') ];
                    R = [ sprintf('%% run');   R; sprintf('\n') ];
                case {'subj', 'session', 'subjclass'}
                    G = [ sprintf('%% group'); G; sprintf('\n') ];
                    S = [ sprintf('%% subj');  obj.GenerateSection(); sprintf('\n') ];
                    R = [ sprintf('%% run');   R; sprintf('\n') ];
                case {'run', 'runclass'}
                    G = [ sprintf('%% group'); G; sprintf('\n') ];
                    S = [ sprintf('%% subj');  S; sprintf('\n') ];
                    R = [ sprintf('%% run');   obj.GenerateSection(); sprintf('\n') ];
                otherwise
                    return;
            end
            newcontents = [versionstamp; G; S; R];
            
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
        function [G, S, R] = FindSections(obj, fid, mode)
            %
            % Syntax:
            %    [G, S, R] = obj.FindSections(fid, mode)
            %
            % Description:
            %    Read in proc stream config file with file descriptor fid and returns the 
            %    group (G), subject (S) and run (R) sections. A section is a cell array of 
            %    encoded function call strings. If mode is 'default' then for a missing 
            %    section a default section is generated, otherwise it is left empty. 
            %
            % Example: 
            %    fid = fopen('processOpt_ShortSep.cfg');
            %    p = ProcInputClass();
            %    [G, S, R] = p.FindSections(fid);
            %    fclose(fid);
            %
            %    Here's the output:
            %
            %     G = {
            %          '@ hmrG_BlockAvg [dcAvg,dcAvgStd,nTrials,grpAvgPass] (dcAvgSubjs,dcAvgStdSubjs,SDSubjs,nTrialsSubjs,CondName2Subj tRange %0.1f…'
            %         }
            %     S = {
            %          '@ hmrS_BlockAvg [dcAvg,dcAvgStd,nTrials] (dcAvgRuns,dcAvgStdRuns,dcSum2Runs,SDRuns,nTrialsRuns,CondName2Run'
            %         }
            %     R = {
            %         '@ hmrR_Intensity2OD dod (d'
            %         '@ hmrR_MotionArtifact tIncAuto (dod,t,SD,tIncMan tMotion %0.1f 0.5 tMask %0.1f 1.0 STDEVthresh %0.1f 50.0 AMPthresh %0.1f 5.0'
            %         '@ hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.010 lpf %0.3f 0.500'
            %         '@ hmrR_OD2Conc dc (dod,SD ppf %0.1f_%0.1f 6.0_6.0'
            %         '@ hmrR_DeconvHRF_DriftSS [dcAvg,dcAvgstd,tHRF,nTrials,ynew,yresid,ysum2,beta,R] (dc,s,t,SD,aux,tIncAuto trange %0.1f_%0.1f -2.0_20.0 glmSolv…'
            %         }
            % 
            if ~exist('mode','var') || isempty(mode) || ~ischar(mode)
                mode = 'default';
            end
            
            G = {};
            S = {};
            R = {};
            if ~iswholenum(fid) || fid<0
                return;
            end
            iG=1; iS=1; iR=1;
            section = 'run';   % Run is the default is sections aren't labeled
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
                        case {'subj','subject','session','sess'}
                            section = str;
                        case {'run'}
                            section = str;
                    end
                elseif ln(1)=='@'
                    switch(lower(section))
                        case {'group','grp'}
                            G{iG,1} = strtrim(ln); iG=iG+1;
                        case {'subj','subject','session','sess'}
                            S{iS,1} = strtrim(ln); iS=iS+1;
                        case {'run'}
                            R{iR,1} = strtrim(ln); iR=iR+1;
                    end
                end
            end
            
            % Generate default contents for all sections which are missing
            if strcmp(mode, 'default')
                if isempty(G)
                    G = obj.fcallStrEncodedGroup;
                end
                if isempty(S)
                    S = obj.fcallStrEncodedSubj;
                end
                if isempty(R)
                    R = obj.fcallStrEncodedRun;
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
            %    reg = RegistriesClass();
            %    p = ProcInputClass();
            %    p.LoadConfigFile('processOpt_default.cfg', reg)
            %    R = obj.GenerateSection();
            %
            %    Here's the output:
            %
            %     R = {
            %         '@ hmrR_Intensity2OD dod (d'
            %         '@ hmrR_MotionArtifact tIncAuto (dod,t,SD,tIncMan tMotion %0.1f 0.5 tMask %0.1f 1.0 STDEVthresh %0.1f 50.0 AMPthresh %0.1f 5.0'
            %         '@ hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.010 lpf %0.3f 0.500'
            %         '@ hmrR_OD2Conc dc (dod,SD ppf %0.1f_%0.1f 6.0_6.0'
            %         '@ hmrR_DeconvHRF_DriftSS [dcAvg,dcAvgstd,tHRF,nTrials,ynew,yresid,ysum2,beta,R] (dc,s,t,SD,aux,tIncAuto trange %0.1f_%0.1f -2.0_20.0 glmSolv…'
            %         }
            %
            section = cell(length(obj.fcalls), 1);
            for ii=1:length(obj.fcalls)
                section{ii} = obj.fcalls(ii).Encode();
            end
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function err = ParseFile(obj, fid, type, reg)
            %
            % Processing stream config file parser. This function handles
            % group, subj and run processing stream parameters
            %
            % Example:
            %  
            %    Create a ProcInputClass object and load the function calls
            %    from the proc stream config file './processOpt_default.cfg'
            % 
            %    fid = fopen('./processOpt_default.cfg');
            %    p = ProcInputClass();
            %    p.ParseFile(fid, 'run');
            %    fclose(fid);
            %
            %    Here's some of the output 
            %
            %    p
            %
            %        ===> ProcInputClass with properties:
            %
            %            fcalls: [1x6 FuncCallClass]
            %     CondName2Subj: []
            %      CondName2Run: []
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
            %              help: '  Excludes stims that fall within the time points identified as …'
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
            %              help: '  Excludes stims that fall within the time points identified as …'
            %
            
            err=-1;
            if ~exist('fid','var') || ~iswholenum(fid) || fid<0
                return;
            end
            if ~exist('type','var')
                return;
            end
            if ~exist('reg','var')
                reg = RegistriesClass().empty();
            end
            [G, S, R] = obj.FindSections(fid);
            switch(lower(type))
                case {'group', 'groupclass', 'grp'}
                    obj.Decode(G, reg);
                case {'subj', 'session', 'subjclass'}
                    obj.Decode(S, reg);
                case {'run', 'runclass'}
                    obj.Decode(R, reg);
                otherwise
                    return;
            end
            err=0;
        end
        
        
        % ----------------------------------------------------------------------------------
        function Decode(obj, section, reg)
            % Syntax:
            %    obj.Decode(section, reg)
            %    
            % Description:
            %    Parse a cell array of strings, each string an encoded hmr*.m function call
            %    and into the FuncCallClass array of this ProcInputClass object. 
            %
            % Input: 
            %    A section contains encoded strings for one or more hmr* user function calls.
            %   
            % Example:
            %
            %    fcallStrs{1} = '@ hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.010 lpf %0.3f 0.500';
            %    fcallStrs{2} = '@ hmrR_OD2Conc dc (dod,SD ppf %0.1f_%0.1f 6_6';
            %
            %    p = ProcInputClass();
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
            %          help: '  Perform a bandpass filter…'
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
            %          help: '  Convert OD to concentrations…'
            % 
            if nargin<2
                return
            end
            if nargin<3
                reg = RegistriesClass.empty();
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
                    
                    % If registry was not passed down to us, then add fcall entries unconditionally. 
                    % Otherwise only include those user function calls that exist in the registry. 
                    if temp.GetErr()==0 && (isempty(reg) || ~isempty(reg.GetUsageName(temp)))
                        obj.fcalls(kk) = FuncCallClass(temp, reg);                                                
                        kk=kk+1;
                    else
                        fprintf('Entry not found in registry: "%s"\n', section{ii})
                    end
                end
            end            
        end
        

        
        % ----------------------------------------------------------------------------------
        function Add(obj, new, reg)
            if ~exist('reg','var')
                reg = Registries.empty();
            end
            idx = length(obj.fcalls)+1;
            obj.fcalls(idx) = FuncCallClass(new, reg);
        end
        
        
        % ----------------------------------------------------------------------------------
        function section = Encode(obj)
            % Syntax:
            %    section = obj.Encode()
            % 
            % Description:
            %    Generate a cell array of encoded string function calls from 
            %    the FuncCallClass array of this ProcInputClass object. 
            %
            % Input:
            %    A section contains encoded strings for one or more hmr* user function calls.
            %   
            % Example:
            %
            %    fcallStrs{1} = '@ hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.010 lpf %0.3f 0.500';
            %    fcallStrs{2} = '@ hmrR_OD2Conc dc (dod,SD ppf %0.1f_%0.1f 6_6';
            %
            %    p = ProcInputClass();
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
        function CreateDefault(obj, reg)
            if ~isa(reg, 'RegistriesClass')
                return;
            end
            obj.fcallStrEncodedGroup(reg);
            obj.fcallStrEncodedSubj(reg);
            obj.fcallStrEncodedRun(reg);
        end
        
        
        % ----------------------------------------------------------------------------------
        function obj2 = GetDefault(obj, type, reg)
            if nargin<3
                reg = RegistriesClass.empty();
            end
            obj2 = ProcInputClass();
            switch(lower(type))
                case {'group', 'groupclass'}
                    obj2.Decode(obj.fcallStrEncodedGroup, reg);
                case {'subj', 'session', 'subjclass'}
                    obj2.Decode(obj.fcallStrEncodedSubj, reg);
                case {'run', 'runclass'}
                    obj2.Decode(obj.fcallStrEncodedRun, reg);
                otherwise
                    return;
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods implementing static variables for this class. The static variable 
    % for this class are the default function call chains for group, subject and run. 
    % There is only one instance of each of these because these variables are the 
    % same for all instances of the ProcInputClass class
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function val = fcallStrEncodedGroup(obj, reg)
            persistent v;
            if nargin>1
                iG = reg.igroup;
                tmp = {...
                    reg.funcReg(iG).GetUsageStrDecorated('hmrG_BlockAvg','dcAvg'); ...
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
        function val = fcallStrEncodedSubj(obj, reg)
            persistent v;
            if nargin>1
                iS = reg.isubj;
                tmp = {...
                    reg.funcReg(iS).GetUsageStrDecorated('hmrS_BlockAvg','dcAvg'); ...
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
        function val = fcallStrEncodedRun(obj, reg)
            persistent v;
            if nargin>1
                iR = reg.irun;
                tmp = {...
                    reg.funcReg(iR).GetUsageStrDecorated('hmrR_Intensity2OD'); ...
                    reg.funcReg(iR).GetUsageStrDecorated('hmrR_BandpassFilt'); ...
                    reg.funcReg(iR).GetUsageStrDecorated('hmrR_OD2Conc'); ...
                    reg.funcReg(iR).GetUsageStrDecorated('hmrR_BlockAvg','dcAvg'); ...
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
        
end

