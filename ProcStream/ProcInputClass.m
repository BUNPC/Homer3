classdef ProcInputClass < matlab.mixin.Copyable
    %
    % ProcInputClass stores processing stream input parameters that are independent 
    % of acquisition data or is derived from acquisition data but not stored there. 
    %
    properties
        fcalls;         % Processing stream functions
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
            obj.fcalls = FuncCallClass().empty();
            obj.CondName2Subj = [];
            obj.CondName2Run = [];            
            obj.tIncMan = [];
            obj.misc = [];
            obj.changeFlag = 0;
        end
                
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            if isproperty(obj2, 'fcalls')
                obj.fcalls = obj2.fcalls;
            end
            if isproperty(obj2, 'changeFlag')
                obj.changeFlag = obj2.changeFlag;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function b = isempty(obj)
            b = true;
            if isempty(obj.fcalls)
                return
            end
            if isempty(obj.fcalls(1).name)
                return;
            end
            b = false;
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
            obj.fcalls(iFcall).paramIn(iParam).value = val;
            str = sprintf(obj.fcalls(iFcall).paramIn(iParam).format, val);
        end

        
        % ----------------------------------------------------------------------------------
        function b = IsEmpty(obj)            
            b=0;
            if isempty(obj.fcalls)
                b=1;
                return;
            end
            
            % Now that we know we have a non-empty fcalls, check to see if at least
            % one VALID function is present
            b=1;
            for ii=1:length(obj.fcalls)
                if ~isempty(obj.fcalls(ii).name) && ~isempty(obj.fcalls(ii).argOut)
                    b=0;
                    return;
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function args = GetInputArgs(obj, iFcall)
            args={};
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
                if obj.fcalls(iFcall(jj)).argIn(1) ~= '('
                    continue;
                end
                j=2;
                k = [strfind(obj.fcalls(iFcall(jj)).argIn,',') length(obj.fcalls(iFcall(jj)).argIn)+1];
                for ii=1:length(k)
                    args{kk} = obj.fcalls(iFcall(jj)).argIn(j:k(ii)-1);
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
        function [sargin, p] = ParseInputParams(obj, iFcall)
            sargin = '';            
            nParam = length(obj.fcalls(iFcall).paramIn);
            
            p = cell(nParam, 1);

            if isempty(obj.fcalls)
                return;
            end
            if iFcall>length(obj.fcalls)
                return;
            end
            
            sarginVal = '';
            for iP = 1:nParam
                p{iP} = obj.fcalls(iFcall).paramIn(iP).value;
                if length(obj.fcalls(iFcall).argIn)==1 & iP==1
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
            sargout = obj.fcalls(iFcall).argOut;
            for ii=1:length(obj.fcalls(iFcall).argOut)
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
        function name = GetFcallNamePrettyPrint(obj, iFcall)
            name = '';
            if isempty(obj.fcalls)
                return;                
            end
            if iFcall>length(obj.fcalls)
                return;
            end
            k = find(obj.fcalls(iFcall).name=='_');
            if isempty(k)
                name = obj.fcalls(iFcall).name;
            else
                name = sprintf('%s\\%s...', obj.fcalls(iFcall).name(1:k-1), obj.fcalls(iFcall).name(k:end));
            end            
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetFuncCallNum(obj)
            n = length(obj.fcalls);
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
        function [filename, pathname] = CreateDefaultConfigFile(obj, reg)
            % This pause is a workaround for a matlab bug in version
            % 7.11 for Linux, where uigetfile won't block unless there's
            % a breakpoint.
            pause(.5);
            [filename, pathname] = uigetfile('*.cfg', 'Load Process Options File' );
            if filename==0
                menu( sprintf('Loading default config file.'),'Okay');
                filename = './processOpt_default.cfg';
                success = true;
                if exist(filename,'file')
                    delete(filename);
                    if exist(filename,'file')
                        success = false;
                    end
                end
                if success
                    obj.FileGenDefConc(filename, 'group', reg);
                    obj.FileGenDefConc(filename, 'subj', reg);
                    obj.FileGenDefConc(filename, 'run', reg);
                end
            else
                filename = [pathname, filename];
            end
        end
        
                
        % ----------------------------------------------------------------------------------
        function FileGenDefConc(obj, filepath, type, reg)
            % Generates default processOpt.cfg file.
            % Note that fprintf outputs formatted textstr where some characters
            % are special characters - such as '%'. In order to write a
            % literal '%' you need to type '%%' in fprintf argument string
            % (2nd argument).
            %
            if ischar(filepath)
                slashes = [strfind(filepath,'/') strfind(filepath,'\')];
                if(~isempty(slashes))
                    filename = ['.' filepath(slashes(end):end)];
                end
                fid = fopen(filename,'a');
            else
                fid = filepath;
            end
            
            switch(type)
                case 'group'
                    contents = obj.DefaultFileGroupConc(reg);
                case 'subj'
                    contents = obj.DefaultFileSubjConc(reg);
                case 'run'
                    contents = obj.DefaultFileRunConc(reg);
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
        function [contents, str] = DefaultFileGroupConc(obj, reg)
            contents = {};
            if isempty(reg)
                return;
            end
            iG = reg.IdxGroup();
            contents = {...
                '%% group\n', ...
                reg.funcReg(iG).FindUsage('hmrG_BlockAvg','dcAvg'), ...
                '\n\n', ...
            };
            str = cell2str(contents);
        end
        
                
        % ----------------------------------------------------------------------------------
        function [contents, str] = DefaultFileSubjConc(obj, reg)
            contents = {};
            if isempty(reg)
                return;
            end
            iS = reg.IdxSubj();
            contents = {...
                '%% subj\n', ...
                reg.funcReg(iS).FindUsage('hmrS_BlockAvg','dcAvg'), ...
                '\n\n', ...
            };
            str = cell2str(contents);            
        end
        
        
        % ----------------------------------------------------------------------------------
        function [contents, str] = DefaultFileRunConc(obj, reg)
            contents = {};
            if isempty(reg)
                return;
            end
            iR = reg.IdxRun();
            contents = {...
                '%% run\n', ...
                reg.funcReg(iR).FindUsage('hmrR_Intensity2OD'), ...
                reg.funcReg(iR).FindUsage('hmrR_MotionArtifact'), ...
                reg.funcReg(iR).FindUsage('hmrR_BandpassFilt'), ...
                reg.funcReg(iR).FindUsage('hmrR_OD2Conc'), ...
                reg.funcReg(iR).FindUsage('hmrR_StimRejection'), ...
                reg.funcReg(iR).FindUsage('hmrR_BlockAvg','dcAvg') ...
                '\n\n', ...
                };
            str = cell2str(contents);
        end
        
        
        % ----------------------------------------------------------------------------------
        function DefaultFileConc(obj, type, reg)
            filecontents_str = '';
            switch(type)
                case 'group'
                    [~, filecontents_str] = obj.DefaultFileGroupConc(reg);
                case 'subj'
                    [~, filecontents_str] = obj.DefaultFileSubjConc(reg);
                case 'run'
                    [~, filecontents_str] = obj.DefaultFileRunConc(reg);
            end
            S = textscan(filecontents_str,'%s');
            obj.Parse(S{1});
        end
        
        
        % ---------------------------------------------------------------------
        % Function to extract the 3 proc stream sections - group, subj, and run -
        % from a processing stream config cell array.
        % ---------------------------------------------------------------------
        function [G, S, R] = FindSections(obj, fid)
            G = {};
            S = {};
            R = {};
            if ~iswholenum(fid) || fid<0
                return;
            end
            iG=1;
            iS=1;
            iR=1;
            section = 'run';   % Run is the default is sections aren't labeled
            while ~feof(fid)
                ln = strtrim(fgetl(fid));
                if isempty(ln)
                    continue;
                end
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
                            G{iG} = strtrim(ln); iG=iG+1;
                        case {'subj','subject','session','sess'}
                            S{iS} = strtrim(ln); iS=iS+1;
                        case {'run'}
                            R{iR} = strtrim(ln); iR=iR+1;
                    end                    
                end
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
            switch(type)
                case {'group', 'GroupClass'}
                    % generate default contents for group section if there's no % group header.
                    if isempty(G)
                        G = obj.DefaultFileGroupConc(reg);
                    end
                    obj.Parse(G);
                case {'subj', 'SubjClass'}
                    % generate default contents for subject section there's no % subj header. 
                    if isempty(S)
                        S = obj.DefaultFileSubjConc(reg);
                    end
                    obj.Parse(S);
                case {'run', 'RunClass'}
                    % generate default contents for subject section there's no % run header. 
                    if isempty(R)
                        R = obj.DefaultFileRunConc(reg);
                    end
                    obj.Parse(R);
                otherwise
                    return;
            end            
            err=0;
        end
        
        
        % ----------------------------------------------------------------------------------
        function Parse(obj, section)
            % Syntax:
            %    Parse(section)
            %    
            % Description:            
            %    Parse a cell array of strings, each string an encoded hmr*.m function call
            %    into a FuncCallClass object. 
            %
            % Input: 
            %    A section contains encoded strings for one or more hmr* user function calls.
            %   
            % Example:
            %
            %    fcalls{1} = '@ hmrR_BandpassFilt dod (dod,t hpf %0.3f 0.010 lpf %0.3f 0.500';
            %    fcalls{2} = '@ hmrR_OD2Conc dc (dod,SD ppf %0.1f_%0.1f 6_6';
            %
            %    p = ProcInputClass();
            %    p.Parse(fcalls);
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
                    if kk>length(obj.fcalls)
                        obj.fcalls(kk) = FuncCallClass(section{ii});
                    else
                        obj.fcalls(kk).Parse(section{ii});
                    end
                    kk=kk+1;
                end    
            end
        end
     
        
    end   
end

