classdef DataClass < FileLoadSaveClass
    
    properties
        dataTimeSeries
        time
        measurementList
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
            %     data - When there's one argument, data can be either NirsClass object or 
            %            DataClass object. 
            %     d    - When there are three arguments, d is the data time course matrix
            %     t    - When there are three arguments, t is the data time vector
            %     ml   - When there are three arguments, ml is the measurent list, which 
            %            can be either a nirs style matrix or a MeasListClass object
            %
            %  Example:
            %    
            obj.measurementList = MeasListClass().empty();
            
            if nargin==0 
                return;
            elseif nargin==1
                if isa(varargin{1}, 'DataClass')
                    obj.Copy(varargin{1});
                elseif isa(varargin{1}, 'NirsClass')
                    obj.dataTimeSeries = varargin{1}.d;
                    obj.time = varargin{1}.t;
                    for ii=1:size(varargin{1}.ml,1)
                        obj.measurementList(end+1) = MeasListClass(varargin{1}.ml(ii,:));
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
                    obj.dataTimeSeries = varargin{1};
                    obj.time = varargin{2};
                    for ii=1:length(varargin{3})
                        obj.measurementList(end+1) = MeasListClass(varargin{3}(ii));
                    end
                else
                    obj.dataTimeSeries = varargin{1};
                    obj.time = varargin{2};
                    for ii=1:size(varargin{3},1)
                        obj.measurementList(end+1) = MeasListClass(varargin{3}(ii,:));
                    end
                end
            else
                obj.dataTimeSeries = double([]);
                obj.time = double([]);
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load/Save from/to file methods 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        % -------------------------------------------------------
        function err = LoadHdf5(obj, fname, parent)
            err = 0;
            if ~exist(fname, 'file')
                err = -1;
                return;
            end
            
            % Arg 2
            if ~exist('parent', 'var')
                parent = '/nirs/data1';
            elseif parent(1)~='/'
                parent = ['/',parent];
            end
            
            try
                obj.dataTimeSeries = h5read(fname, [parent, '/dataTimeSeries']);
                obj.time = h5read(fname, [parent, '/time']);
            catch
                err = -1;
                return;
            end
            
            ii=1;
            info = h5info(fname);
            while h5exist(info, [parent, '/measurementList', num2str(ii)])
                if ii > length(obj.measurementList)
                    obj.measurementList(ii) = MeasListClass;
                end
                obj.measurementList(ii).LoadHdf5(fname, [parent, '/measurementList', num2str(ii)]);
                ii=ii+1;
            end
        end
        
        
        % -------------------------------------------------------
        function SaveHdf5(obj, fname, parent)
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            
            hdf5write_safe(fname, [parent, '/dataTimeSeries'], obj.dataTimeSeries);
            hdf5write_safe(fname, [parent, '/time'], obj.time);
            
            for ii=1:length(obj.measurementList)
                obj.measurementList(ii).SaveHdf5(fname, [parent, '/measurementList', num2str(ii)]);
            end
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set/Get properties methods 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods        
        
        % -------------------------------------------------------
        function b = IsEmpty(obj)
            b = false;
            if isempty(obj)
                b = true;
            end
            if isempty(obj.dataTimeSeries) || isempty(obj.time) || isempty(obj.measurementList)
                b = true;
            end
            if isempty(obj.measurementList)
                return;
            end
        end
    
        
        % ---------------------------------------------------------
        function val = GetDataTimeSeries(obj)
            val = obj.dataTimeSeries;
        end
        
        
        % ---------------------------------------------------------
        function val = GetT(obj)
            val = obj.time;
        end
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.measurementList(1).GetWls();
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj)
            ml = [];
            for ii=1:length(obj.measurementList)
                % If this data contains block average then only get the measurements for first condition. That will 
                % contain all the measurement channels
                if obj.measurementList(ii).GetCondition()>1
                    break;
                end
                ml(ii,:) = [obj.measurementList(ii).GetSourceIndex(), obj.measurementList(ii).GetDetectorIndex(), 1, obj.measurementList(ii).GetWavelengthIndex()];
            end
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasListSrcDetPairs(obj)
            ml = zeros(0, 2);
            jj=1;
            for ii=1:length(obj.measurementList)
                if isempty(find(ml(:,1)==obj.measurementList(ii).GetSourceIndex() & ml(:,2)==obj.measurementList(ii).GetDetectorIndex()))
                    ml(jj,:) = [obj.measurementList(ii).GetSourceIndex(), obj.measurementList(ii).GetDetectorIndex()];
                    jj=jj+1;
                end
            end
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasListDod(obj)
            ml = zeros(length(obj.measurementList), 2);
            for ii=1:length(obj.measurementList)
                if  obj.measurementList(ii).GetWavelengthIndex()==1
                    ml(ii,:) = [obj.measurementList(ii).GetSourceIndex(), obj.measurementList(ii).GetDetectorIndex()];
                end
            end
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasListDc(obj)
            ml = zeros(length(obj.measurementList), 2);
            for ii=1:length(obj.measurementList)
                if  obj.measurementList(ii).GetDataTypeLabel()==6
                    ml(ii,:) = [obj.measurementList(ii).GetSourceIndex(), obj.measurementList(ii).GetDetectorIndex()];
                end
            end
        end
        
        
        % ---------------------------------------------------------
        function t = GetTime(obj)
            t = obj.time;
        end
        
        
        % ---------------------------------------------------------
        function d = GetDataMatrix(obj)
            d = [];
            if isempty(obj.dataTimeSeries)
                return;
            end
            
            % Get information for each ch in d matrix
            dataTypeLabels = {};
            srcDetPairs = zeros(0,2);
            conditions = [];
            wavelengths = [];
            hh=1; jj=1; kk=1; ll=1;
            for ii=1:length(obj.measurementList)
                if ~ismember(obj.measurementList(ii).GetDataTypeLabel(), dataTypeLabels)
                    dataTypeLabels{hh} = obj.measurementList(ii).GetDataTypeLabel(); 
                    hh=hh+1;
                end
                if isempty(find(srcDetPairs(:,1)==obj.measurementList(ii).GetSourceIndex() & srcDetPairs(:,2)==obj.measurementList(ii).GetDetectorIndex()))
                    srcDetPairs(jj,:) = [obj.measurementList(ii).GetSourceIndex(), obj.measurementList(ii).GetDetectorIndex()];
                    jj=jj+1;
                end
                if ~ismember(obj.measurementList(ii).GetCondition(), conditions)
                    conditions(kk) = obj.measurementList(ii).GetCondition();
                    kk=kk+1;
                end
                if ~ismember(obj.measurementList(ii).GetWavelengthIndex(), wavelengths)
                    wavelengths(ll) = obj.measurementList(ii).GetWavelengthIndex();
                    ll=ll+1;
                end
            end
            dim1 = length(obj.dataTimeSeries(:,1));
            if all(wavelengths(:)~=0) && all(conditions(:)==0)
                dim2 = length(wavelengths(:)) * size(srcDetPairs,1);
                dim3 = 1;
                dim4 = 1;
            elseif all(wavelengths(:)~=0) && all(conditions(:)~=0)
                dim2 = length(wavelengths(:)) * size(srcDetPairs,1);
                dim3 = length(conditions(:));
                dim4 = 1;
            elseif all(wavelengths(:)==0) && all(conditions(:)==0)
                dim2 = length(dataTypeLabels);
                dim3 = size(srcDetPairs,1);
                dim4 = 1;
            elseif all(wavelengths(:)==0) && all(conditions(:)~=0)
                dim2 = length(dataTypeLabels);
                dim3 = size(srcDetPairs,1);
                dim4 = length(conditions(:));
            end
            d = reshape(obj.dataTimeSeries, dim1, dim2, dim3, dim4);
        end
        
        
        % ---------------------------------------------------------
        function SetDataTimeSeries(obj, val)
            if ~exist('val','var')
                return;
            end
            obj.dataTimeSeries = val;
        end
        
        
        % ---------------------------------------------------------
        function SetTime(obj, val, datacheck)
            if ~exist('val','var')
                return;
            end
            if ~exist('datacheck','var')
                datacheck = false;
            end
            if isempty(obj.dataTimeSeries) && datacheck==true
                obj.time = [];
                return;
            end
            obj.time = val;
        end
        
        
        % ---------------------------------------------------------
        function SetDataType(obj, dataType, dataTypeLabel, chIdxs)
            if ~exist('dataType','var') ||  isempty(dataType)
                return;
            end
            if ~exist('dataTypeLabel','var') ||  isempty(dataTypeLabel)
                dataTypeLabel = '';
            end
            if ~exist('chIdxs','var') || isempty(chIdxs)
                chIdxs = 1:length(obj.measurementList);
            end
            for ii=chIdxs
                obj.measurementList(ii).SetDataType(dataType, dataTypeLabel);
            end
        end
        
        
        % ---------------------------------------------------------
        function SetDataTypeDod(obj)
            vals = DataTypeValues();
            for ii=1:length(obj.measurementList)
                obj.measurementList(ii).SetDataType(vals.Processed, 'dOD');
            end
        end
        
        
        
        % ---------------------------------------------------------
        function SetMl(obj, val)
            obj.measurementList = val.copy();      % shallow copy ok because MeasListClass has no handle properties 
        end
        
        
        % ---------------------------------------------------------
        function val = GetMl(obj)
            val = obj.measurementList;
        end
        
        
        % ---------------------------------------------------------
        function val = GetDataType(obj)
            val = zeros(length(obj.measurementList),1);
            for ii=1:length(obj.measurementList)
                val(ii) = obj.measurementList(ii).GetDataType();
            end
        end
        
        
        % ---------------------------------------------------------
        function val = GetDataTypeLabel(obj, ch_idx)
            if ~exist('ch_idx','var')
                ch_idx = 1:length(obj.measurementList);
            end
            val = repmat({''}, length(ch_idx),1);
            for ii=ch_idx
                val{ii} = obj.measurementList(ii).GetDataTypeLabel();
            end
            val = unique(val);
        end

        
        % ---------------------------------------------------------
        function val = GetCondition(obj, ch_idx)
            if ~exist('ch_idx','var')
                ch_idx = 1:length(obj.measurementList);
            end
            val = zeros(length(ch_idx),1);
            for ii=ch_idx
                val(ii) = obj.measurementList(ii).GetCondition();
            end
        end
        
    end
    
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Adding/deleting data methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ---------------------------------------------------------
        function AddChannelHb(obj, isrc, idet, iHb, icond)
            if ~exist('isrc','var') || isempty(isrc)
                return;
            end
            if ~exist('idet','var') || isempty(idet)
                return;
            end
            if ~exist('iHbType','var') || isempty(iHbType)
                iHb = 1;
            end
            if ~exist('icond','var') || isempty(icond)
                icond = 0;
            end
            switch(iHb)
                case 1
                    AddChannelHbO(obj, isrc, idet, icond);
                case 2
                    AddChannelHbR(obj, isrc, idet, icond);
                case 3
                    AddChannelHbT(obj, isrc, idet, icond);
            end
            
        end
        
        
        % ---------------------------------------------------------
        function AddChannelHbO(obj, isrc, idet, icond)
            if ~exist('isrc','var') || isempty(isrc)
                return;
            end
            if ~exist('idet','var') || isempty(idet)
                return;
            end
            if ~exist('icond','var') || isempty(icond)
                icond = 0;
            end
            vals = DataTypeValues();
            if icond==0
                obj.measurementList(end+1) = MeasListClass(isrc, idet, vals.Processed, 'HbO');
            else
                obj.measurementList(end+1) = MeasListClass(isrc, idet, vals.Processed, 'HRF HbO', icond);
            end
        end
        
        
        % ---------------------------------------------------------
        function AddChannelHbR(obj, isrc, idet, icond)
            if ~exist('isrc','var') || isempty(isrc)
                return;
            end
            if ~exist('idet','var') || isempty(idet)
                return;
            end
            if ~exist('icond','var') || isempty(icond)
                icond = 0;
            end
            vals = DataTypeValues();
            if icond==0
                obj.measurementList(end+1) = MeasListClass(isrc, idet, vals.Processed, 'HbR');
            else
                obj.measurementList(end+1) = MeasListClass(isrc, idet, vals.Processed, 'HRF HbR', icond);
            end
        end
        
        
        % ---------------------------------------------------------
        function AddChannelHbT(obj, isrc, idet, icond)
            if ~exist('isrc','var') || isempty(isrc)
                return;
            end
            if ~exist('idet','var') || isempty(idet)
                return;
            end
            if ~exist('icond','var') || isempty(icond)
                icond = 0;
            end
            vals = DataTypeValues();
            if icond==0
                obj.measurementList(end+1) = MeasListClass(isrc, idet, vals.Processed, 'HbT');
            else
                obj.measurementList(end+1) = MeasListClass(isrc, idet, vals.Processed, 'HRF HbT', icond);
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
            if ~exist('icond','var') || isempty(icond)
                icond = 0;
            end
            vals = DataTypeValues();
            if icond==0
                obj.measurementList(end+1) = MeasListClass(isrc, idet, vals.Processed, 'dOD');
            else
                obj.measurementList(end+1) = MeasListClass(isrc, idet, vals.Processed, 'HRF dOD', icond);
            end
            obj.measurementList(end).SetWavelengthIndex(wl);
        end
        
        
        % ---------------------------------------------------------
        function AppendD(obj, y)
            obj.dataTimeSeries(:, end+1:end+size(y(:,:),2)) = y(:,:);
        end

        
        % ---------------------------------------------------------
        function TruncateTpts(obj, n)
            obj.dataTimeSeries(end-n+1:end, :) = [];
            obj.time(end-n+1:end) = [];
        end
        
    end    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------------------------
        function Copy(obj, obj2)
            if isempty(obj)
                obj = DataClass();
            end
            if ~isa(obj2, 'DataClass')
                return;
            end
            for ii=1:length(obj2.measurementList)
                obj.measurementList(ii) = obj2.measurementList(ii).copy();      % shallow copy ok because MeasListClass has no handle properties 
            end
            obj.dataTimeSeries = obj2.dataTimeSeries;
            obj.time = obj2.time;
        end
        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B = false;
            if ~all(obj.dataTimeSeries(:)==obj2.dataTimeSeries(:))
                return;
            end
            if ~all(obj.time(:)==obj2.time(:))
                return;
            end
            if length(obj.measurementList)~=length(obj2.measurementList)
                return;
            end
            for ii=1:length(obj.measurementList)
                if obj.measurementList(ii)~=obj2.measurementList(ii)
                    return;
                end
            end
            B = true;
        end
        
        
    end
end

