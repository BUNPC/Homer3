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
            %     obj = DataClass(filename)
            %     obj = DataClass(data)
            %     obj = DataClass(d,t,ml)
            %
            %  Input:
            %     filename - When there's one argument and it is a char,
            %                then it's interepreted as a filename path
            %     data - When there's one argument and it it is not a char string, 
            %            it can be either a DataClass or NirsClass object.
            %     d    - When there are three arguments, d is the data time course matrix
            %     t    - When there are three arguments, t is the data time vector
            %     ml   - When there are three arguments, ml is the measurent list, which
            %            can be either a nirs style matrix or a MeasListClass object
            %
            %  Examples:
            %     
            %     % Example 1 - Create DataClass object and initialize it with SNIRF data variable 
            %     %             from file neuro_run01.snirf
            %
            %     data = DataClass('c:/users/public/subjects/subj1/neuro_run01.snirf')   
            %
            %    
            %     % Example 2 - Create DataClass object and initialize it with time course data and time vectors 
            %     %             from the .nirs file ./s1/neuro_run01.nirs
            %
            %     nirs = NirsClass('./s1/neuro_run01.nirs')
            %     data = DataClass(nirs.d, nirs.t)
            % 
            obj.SetFileFormat('hdf5');
            
            % Set SNIRF fomat properties
            obj.measurementList = MeasListClass().empty();
            
            if nargin==0
                return;
            elseif nargin==1
                if isa(varargin{1}, 'DataClass')
                    obj.Copy(varargin{1});
                elseif NirsClass(varargin{1}).IsValid()
                    obj.dataTimeSeries = varargin{1}.d;
                    obj.time = varargin{1}.t;
                    for ii = 1:size(varargin{1}.ml,1)
                        obj.measurementList(end+1) = MeasListClass(varargin{1}.ml(ii,:));
                    end
                elseif NirsClass(varargin{1}).IsProbeValid()
                    obj.dataTimeSeries = zeros(2, size(varargin{1}.MeasList,1));
                    obj.time = zeros(2,1);
                    for ii = 1:size(varargin{1}.MeasList,1)
                        obj.measurementList(end+1) = MeasListClass(varargin{1}.MeasList(ii,:));
                    end
                elseif isa(varargin{1}, 'char')
                    obj.SetFilename(varargin{1});
                    obj.Load();
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
                    for ii = 1:length(varargin{3})
                        obj.measurementList(end+1) = MeasListClass(varargin{3}(ii));
                    end
                else
                    obj.dataTimeSeries = varargin{1};
                    obj.time = varargin{2};
                    for ii = 1:size(varargin{3},1)
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
        function err = LoadHdf5(obj, fileobj, location)
            err = 0;
            
            % Arg 1
            if ~exist('fileobj','var') || (ischar(fileobj) && ~exist(fileobj,'file'))
                fileobj = '';
            end
                      
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/data1';
            elseif location(1)~='/'
                location = ['/',location];
            end
            
            % Error checking            
            if ~isempty(fileobj) && ischar(fileobj)
                obj.SetFilename(fileobj);
            elseif isempty(fileobj)
                fileobj = obj.GetFilename();
            end
            if isempty(fileobj)
               err = -1;
               return;
            end
            
            
            try
                % Open group
                [gid, fid] = HDF5_GroupOpen(fileobj, location);
                if isstruct(gid)
                    if gid.double < 0 
                        err = -1;
                        return 
                    end
                end                
                
                obj.dataTimeSeries  = HDF5_DatasetLoad(gid, 'dataTimeSeries');
                obj.time            = HDF5_DatasetLoad(gid, 'time');
                                   
                ii = 1;
                while 1
                    if ii > length(obj.measurementList)
                        obj.measurementList(ii) = MeasListClass;
                    end
                    if obj.measurementList(ii).LoadHdf5(fileobj, [location, '/measurementList', num2str(ii)]) < 0
                        if ~obj.measurementList(ii).IsEmpty()
                            err = -1;                        
                        else
                            obj.measurementList(ii).delete();
                            obj.measurementList(ii) = [];
                        end
                        if ii == 1
                            err = -1;
                        end
                        break;
                    end
                    ii=ii+1;
                end
                
                % Close group
                HDF5_GroupClose(fileobj, gid, fid);
            catch
                err = -1;
            end
            
            err = ErrorCheck(obj, err);
        end
        
        
        % -------------------------------------------------------
        function err = LoadTime(obj, fileobj, location)
            err = 0;
                       
            % Arg 1
            if ~exist('fileobj','var') || (ischar(fileobj) && ~exist(fileobj,'file'))
                fileobj = '';
            end
                      
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/data1';
            elseif location(1)~='/'
                location = ['/',location];
            end
                      
            % Error checking            
            if ~isempty(fileobj) && ischar(fileobj)
                obj.SetFilename(fileobj);
            elseif isempty(fileobj)
                fileobj = obj.GetFilename();
            end
            if isempty(fileobj)
               err = -1;
               return;
            end
            
            
            try
                % Open group
                [gid, fid] = HDF5_GroupOpen(fileobj, location);
                
                obj.time = HDF5_DatasetLoad(gid, 'time');
                                   
                % Close group
                HDF5_GroupClose(fileobj, gid, fid);
            catch
                err = -1;
            end
            
            err = ErrorCheck(obj, err, {'time'});
        end
        
        
        % -------------------------------------------------------
        function SaveHdf5(obj, fileobj, location)
            if ~exist('fileobj', 'var') || isempty(fileobj)
                error('Unable to save file. No file name given.')
            end
            
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/data1';
            elseif location(1)~='/'
                location = ['/',location];
            end
            
            if ~exist(fileobj, 'file')
                fid = H5F.create(fileobj, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            
            hdf5write_safe(fileobj, [location, '/dataTimeSeries'], obj.dataTimeSeries, 'array');
            hdf5write_safe(fileobj, [location, '/time'], obj.time, 'array');
            
            for ii=1:length(obj.measurementList)
                obj.measurementList(ii).SaveHdf5(fileobj, [location, '/measurementList', num2str(ii)]);
            end
        end
        
        
        % -------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return;
            end
            if isempty(obj.dataTimeSeries) || isempty(obj.time) || isempty(obj.measurementList)
                return;
            end
            if isempty(obj.measurementList)
                return;
            end
            b = false;
        end
        
        
        % -------------------------------------------------------
        function b = IsDataValid(obj, iMeas)
            b = false;
            if ~exist('iMeas','var')
                iMeas = 1:length(obj.measurementList);
            end            
            if all(isnan(obj.dataTimeSeries(:)))
                return;
            end
            for ii = iMeas
                if any(isnan(obj.dataTimeSeries(:, iMeas)))
                    return;
                end
            end
            b = true;
        end
        
        
        % ----------------------------------------------------------------------
        function err = ErrorCheck(obj, err, params)
            if ~exist('params','var')
                params = propnames(obj);
            end
            if ismember('dataTimeSeries',params)
                if obj.IsEmpty()
                    err = -2;
                    return;
                end
                if size(obj.dataTimeSeries,1) ~= length(obj.time)
                    err = -3;
                end
                if size(obj.dataTimeSeries,2) ~= length(obj.measurementList)
                    err = -4;
                end
                if all(obj.dataTimeSeries==0)
                    err = 5;
                end
            end
            if ismember('time',params)
                if isempty(obj.time)
                    err = -6;
                    return;
                end
                if all(obj.time==0)
                    err = 7;
                end
            end
        end
        
    end
    
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set/Get properties methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ---------------------------------------------------------
        function val = GetT(obj)
            val = obj.time;
        end
        
        
        % ---------------------------------------------------------
        function wls = GetWls(obj)
            wls = obj.measurementList(1).GetWls();
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasList(obj, options)
            if ~exist('options', 'var')
                options = '';
            end
            % Preallocate for speed 
            ml = ones(length(obj.measurementList), 4);
            
            % Convert obj.measurementList to matrix
            for ii = 1:length(obj.measurementList)
                % If this data contains block average then only get the measurements for first condition. That will
                % contain all the measurement channels
                if obj.measurementList(ii).GetCondition()>1
                    break;
                end
                % Deal with the cases where the measurementList contains
                % wavelengthIndex versus not
                if ~isempty(obj.measurementList(ii).GetWavelengthIndex())
                    ml(ii,:) = [obj.measurementList(ii).GetSourceIndex(), obj.measurementList(ii).GetDetectorIndex(), 1, obj.measurementList(ii).GetWavelengthIndex()];
                else 
                    ml(ii,:) = [obj.measurementList(ii).GetSourceIndex(), obj.measurementList(ii).GetDetectorIndex(), 1, 1];
                end
            end
            
            % Remove unused rows that were pre-allocated
            ml(ii+1:end,:) = [];
            if strcmp(options, 'reshape')
                ml = sortrows(ml);
            end            
        end
        
        
        
        % ---------------------------------------------------------
        function ml = GetMeasListSrcDetPairs(obj, options)
            if ~exist('options', 'var')
                options = '';
            end
            ml = zeros(0, 2);
            jj=1;
            for ii=1:length(obj.measurementList)
                if isempty(find(ml(:,1) == obj.measurementList(ii).sourceIndex & ml(:,2) == obj.measurementList(ii).detectorIndex))
                    ml(jj,:) = [obj.measurementList(ii).sourceIndex, obj.measurementList(ii).detectorIndex];
                    jj=jj+1;
                end
            end
            if strcmp(options, 'reshape')
                ml = sortrows(ml);
            end
        end
        
        
        % ---------------------------------------------------------
        function ml = GetMeasurementList(obj)
            ml = obj.measurementList;
        end
        
        
        % ---------------------------------------------------------
        function idxs = GetMeasurementListIdxs(obj, CondIdxs)
            % Get all the measurementList array idxs matching the
            % conditions in the CondNames argument
            idxs = zeros(1,length(obj.measurementList));
            kk=1;
            for iCh = 1:length(obj.measurementList)
                for iCond = 1:length(CondIdxs)
                    if sum(obj.measurementList(iCh).dataTypeIndex == CondIdxs)
                        idxs(kk) = iCh;
                        kk=kk+1;
                        break;
                    end
                end
            end
            idxs(idxs==0) = [];
        end
        
        
        % ---------------------------------------------------------
        function t = GetTime(obj)
            
            t = obj.time;
        end
        
        
        
        % ---------------------------------------------------------
        function [d, order] = GetDataTimeSeries(obj, options)
            d = [];
            order = [];
            if ~exist('options','var') || isempty(options)
                options = '';
            end
            if isempty(obj.dataTimeSeries)
                return;
            end
            if ~strcmp(options, 'reshape')
                d = obj.dataTimeSeries;
                return
            end
                      
            dataTypeLabels = {};
            srcs = zeros(0,2);
            dets = zeros(0,2);
            conditions = [];
            wavelengths = [];
            hh=1; jj=1; kk=1; ll=1; mm=1;
            for ii = 1:length(obj.measurementList)
                if ~ismember(obj.measurementList(ii).dataTypeLabel, dataTypeLabels) && ~isempty(obj.measurementList(ii).dataTypeLabel)
                    dataTypeLabels{hh} = obj.measurementList(ii).dataTypeLabel; %#ok<*AGROW>
                    hh=hh+1;
                end
                if isempty(find(srcs == obj.measurementList(ii).GetSourceIndex()))
                    srcs(jj) = obj.measurementList(ii).GetSourceIndex();
                    jj=jj+1;
                end
                if isempty(find(dets == obj.measurementList(ii).GetDetectorIndex())) %#ok<*EFIND>
                    dets(kk) = obj.measurementList(ii).GetDetectorIndex();
                    kk=kk+1;
                end
                if ~ismember(obj.measurementList(ii).GetCondition(), conditions) && obj.measurementList(ii).GetCondition() > 0
                    conditions(ll) = obj.measurementList(ii).GetCondition();
                    ll=ll+1;
                end
                if ~ismember(obj.measurementList(ii).GetWavelengthIndex(), wavelengths) && obj.measurementList(ii).GetWavelengthIndex()>0
                    wavelengths(mm) = obj.measurementList(ii).GetWavelengthIndex();
                    mm=mm+1;
                end
            end
            
            hbTypes         = {'hbo','hbr','hbt'};
            nWavelengths    = length(wavelengths);
            nDataTypeLabels = length(dataTypeLabels);
            nCond           = length(conditions);
            ml              = obj.GetMeasListSrcDetPairs('reshape');
            
            kk = 1;
            if nWavelengths > 0 && nCond == 0
                
                for iWl = 1:nWavelengths
                    for iS = 1:length(srcs)
                        for iD = 1:length(dets)
                            
                            for ii = 1:length(obj.measurementList)
                                if obj.measurementList(ii).sourceIndex == iS && ...
                                   obj.measurementList(ii).detectorIndex == iD &&  ...
                                   obj.measurementList(ii).wavelengthIndex == iWl
                                    
                                    iSrcDetPair = find(ml(:,1)==iS & ml(:,2)==iD);
                                    d(:, iWl, iSrcDetPair) = obj.dataTimeSeries(:,ii); %#ok<*FNDSB>
                                    
                                    
                                    order(kk) = ii;
                                    kk = kk+1;
                                    break;

                                end
                                
                            end
                        end
                    end
                end
                
            elseif nWavelengths > 0 && nCond > 0 
                
                for iWl = 1:nWavelengths
                    for iS = 1:length(srcs)
                        for iD = 1:length(dets)
                            for iCond = 1:nCond
                            
                                for ii = 1:length(obj.measurementList)
                                    if obj.measurementList(ii).sourceIndex == iS && ...
                                       obj.measurementList(ii).detectorIndex == iD &&  ...
                                       obj.measurementList(ii).wavelengthIndex == iWl && ...
                                       obj.measurementList(ii).dataTypeIndex == iCond
                                        
                                        iSrcDetPair = find(ml(:,1)==iS & ml(:,2)==iD);
                                        d(:, iWl, iSrcDetPair, iCond) = obj.dataTimeSeries(:,ii);
                                        
                                        order(kk) = ii;
                                        kk = kk+1;
                                        break;

                                    end
                                end
                                
                            end     
                        end
                    end
                end
                
            elseif nDataTypeLabels > 0 && nCond == 0 
                
                for iHbType = 1:length(hbTypes)
                    for iS = 1:length(srcs)
                        for iD = 1:length(dets)
                            
                            for ii = 1:length(obj.measurementList)
                                if obj.measurementList(ii).sourceIndex == iS && ...
                                   obj.measurementList(ii).detectorIndex == iD && ...
                                   ~isempty(strfind(lower(obj.measurementList(ii).dataTypeLabel), hbTypes{iHbType}))

                                    iSrcDetPair = find(ml(:,1)==iS & ml(:,2)==iD);
                                    d(:, iHbType, iSrcDetPair) = obj.dataTimeSeries(:,ii);

                                    order(kk) = ii;
                                    kk = kk+1;                                    
                                    break;

                                end

                            end
                            
                        end
                    end
                end
                
            elseif nDataTypeLabels > 0 && nCond > 0 
                
                for iHbType = 1:length(hbTypes)
                    for iS = 1:length(srcs)
                        for iD = 1:length(dets)
                            for iCond = 1:nCond
                            
                                for ii = 1:length(obj.measurementList)
                                    if obj.measurementList(ii).sourceIndex == iS && ...
                                       obj.measurementList(ii).detectorIndex == iD &&  ...
                                       ~isempty(strfind(lower(obj.measurementList(ii).dataTypeLabel), hbTypes{iHbType})) && ...
                                       obj.measurementList(ii).dataTypeIndex == iCond
                                        
                                        iSrcDetPair = find(ml(:,1)==iS & ml(:,2)==iD);
                                        d(:, iHbType, iSrcDetPair, iCond) = obj.dataTimeSeries(:,ii);
                                        
                                        order(kk) = ii;
                                        kk = kk+1;
                                        break;

                                    end
                                end
                                
                            end     
                        end
                    end
                end
                
            end
            
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
            if ~exist('iHb','var') || isempty(iHb)
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
        function AppendDataTimeSeries(obj, y)
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
            if isempty(obj2)
                obj = DataClass();
                return;
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
            if length(obj.dataTimeSeries(:)) ~= length(obj2.dataTimeSeries(:))
                return;
            end
            if ndims(obj.dataTimeSeries) ~= ndims(obj2.dataTimeSeries)
                return;
            end
            if ~all(size(obj.dataTimeSeries)==size(obj2.dataTimeSeries))
                return;
            end
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
        
        
        % ----------------------------------------------------------------------------------
        function nbytes = MemoryRequired(obj)
            nbytes = 0;
            if isempty(obj)
                return
            end
            nbytes = sizeof(obj.dataTimeSeries) + sizeof(obj.time);
            for ii=1:length(obj.measurementList)
                nbytes = nbytes + obj.measurementList(ii).MemoryRequired();
            end
        end
        
        
    end
end

