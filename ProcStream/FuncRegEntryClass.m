classdef FuncRegEntryClass < matlab.mixin.Copyable

    properties
        name
        uiname
        usageoptions
        params
        help
    end    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function obj = FuncRegEntryClass(filename)
            if nargin==0
                return;
            end
            [~,funcname] = fileparts(filename);
            obj.name = funcname;
            obj.uiname = '';
            obj.usageoptions = {};
            obj.params       = {};
            obj.help = FuncHelpClass(funcname);
            obj.GetUsage();
            obj.EncodeUsage();
        end

        
        % ----------------------------------------------------------------------------------
        function GetUsage(obj)
            %
            % Data flow for GetUsage:
            %   obj.help  --> GetUsage() --> {obj.usageoptions, obj.params}
            %
            [paramname, valformat] = obj.help.GetParamUsage();
            for ii=1:length(paramname)
                obj.params{ii,1} = paramname{ii};
                obj.params{ii,2} = valformat{ii};
            end
            [usage, friendlyname] = obj.help.GetUsageOptions();
            for ii=1:length(usage)
                obj.usageoptions{ii,1} = friendlyname{ii};
                obj.usageoptions{ii,2} = usage{ii};
            end            
            obj.uiname = obj.help.GetUiname();
        end
        
        
        % ----------------------------------------------------------------------------------
        function EncodeUsage(obj)
            % This function takes all usage cases and encodes them into registry language
            % Data flow for EncodeUsage:
            %   {obj.usageoptions{:,2}, obj.params} --> EncodeUsage() --> obj.usageoptions{:,3}
            %
            % Formal description of encoding for the generic function:  
            %
            % [r11,...,r1N] = F(a11,...,a1M,p1,...,pL)  
            % p1: [v11, ..., v1S1]
            %  ...  
            % pL: [vL1, ..., vLSL]
            % ===> F [r11,...,r1N] (a11,...,a1M p1 <v11_form>_..._<v1S1_form> v11 ... v1S1 ... pL <vL1_form>_..._<vLSL_form> vL1 ... vLSL
            %
            % Examples converting the "USAGE OPTIONS" and "PARAMETERS" section from the help to a registry encoding:
            %
            % dod = hmrR_BandpassFilt( dod, t, hpf, lpf )
            % hpf: [0.000]
            % lpf: [0.050]
            % ===> hmrR_BandpassFilt dod (dod,t hpf %0.3f 0 lpf %0.2f 3
            %
            % SD = hmrR_PruneChannels(d,SD,tInc,dRange,SNRthresh,SDrange,reset)
            % dRange: [1e4, 1e7]
            % SNRthresh: 2
            % SDrange: [0, 45]
            % reset: 0
            % ===> hmrR_PruneChannels SD (d,SD,tIncMan dRange %.0e_%.0e 1e4_1e7 SNRthresh %d 2 reset %d 0
            %
            % [dcAvg, dcAvgStd, tHRF, nTrials, dcSum2] = hmrR_BlockAvg( dc, s, t, trange )
            % trange: [-2.10, 20.30]
            % ===> hmrR_BlockAvg [dcAvg,dcAvgStd,tHRF,nTrials,dcSum2] (dc,s,t trange %0.1f_%0.1f -2_20
            %
            %
            for ii=1:size(obj.usageoptions,1)
                usage = obj.usageoptions{ii,2};
                
                % F
                encoding = sprintf('%s ', obj.name);
                
                % [r11,...,r1N]
                iequals = find(usage == '=');
                if isempty(iequals)
                    continue;
                end
                argout = usage(1:iequals-1);
                argout(argout==' ')='';
                encoding = sprintf('%s%s ', encoding, argout);
                
                % (a11,...,a1M
                iparenopen = find(usage == '(');
                iparenclose = find(usage == ')');
                if isempty(iparenopen) 
                    continue;
                end
                if isempty(iparenclose)
                    continue;
                end
                argin = usage(iparenopen:iparenclose-1);
                argin(argin==' ')='';
                if ~isempty(obj.params)
                    k = strfind(argin, obj.params{1,1});
                    argin = argin(1:k-1);
                    if ~isempty(argin) && ~isalpha_num(argin(end))
                        argin(end)='';
                    end
                end
                encoding = sprintf('%s%s ', encoding, argin);
                
                % p1 <v11_form>_..._<v1S_form> v11 ... v1S ... pL <vL1_form>_..._<vLS_form> vL1 ... vLS
                p='';
                for jj=1:size(obj.params,1)
                    p = sprintf('%s%s %s ',p, obj.params{jj,1}, obj.EncodeParamFormat(jj));
                end
                encoding = strtrim(sprintf('%s%s ', encoding, p));
                
                obj.usageoptions{ii,3} = encoding;
            end            
        end
        
        
        % ----------------------------------------------------------------------------------
        function encoding = EncodeParamFormat(obj, idx)
            encoding = obj.params{idx,2};
        end        
        
        
    end
    
end
