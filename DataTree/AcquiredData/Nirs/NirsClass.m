classdef NirsClass < AcqDataClass & FileLoadSaveClass
    
    properties
        SD;
        t;
        s;
        d;
        aux;
        CondNames;
    end    

    % Properties not part of the NIRS format. These parameters aren't loaded or saved to nirs files
    properties (Access = private)
        errmargin
    end    
    
    methods
        
        % ---------------------------------------------------------
        function obj = NirsClass(filename)
            obj.SD        = struct([]);
            obj.t         = [];
            obj.s         = [];
            obj.d         = [];
            obj.aux       = [];
            obj.CondNames = {};

            % Set base class properties not part of NIRS format 
            obj.filename  = '';
            obj.fileformat = 'mat';
            obj.errmargin = 1e-3;
            
            if ~exist('filename','var') || ~exist(filename,'file')
                return;
            end
            obj.Load(filename);
        end
        
        
        % ---------------------------------------------------------
        function SortStims(obj)
            [~,idx] = sort(obj.CondNames);
            obj.CondNames = obj.CondNames(idx);
            obj.s = obj.s(:,idx);            
        end
        
        
        % ---------------------------------------------------------
        function err = LoadMat(obj, fname)
            err = 0;
            
            % Arg 1
            if ~exist('fname','var') || ~exist(fname,'file')
                fname = '';
            end
                       
            % Do some error checking            
            if ~isempty(fname)
                obj.filename = fname;
            else
                fname = obj.filename;
            end
            if isempty(fname)
               err=-1;
               return;
            end
                        
            warning('off', 'MATLAB:load:variableNotFound');
            fdata = load(fname,'-mat', 'SD','t','d','s','aux','CondNames');
            if isproperty(fdata,'d')
                obj.d = fdata.d;
            end
            if isproperty(fdata,'t')
                obj.t = fdata.t;
            end
            if isproperty(fdata,'SD')
                obj.SetSD(fdata.SD);
            end
            if isproperty(fdata,'s')
                obj.s = fdata.s;
            end
            if isproperty(fdata,'aux')
                obj.aux = fdata.aux;
            end
            if isproperty(fdata,'CondNames')
                obj.CondNames = fdata.CondNames;
            else
                obj.InitCondNames();
            end
            if ~isempty(obj.t)
                obj.errmargin = min(diff(obj.t))/10;
            end
            obj.SortStims();
        end
        
        
        
        % ---------------------------------------------------------
        function SaveMat(obj, fname)
            if ~exist('fname','var') || isempty(fname)
                fname = '';
            end
            if isempty(fname)
                fname = obj.filename;
            end
            
            SD        = obj.SD;
            s         = obj.s;
            CondNames = obj.CondNames;
            save(fname, '-mat', '-append', 'SD','s','CondNames');            
        end
                
        
        % ---------------------------------------------------------
        function nTrials = InitCondNames(obj)
            if isempty(obj.CondNames)
                obj.CondNames = repmat({''},1,size(obj.s,2));
            end
            for ii=1:size(obj.s,2)
                if isempty(obj.CondNames{ii})
                    % Make sure not to duplicate a condition name
                    jj=0;
                    kk=ii+jj;
                    condName = num2str(kk);
                    while ~isempty(find(strcmp(condName, obj.CondNames)))
                        jj=jj+1;
                        kk=ii+jj;
                        condName = num2str(kk);
                    end
                    obj.CondNames{ii} = condName;
                else
                    % Check if CondNames{ii} has a name. If not name it but
                    % make sure not to duplicate a condition name
                    k = find(strcmp(obj.CondNames{ii}, obj.CondNames));
                    if length(k)>1
                        % Unname and then rename duplicate condition
                        obj.CondNames{ii} = '';
                        
                        jj=0;
                        while find(strcmp(num2str(ii), obj.CondNames))
                            kk=ii+jj;
                            obj.CondNames{ii} = num2str(kk);
                            jj=jj+1;
                        end
                    end
                end
            end
            nTrials = sum(obj.s,1);
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Basic methods to Set/Get native variable 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        % ---------------------------------------------------------
        function SetD(obj, val)
            obj.d = val;            
        end
        
        % ---------------------------------------------------------
        function val = GetD(obj)
            val = obj.d;
        end
        
        % ---------------------------------------------------------
        function SetT(obj, val)
            obj.t = val;
        end
        
        % ---------------------------------------------------------
        function val = GetT(obj)
            val = obj.t;
        end
        
        % ---------------------------------------------------------
        function SetSD(obj, val)
            obj.SD = val;            
        end
        
        % ---------------------------------------------------------
        function val = GetSD(obj)
            val = obj.SD;
        end
        
        % ---------------------------------------------------------
        function SetS(obj, val)
            obj.s = val;
        end
        
        % ---------------------------------------------------------
        function val = GetS(obj)
            val = obj.s;
        end
        
        % ---------------------------------------------------------
        function SetAux(obj, val)
            obj.aux = val;        
        end
        
        % ---------------------------------------------------------
        function val = GetAux(obj)
            val = obj.aux;
        end
        
        % ---------------------------------------------------------
        function SetCondNames(obj, val)
            obj.CondNames = val;            
        end
        
        % ---------------------------------------------------------
        function val = GetCondNames(obj)
            val = obj.CondNames;
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods that must be implemented as a child class of AcqDataClass
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        % ---------------------------------------------------------
        function t = GetTime(obj, iDataBlk)
            t = obj.t;
        end
        
        
        % ---------------------------------------------------------
        function datamat = GetDataMatrix(obj, iDataBlk)
            datamat = obj.d;
        end
        
        
        % ---------------------------------------------------------
        function SD = GetSDG(obj)
            SD = obj.SD;
        end
        
        
        % ---------------------------------------------------------
        function SetSDG(obj, SD)
            obj.SD = SD;
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj, iDataBlk)
            ml = obj.SD.MeasList;
        end
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.SD.Lambda;
        end
        
        
        % ---------------------------------------------------------
        function SetStims_MatInput(obj,s,t,CondNames)
            obj.s = s;
        end
                
        
        % ---------------------------------------------------------
        function s = GetStims(obj)
            s = obj.s;
        end
        
        
        % ---------------------------------------------------------
        function CondNames = GetConditions(obj)
            CondNames = obj.CondNames;
        end
                
        
        % ---------------------------------------------------------
        function srcpos = GetSrcPos(obj)
            srcpos = obj.SD.SrcPos;
        end
        
        
        % ---------------------------------------------------------
        function detpos = GetDetPos(obj)
            detpos = obj.SD.DetPos;
        end
        
        
        % ----------------------------------------------------------------------------------
        function aux = GetAuxiliary(obj)
            aux = struct('data', obj.aux, 'names',{{}});
            for ii=1:size(obj.aux, 2)
                if isproperty(obj.SD,'auxChannels')
                    aux.names{end+1} = obj.SD.auxChannels{ii};
                else
                    aux.names{end+1} = sprintf('Aux%d',ii);
                end
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function n = GetDataBlocksNum(obj)
            n = 1;
        end
        
        
        % ----------------------------------------------------------------------------------
        function params = MutableParams(obj)
            params = {'SD'};
            % params = {'SD','s'};
        end
        
        
        % ----------------------------------------------------------------------------------
        function [iDataBlks, ich] = GetDataBlocksIdxs(obj, ich)
            iDataBlks = 1;
        end

    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public interface for older processing stream
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function d = Get_d(obj)
            d = obj.d;
        end
        
        % ----------------------------------------------------------------------------------
        function t = Get_t(obj)
            t = obj.t;
        end
        
        % ----------------------------------------------------------------------------------
        function SD = Get_SD(obj)
            SD = obj.SD;
        end
        
        % ----------------------------------------------------------------------------------
        function aux = Get_aux(obj)
            aux = obj.aux;
        end
        
        % ----------------------------------------------------------------------------------
        function s = Get_s(obj)
            s = obj.s;
        end

        % ----------------------------------------------------------------------------------
        function CondNames = Get_CondNames(obj)
            CondNames = obj.CondNames;
        end
                
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for stims & conditions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function AddStims(obj, tPts, condition)
            k = find(strcmp(obj.CondNames, condition));
            if isempty(k)
                obj.s(:,end+1) = zeros(length(obj.t),1);
                icol = size(obj.s,2);
                obj.CondNames{icol} = condition;
            else
                icol = k;
            end      
            [~, tidx] = nearest_point(obj.t, tPts);
            obj.s(tidx, icol) = 1;
            obj.SortStims();
        end
        
        
        % ----------------------------------------------------------------------------------
        function DeleteStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var') || isempty(condition)
                j = 1:size(obj.s,2);
            else
                j = find(strcmp(obj.CondNames, condition));
            end
            if isempty(j)
                return;
            end
                        
            % Find all stims for any conditions which match the time points.
            k = [];
            for ii=1:length(tPts)
                k = [k, find( abs(obj.t-tPts(ii)) < obj.errmargin )];
            end
            obj.s(k,j) = 0;
        end
        
        
        % ----------------------------------------------------------------------------------
        function MoveStims(obj, tPts, condition)
            if ~exist('tPts','var') || isempty(tPts)
                return;
            end
            if ~exist('condition','var') || isempty(condition)
                return;
            end
            
            j = find(strcmp(obj.CondNames, condition));
            if isempty(j)
                % Destination condition wasn't found in data, so add new condition 
                j = size(obj.s,2)+1;
                obj.s(:,j) = zeros(1,length(obj.t));
                obj.CondNames{j} = condition;
                obj.SortStims();
                
                % Recalculate j after sort
                j = find(strcmp(obj.CondNames, condition));
            end
            
            % Find all stims for any conditions which match the time points.
            for ii=1:length(tPts)
                % Find index k in the time vector obj.t of time point tPts(ii)
                k = find( abs(obj.t-tPts(ii)) < obj.errmargin );
                
                % Find all columns is obj.s that are non-zero
                i = find(obj.s(k,:)~=0);
                if isempty(i)
                    continue;
                end
                if i(1)==j
                    continue;
                end
                
                % Move the first non-zero column stim to the destination
                % condition
                obj.s(k,j) = obj.s(k,i(1));
                obj.s(k,i(1)) = 0;
            end
        end
        
        
        % ----------------------------------------------------------------------------------
        function SetStimTpts(obj, icond, tpts)
            return;
        end
        
        
        % ----------------------------------------------------------------------------------
        function tpts = GetStimTpts(obj, icond)
            tpts = [];
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
        function SetStimValues(obj, icond, vals)
            return;
        end
        
        
        % ----------------------------------------------------------------------------------
        function vals = GetStimValues(obj, icond)
            vals = [];
        end
        
        
        % ----------------------------------------------------------------------------------
        function RenameCondition(obj, oldname, newname)
            if ~exist('oldname','var') || ~ischar(oldname)
                return;
            end
            if ~exist('newname','var')  || ~ischar(newname)
                return;
            end
            k = find(strcmp(obj.CondNames, oldname));
            if isempty(k)
                return;
            end
            obj.CondNames{k} = newname;
            obj.SortStims();
        end

    end
    
   
end

