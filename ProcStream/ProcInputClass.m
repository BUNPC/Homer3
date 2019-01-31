classdef ProcInputClass < matlab.mixin.Copyable
    %
    % ProcInputClass stores processing stream input parameters that are independent 
    % of acquisition data or is derived from acquisition data but not stored there. 
    %
    properties
        func;           % Processing stream functions
        param;          % Processing stream user-settable input arguments and their current values
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
            obj.func = FuncClass().empty();
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
            if isempty(obj.func)
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
        function [filename, pathname] = CreateDefaultConfigFile(obj, funcReg)
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
                    obj.FileGenDefConc(filename, 'group', funcReg);
                    obj.FileGenDefConc(filename, 'subj', funcReg);
                    obj.FileGenDefConc(filename, 'run', funcReg);
                end
            else
                filename = [pathname filename];
            end
        end
        
                
        % ----------------------------------------------------------------------------------
        function FileGenDefConc(obj, filepath, type, funcReg)            
            % Generates default processOpt.cfg file.
            % Note that fprintf outputs formatted textstr where some characters
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
                    contents = obj.DefaultFileGroupConc(funcReg);
                case 'subj'
                    contents = obj.DefaultFileSubjConc(funcReg);
                case 'run'
                    contents = obj.DefaultFileRunConc(funcReg);
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
        function [contents, str] = DefaultFileGroupConc(obj, funcReg)            
            contents = {...
                '%% group\n', ...
                funcReg.FindUsageGroup('hmrG_BlockAvg','dcAvg'), ...
                '\n\n', ...
            };
            str = cell2str(contents);
        end
        
                
        % ----------------------------------------------------------------------------------
        function [contents, str] = DefaultFileSubjConc(obj, funcReg)
            contents = {...
                '%% subj\n', ...
                funcReg.FindUsageSubj('hmrS_BlockAvg','dcAvg'), ...
                '\n\n', ...
            };
            str = cell2str(contents);            
        end
        
        
        % ----------------------------------------------------------------------------------
        function [contents, str] = DefaultFileRunConc(obj, funcReg)
            contents = {...
                '%% run\n', ...
                funcReg.FindUsageRun('hmrR_Intensity2OD'), ...
                funcReg.FindUsageRun('hmrR_MotionArtifact'), ...
                funcReg.FindUsageRun('hmrR_BandpassFilt'), ...
                funcReg.FindUsageRun('hmrR_OD2Conc'), ...
                funcReg.FindUsageRun('hmrR_StimRejection'), ...
                funcReg.FindUsageRun('hmrR_BlockAvg','dcAvg') ...
                '\n\n', ...
                };
            str = cell2str(contents);
        end
        
        
        % ----------------------------------------------------------------------------------
        function DefaultConc(obj, type, funcReg)
            obj.param = struct([]);
            filecontents_str = '';
            switch(type)
                case 'group'
                    [~, filecontents_str] = obj.DefaultFileGroupConc(funcReg);
                case 'subj'
                    [~, filecontents_str] = obj.DefaultFileSubjConc(funcReg);
                case 'run'
                    [~, filecontents_str] = obj.DefaultFileRunConc(funcReg);
            end
            S = textscan(filecontents_str,'%s');
            obj.Parse(S{1});
            obj.SetHelp();
        end
        
        
        % ----------------------------------------------------------------------------------
        function [G, S, R] = PreParse(obj, fid_or_str, type)
            T = textscan(fid_or_str,'%s');
            if isempty(T{1})
                return;
            end
            Sections = obj.findSections(T{1});
            if ischar(fid_or_str)
                for ii=1:length(Sections)
                    if ~strcmp(Sections{ii}{2}, 'group') && ~strcmp(Sections{ii}{2}, 'subj') && ~strcmp(Sections{ii}{2}, 'run')
                        switch(type)
                            case 'group'
                                Sections{ii} = [{'%'}, {'group'}, Sections{ii}];
                            case 'subj'
                                Sections{ii} = [{'%'}, {'subj'}, Sections{ii}];
                            case 'run'
                                Sections{ii} = [{'%'}, {'run'}, Sections{ii}];
                        end
                    end
                end
            end
            [G, S, R] = obj.consolidateSections(Sections);
        end
                
        
        % ----------------------------------------------------------------------------------
        function Parse(obj, textstr, ifunc)
            % Parse functions and parameters
            % function call, param, param_format, param_value
            % name{}, argOut{}, argIn{}, nParam(), param{nFunc}{nParam},
            % paramFormat{nFunc}{nParam}, paramVal{nFunc}{nParam}()
            obj.param = struct([]);
            nstr = length(textstr);
            if ~exist('ifunc','var') || isempty(ifunc)
                ifunc = 0;
            else
                ifunc = ifunc-1;
            end
            flag = 0;
            for ii=1:nstr
                if flag==0 || textstr{ii}(1)=='@'
                    if textstr{ii}=='%'
                        flag = 999;
                    elseif textstr{ii}=='@'                        
                        ifunc = ifunc+1;
                        k = findstr(textstr{ii+1},',');
                        obj.func(ifunc) = FuncClass();
                        if ~isempty(k)
                            obj.func(ifunc).name = textstr{ii+1}(1:k-1);
                            obj.func(ifunc).nameUI = textstr{ii+1}(k+1:end);
                            k = findstr(obj.func(ifunc).nameUI,'_');
                            obj.func(ifunc).nameUI(k)=' ';
                        else
                            obj.func(ifunc).name = textstr{ii+1};
                            obj.func(ifunc).nameUI = obj.func(ifunc).name;
                        end
                        obj.func(ifunc).argOut = textstr{ii+2};
                        obj.func(ifunc).argIn = textstr{ii+3};
                        flag = 3;
                    else
                        if(textstr{ii} == '*')
                            obj.func(ifunc).nParamVar = 1;
                        elseif(textstr{ii} ~= '*')
                            obj.func(ifunc).nParam = obj.func(ifunc).nParam + 1;
                            obj.func(ifunc).param{obj.func(ifunc).nParam} = textstr{ii};
                            
                            for jj = 1:length(textstr{ii+1})
                                if textstr{ii+1}(jj)=='_'
                                    textstr{ii+1}(jj) = ' ';
                                end
                            end
                            obj.func(ifunc).paramFormat{obj.func(ifunc).nParam} = textstr{ii+1};
                            
                            for jj = 1:length(textstr{ii+2})
                                if textstr{ii+2}(jj)=='_'
                                    textstr{ii+2}(jj) = ' ';
                                end
                            end
                            val = str2num(textstr{ii+2});
                            obj.func(ifunc).paramVal{obj.func(ifunc).nParam} = val;
                            if(textstr{ii} ~= '*')
                                eval( sprintf('obj.param(1).%s_%s = val;',obj.func(ifunc).name, obj.func(ifunc).param{obj.func(ifunc).nParam}) );
                            end
                            obj.func(ifunc).nParamVar = 0;
                        end
                        flag = 2;
                    end
                else
                    flag = flag-1;
                end
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Help related methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ---------------------------------------------------------------------
        function Sections = findSections(obj, T)
            % Function to extract the 3 proc stream sections - group, subj, and run -
            % from a processing stream config cell array.
            n=length(T);
            Sections={};
            kk=1;
            ii=1;
            while ii<=n
                if T{ii}=='%'
                    if (ii+1<=n) & (strcmp(T{ii+1},'group') | strcmp(T{ii+1},'subj') | strcmp(T{ii+1},'run') | T{ii+1}=='@')
                        Sections{kk}{1} = T{ii};
                        jj=2;
                        for mm=ii+1:n
                            Sections{kk}{jj} = T{mm};
                            jj=jj+1;
                            if T{mm}=='%'
                                if (mm+1<=n) & (strcmp(T{mm+1},'group') | strcmp(T{mm+1},'subj') | strcmp(T{mm+1},'run'))
                                    break;
                                end
                            end
                        end
                        kk=kk+1;
                        ii=mm;
                        continue;
                    end
                elseif T{ii}=='@'
                    Sections{kk}{1} = T{ii};
                    jj=2;
                    for mm=ii+1:n
                        Sections{kk}{jj} = T{mm};
                        jj=jj+1;
                        if T{mm}=='%'
                            if (mm+1<=n) & (strcmp(T{mm+1},'group') | strcmp(T{mm+1},'subj') | strcmp(T{mm+1},'run'))
                                break;
                            end
                        end
                    end
                    kk=kk+1;
                    ii=mm;
                    continue;
                end
                ii=ii+1;
            end
        end
        
        
        % ---------------------------------------------------------------------
        function [G, S, R] = consolidateSections(obj, Sections)
            
            % This functions allows the functions for a run, subject or group
            % to be scattered. That is, you can multiple group, subject or run
            % sections; they'll be consolidated by this function into one group,
            % subject and run sections
            
            G={};
            S={};
            R={};
            jj=1; kk=1; ll=1;
            for ii=1:length(Sections)
                if Sections{ii}{1} ~= '%'
                    Sections{ii} = [{'%','run'},Sections{ii}];
                end
                if Sections{ii}{1} == '%' && (~strcmp(Sections{ii}{2},'group') && ~strcmp(Sections{ii}{2},'subj') && ~strcmp(Sections{ii}{2},'run'))
                    Sections{ii} = [{'%','run'},Sections{ii}];
                end
                
                if Sections{ii}{1} == '%' && strcmp(Sections{ii}{2},'group')
                    if isempty(G)
                        G = Sections{ii};
                    else
                        G = [G(1:end) Sections{ii}{3:end}];
                    end
                end
                if Sections{ii}{1} == '%' && strcmp(Sections{ii}{2},'subj')
                    if isempty(S)
                        S = Sections{ii};
                    else
                        S = [S(1:end) Sections{ii}(3:end)];
                    end
                end
                if Sections{ii}{1} == '%' && strcmp(Sections{ii}{2},'run')
                    if isempty(R)
                        R = Sections{ii};
                    else
                        R = [R(1:end) Sections{ii}(3:end)];
                    end
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetHelp(obj)
            for ii=1:length(obj.func)
                obj.func(ii).help = FuncHelpClass(obj.func(ii).name);
            end
        end
        
    end
    
end

