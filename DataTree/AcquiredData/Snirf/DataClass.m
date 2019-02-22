classdef DataClass < FileLoadSaveClass
    
    properties
        d
        t
        ml
    end
    
    methods
        
        % -------------------------------------------------------
        function obj = DataClass(varargin)
            %
            %  Syntax:
            %     obj = DataClass()
            %     obj = DataClass(data)
            %     obj = DataClass(d,t,ml)
            %     
            %  Input:
            %
            %     data - When there's one argument, then data can be either
            %            NirsClass object or DataClass object. 
            %     d    - When there are three arguments, d is the data time course matrix
            %     t    - When there are three arguments, t is the data time vector
            %     ml   - When there are three arguments, ml is the measurent list, which 
            %            can be either a nirs style matrixor a MeasListClass object
            %
            obj.ml = MeasListClass().empty();
            if nargin==0 
                return;
            elseif nargin==1
                if ~isa(varargin{1}, 'DataClass') && ~isa(varargin{1}, 'NirsClass')
                    return;
                end                
                if isa(varargin{1}, 'DataClass')
                    obj.d = varargin{1}.d;
                    obj.t = varargin{1}.t;
                    for ii=1:length(varargin{1}.ml)
                        obj.ml(ii) = MeasListClass(varargin{1}.ml(ii));
                    end
                else
                    obj.d = varargin{1}.d;
                    obj.t = varargin{1}.t;
                    for ii=1:size(varargin{1}.ml,1)
                        obj.ml(ii) = MeasListClass(varargin{1}.ml(ii,:));
                    end
                end
            elseif nargin==3                
                if ~all(isreal(varargin{1}(:)))
                    return;
                end
                if ~all(isreal(varargin{2}(:)))
                    return;
                end
                if ~isa(varargin{3}, 'MeasListClass') && ~all(iswholenum(varargin{3}(:)))
                    return;
                end
                if isa(varargin{3}, 'MeasListClass')
                    obj.d = varargin{1};
                    obj.t = varargin{2};
                    for ii=1:length(varargin{3})
                        obj.ml(ii) = MeasListClass(varargin{3}(ii));
                    end
                else
                    obj.d = varargin{1};
                    obj.t = varargin{2};
                    for ii=1:size(varargin{3},1)
                        obj.ml(ii) = MeasListClass(varargin{3}(ii,:));
                    end
                end
            else
                obj.d = double([]);
                obj.t = double([]);
            end
        end
        


        % -------------------------------------------------------
        function err = LoadHdf5(obj, fname, parent)
            err = 0;
            if ~exist(fname, 'file')
                err = -1;
                return;
            end
            try
                obj.d = h5read(fname, [parent, '/d']);
                obj.t = h5read(fname, [parent, '/t']);
            catch
                err = -1;
                return;
            end
            
            ii=1;
            info = h5info(fname);
            while h5exist(info, [parent, '/ml_', num2str(ii)])
                if ii > length(obj.ml)
                    obj.ml(ii) = MeasListClass;
                end
                obj.ml(ii).LoadHdf5(fname, [parent, '/ml_', num2str(ii)]);
                ii=ii+1;
            end
        end
        
        
        % -------------------------------------------------------
        function SaveHdf5(obj, fname, parent)
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            
            hdf5write_safe(fname, [parent, '/d'], obj.d);
            hdf5write_safe(fname, [parent, '/t'], obj.t);
            
            for ii=1:length(obj.ml)
                obj.ml(ii).SaveHdf5(fname, [parent, '/ml_', num2str(ii)]);
            end
        end

        
        
        % -------------------------------------------------------
        function b = Empty(obj)
            b = false;
            if isempty(obj.d) && isempty(obj.t)
                b = true;
            end
        end
    
        
        % ---------------------------------------------------------
        function val = GetD(obj)
            val = obj.d;
        end
        
        
        % ---------------------------------------------------------
        function val = GetT(obj)
            val = obj.t;
        end
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.ml(1).GetWls();
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj)
            ml = zeros(length(obj.ml), 4);
            for ii=1:length(obj.ml)
                ml(ii,:) = [obj.ml(ii).GetSourceIndex(), obj.ml(ii).GetDetectorIndex(), 1, obj.ml(ii).GetWavelengthIndex()];
            end
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasListDod(obj)
            ml = zeros(length(obj.ml), 2);
            for ii=1:length(obj.ml)
                if  obj.ml(ii).GetWavelengthIndex()==1
                    ml(ii,:) = [obj.ml(ii).GetSourceIndex(), obj.ml(ii).GetDetectorIndex()];
                end
            end
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasListDc(obj)
            ml = zeros(length(obj.ml), 2);
            for ii=1:length(obj.ml)
                if  obj.ml(ii).GetDataTypeLabel()==6
                    ml(ii,:) = [obj.ml(ii).GetSourceIndex(), obj.ml(ii).GetDetectorIndex()];
                end
            end
        end
        
        
        % ---------------------------------------------------------
        function t = GetTime(obj)
            t = obj.t;
        end
        
        
        % ---------------------------------------------------------
        function datamat = GetDataMatrix(obj)
            datamat = obj.d;
        end
        
        
        % ---------------------------------------------------------
        function SetD(obj, val)
            if ~exist('val','var')
                return;
            end
            obj.d = val;
        end
        
        
        % ---------------------------------------------------------
        function SetT(obj, val)
            if ~exist('val','var')
                return;
            end
            obj.t = val;
        end
        
        
        % ---------------------------------------------------------
        function SetDataType(obj, type, subtype, chIdxs)
            if ~exist('type','var') ||  isempty(type)
                return;
            end
            if ~exist('subtype','var') ||  isempty(subtype)
                subtype = 1;
            end
            if ~exist('chIdxs','var') || isempty(chIdxs)
                chIdxs = 1:length(obj.ml);
            end
            for ii=chIdxs
                obj.ml(ii).SetDataType(type, subtype);
            end
        end
        
        
        % ---------------------------------------------------------
        function SetMl(obj, val)
            obj.ml = val.copy();
        end
        
        % ---------------------------------------------------------
        function val = GetMl(obj)
            val = obj.ml;
        end
        
        
        % ---------------------------------------------------------
        function val = GetDataType(obj)
            val = zeros(length(obj.ml),1);
            for ii=1:length(obj.ml)
                val(ii) = obj.ml(ii).GetDataType();
            end
        end
        
        % ---------------------------------------------------------
        function val = GetDataTypeLabel(obj, ch_idx)
            if ~exist('ch_idx','var')
                ch_idx = 1:length(obj.ml);
            end
            val = zeros(length(ch_idx),1);
            for ii=ch_idx
                val(ii) = obj.ml(ii).GetDataTypeLabel();
            end
        end

        
        % ---------------------------------------------------------
        function val = GetCondition(obj, ch_idx)
            if ~exist('ch_idx','var')
                ch_idx = 1:length(obj.ml);
            end
            val = zeros(length(ch_idx),1);
            for ii=ch_idx
                val(ii) = obj.ml(ii).GetCondition();
            end
        end
        
    end
    
    methods
        
        % ---------------------------------------------------------
        function AddChannelDc(obj, isrc, idet, dataTypeLabel, icond)
            if ~exist('isrc','var') || isempty(isrc)
                return;
            end
            if ~exist('idet','var') || isempty(idet)
                return;
            end
            if ~exist('dataType','var') || isempty(dataType)
                dataType = 1;
            end
            if ~exist('dataTypeLabel','var') || isempty(dataTypeLabel)
                dataTypeLabel = 0;
            end
            if ~exist('icond','var') || isempty(icond)
                icond = 0;
            end
            if icond==0
                obj.ml(end+1) = MeasListClass(isrc, idet, 1000, dataTypeLabel);
            else
                obj.ml(end+1) = MeasListClass(isrc, idet, 1000, dataTypeLabel, icond);
            end
        end
        
        
        % ---------------------------------------------------------
        function AddChannelDod(obj, isrc, idet, wl, icond)
            if ~exist('isrc','var') || isempty(isrc)
                return;
            end
            if ~exist('idet','var') || isempty(idet)
                return;
            end
            if ~exist('dataType','var') || isempty(dataType)
                dataType = 1;
            end
            if ~exist('dataTypeLabel','var') || isempty(dataTypeLabel)
                dataTypeLabel = 0;
            end
            if ~exist('icond','var') || isempty(icond)
                icond = 0;
            end
            if icond==0
                obj.ml(end+1) = MeasListClass(isrc, idet, 1000, 1);
            else
                obj.ml(end+1) = MeasListClass(isrc, idet, 1000, 1, icond);
            end
            obj.ml.SetWavelengthIndex(wl);
        end
        
        
        % ---------------------------------------------------------
        function AppendD(obj, y)
            obj.d(:, end+1:end+size(y(:,:),2)) = y(:,:);
        end
        
    end
    
    
    
    methods
        
        % ----------------------------------------------------------------------------------
        function objnew = copydeep(obj)
            objnew = DataClass();
            for ii=1:length(obj.ml)
                objnew.ml(ii) = obj.ml(ii).copy();
            end
            objnew.d = obj.d;
            objnew.t = obj.t;
        end
    end
end

