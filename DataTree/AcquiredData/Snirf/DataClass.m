classdef DataClass < FileLoadSaveClass
    
    properties
        dataTimeSeries
        time
        measurementList
    end
    
    properties
        cache
        diagnostic
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
            obj.cache = struct('measurementListMatrix',[]);
            obj.diagnostic = false;
            
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
            obj.SetError(err); 
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
        function err = SaveHdf5(obj, fileobj, location)
            err = 0;
            if ~exist('fileobj', 'var') || isempty(fileobj)
                error('Unable to save file. No file name given.')
            end
            
            % Arg 2
            if ~exist('location', 'var') || isempty(location)
                location = '/nirs/data1';
            elseif location(1)~='/'
                location = ['/',location];
            end
            
            fid = HDF5_GetFileDescriptor(fileobj);
            if fid < 0
                err = -1;
                return;
            end
            
            hdf5write_safe(fid, [location, '/dataTimeSeries'], obj.dataTimeSeries, 'array');
            hdf5write_safe(fid, [location, '/time'], obj.time, 'array');
            
            for ii = 1:length(obj.measurementList)
                obj.measurementList(ii).SaveHdf5(fid, [location, '/measurementList', num2str(ii)]);
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
        function ml = GetMeasurementList(obj, matrixMode, reshape)
            ml = [];
            if ~exist('matrixMode','var')
                matrixMode = '';
            end
            if ~exist('reshape', 'var')
                reshape = '';
            end            
            hbTypes         = {'hbo','hbr','hbt'};
            if isempty(matrixMode)
                ml = obj.measurementList;
            elseif strncmp(matrixMode,'matrix',length('matrix'))
                if ~isempty(obj.cache) && ~isempty(obj.cache.measurementListMatrix)
                    if strcmp(matrixMode,'matrix')
                        ml = obj.cache.measurementListMatrix;
                        if strcmp(reshape, 'reshape')
                            ml = sortrows(ml);
                        end
                        return
                    end
                end
                ml = zeros(length(obj.measurementList),4);
                for ii = 1:length(obj.measurementList)
                    k = 0;
                    for jj = 1:length(hbTypes)
                        if ~isempty(strfind(lower(obj.measurementList(ii).dataTypeLabel), hbTypes{jj}))
                            k = jj;
                            break;
                        end
                    end
                    if obj.measurementList(ii).wavelengthIndex > 0
                        ml(ii,:) = [obj.measurementList(ii).sourceIndex, obj.measurementList(ii).detectorIndex, obj.measurementList(ii).dataTypeIndex, obj.measurementList(ii).wavelengthIndex];
                    elseif k > 0
                        ml(ii,:) = [obj.measurementList(ii).sourceIndex, obj.measurementList(ii).detectorIndex, obj.measurementList(ii).dataTypeIndex, k];
                    end
                end
                
                % Cache the results to avoid recalculating
                obj.cache.measurementListMatrix = ml;
                if strcmp(reshape, 'reshape')
                    ml = sortrows(ml);
                end
                
            end
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
        function [d, t, ml, order] = GetDataTimeSeries(obj, options)
            %
            % SYNTAX:
            %       d = GetDataTimeSeries(obj)
            %       [d, t] = GetDataTimeSeries(obj)
            %       [d, t, ml] = GetDataTimeSeries(obj)
            %       [d, t, ml, order] = GetDataTimeSeries(obj)
            %       d = GetDataTimeSeries(obj, options)
            %       [d, t] = GetDataTimeSeries(obj, options)
            %       [d, t, ml] = GetDataTimeSeries(obj, options)
            %       [d, t, ml, order] = GetDataTimeSeries(obj, options)
            %
            % DESCRIPTION:
            %       If no argument is supplied, or if option='', then dataTimeSeries and accompanying 
            %       measurementList is returned as is, as it exists in the SNIRF object. 
            %
            %       If option is supplied then we have the following option values possible values which can be 
            %       mixed and matched. The options are combined in one string argument with colon ':'. 
            %       
            %           'reshape'  - dataTimeSeries will be sorted, reshaped and reordered with the following dimensions:  
            %               
            %                        [ dataTimePoints,  sdPairIndex,  dataType, condition ]
            %                   
            %                        and all dimensions sorted in ascending order. The slowest dimensions to change will be 
            %                        from right-to-left. That is, sdPairIndex, dataType, condition. The rows of measurement list, ml, 
            %                        will follow this order in linear form. That is, the order of ml will index the columns 
            %                        of d squeezed into 2 dimensions d(:,:)
            %       
            %           'matrix'   - This options refers to the measurement list type: if 'matrix' keyword is in the options 
            %                        then ml will be returned as a 2D matrix instead of a MeasListClass object (that is the 
            %                        object representing the measurementList SNIRF field). The rows of the 2d array will have 
            %                        the same order as the original MeasListClass object elements. 
            %       
            %           'datatype' - used in combination with reshape. dataTimeSeries will be reshaped as above but the 
            %                        slowest dimensions to change will be reversed from left-to-right, that is, 
            %                        condition, dataType, sdPair:  
            %  
            %           'linear'   - Reordering as shown above with reshape and datatype, but d will be squeezed into 2D 
            %                        array
            % 
            %  EXAMPLES:
            %       
            %       %%%% dod is a DataClass object containing optical density data, with 4 sources, 8 detectors, 9 sd pairs, and 2 wavelengths.
            %       %%%% dc is a DataClass object containing concentration data, with 4 sources, 8 detectors, 9 sd pairs, and 3 Hb data types:  hbo, hbr, and hbt. 
            %
            %
            %       % Example 1:  Return OD dataTimeSeries, time and  measurementList (ml) unchanged, that is, as a MeasListClass object instead of Nx4 2D array.
            %       [d, t, ml, order] = dod.GetDataTimeSeries();
            %
            %
            %       % Example 2:  Return OD dataTimeSeries, and time unchanged and measurementList (ml) as a 2D matrix. Channel order is unchanged.
            %       [d, t, ml, order] = dod.GetDataTimeSeries('matrix');
            %
            %
            %       % Example 3:  Return concentration dataTimeSeries as a 3D array (d), and measurementList (ml) as a 2D array. Channel order is sorted, 
            %                     with slowest dimension to change being Hb type. 
            %       [d, t, ml, order] = dc.GetDataTimeSeries('matrix:reshape');
            %
            %
            %       % Example 4:  Return concentration dataTimeSeries as a 3D array (d), and measurementList (ml) as a 2D array. Channel order is sorted, 
            %                     with slowest dimension to change being sdPair. 
            %       [d, t, ml, order] = dc.GetDataTimeSeries('matrix:reshape:datatype');
            %
            %
            %       % Example 5:  Return concentration dataTimeSeries as a 2D array (d), and measurementList (ml) as a 2D array. Channel order is sorted, 
            %                     with slowest dimension to change being sdPair (ie. same channel as Example 4). 
            %       [d, t, ml, order] = dc.GetDataTimeSeries('matrix:reshape:datatype:linear');
            %
            %
            %
            d = [];
            t = [];
            ml = [];
            order = [];
            
            if ~exist('options','var') || isempty(options)
                options = '';
            end
            if isempty(obj)
                return;
            end            
            if isempty(obj.dataTimeSeries)
                return;
            end
            
            reshapeOption = '';
            if contains(options, 'reshape')
                reshapeOption = 'reshape';
            end
            dimSlow = 'sdpair';
            if contains(lower(options), 'condition')
                dimSlow = 'condition';
            elseif contains(lower(options), 'datatype')
                dimSlow = 'datatype';
            elseif contains(lower(options), 'wavelength')
                dimSlow = 'datatype';
            elseif contains(lower(options), 'hbtype')
                dimSlow = 'datatype';
            end
            matrixOption = '';
            if contains(options, 'matrix')
                matrixOption = 'matrix';
            end
            
            t = obj.time;
            if ~strcmp(reshapeOption, 'reshape')
                d = obj.dataTimeSeries;
                ml = obj.GetMeasurementList(matrixOption);
                order = 1:size(d,2);
                return
            end            
            
            measurementListFull = obj.GetMeasurementList('matrix');
            measurementListSDpairs = obj.GetMeasListSrcDetPairs('reshape');
            
            % Sort all the dimension data
            srcs       = sort(unique(measurementListFull(:,1)));
            dets       = sort(unique(measurementListFull(:,2)));
            conditions = sort(unique(measurementListFull(:,3)));
            dataTypes  = sort(unique(measurementListFull(:,4)));

            if obj.measurementList(1).wavelengthIndex > 0
                wavelengths     = dataTypes;
                hbTypes         = [];
            else
                wavelengths     = [];
                hbTypes         = dataTypes;
            end
            if conditions == 0
                conditions = [];
            end
            nWavelengths    = length(wavelengths);
            nDataTypeLabels = length(hbTypes);
            nCond           = length(conditions);
            
            kk = 1;            
            if strcmp(dimSlow, 'sdpair')
                
                if nWavelengths > 0 && nCond == 0
                    
                    for iS = 1:length(srcs)
                        for iD = 1:length(dets)
                            for iWl = 1:nWavelengths
                                
                                k = find(measurementListFull(:,1)==srcs(iS) & measurementListFull(:,2)==dets(iD) & measurementListFull(:,4)==wavelengths(iWl));
                                if ~isempty(k)
                                    iSDPair = find(measurementListSDpairs(:,1)==srcs(iS) & measurementListSDpairs(:,2)==dets(iD));
                                    d(:, iWl, iSDPair) = obj.dataTimeSeries(:,k); %#ok<*FNDSB>
                                    order(kk) = k;
                                    kk = kk+1;
                                end
                                
                            end
                        end
                    end
                    
                elseif nWavelengths > 0 && nCond > 0
                    
                    for iCond = 1:nCond
                        for iS = 1:length(srcs)
                            for iD = 1:length(dets)
                                for iWl = 1:nWavelengths
                                    
                                    k = find(measurementListFull(:,1)==srcs(iS) & measurementListFull(:,2)==dets(iD) & measurementListFull(:,3)==iCond &  measurementListFull(:,4)==wavelengths(iWl));
                                    if ~isempty(k)
                                        iSDPair = find(measurementListSDpairs(:,1)==srcs(iS) & measurementListSDpairs(:,2)==dets(iD));
                                        d(:, iWl, iSDPair, iCond) = obj.dataTimeSeries(:,k);
                                        order(kk) = k;
                                        kk = kk+1;
                                    end
                                    
                                end
                            end
                        end
                    end
                    
                elseif nDataTypeLabels > 0 && nCond == 0
                    
                    for iS = 1:length(srcs)
                        for iD = 1:length(dets)
                            for iHbType = 1:length(hbTypes)
                                
                                k = find(measurementListFull(:,1)==srcs(iS) & measurementListFull(:,2)==dets(iD) & measurementListFull(:,4)==iHbType);
                                if ~isempty(k)
                                    iSDPair = find(measurementListSDpairs(:,1)==srcs(iS) & measurementListSDpairs(:,2)==dets(iD));
                                    d(:, iHbType, iSDPair) = obj.dataTimeSeries(:,k);
                                    order(kk) = k;
                                    kk = kk+1;
                                end
                                
                            end
                        end
                    end
                    
                elseif nDataTypeLabels > 0 && nCond > 0
                    
                    for iCond = 1:nCond
                        for iS = 1:length(srcs)
                            for iD = 1:length(dets)
                                for iHbType = 1:length(hbTypes)
                                    
                                    k = find(measurementListFull(:,1)==srcs(iS) & measurementListFull(:,2)==dets(iD) & measurementListFull(:,3)==iCond &  measurementListFull(:,4)==iHbType);
                                    if ~isempty(k)
                                        iSDPair = find(measurementListSDpairs(:,1)==srcs(iS) & measurementListSDpairs(:,2)==dets(iD));
                                        d(:, iHbType, iSDPair, iCond) = obj.dataTimeSeries(:,k);
                                        order(kk) = k;
                                        kk = kk+1;
                                    end
                                    
                                end
                            end
                        end
                    end
                end
                
            elseif strcmp(dimSlow, 'condition') || strcmp(dimSlow, 'datatype')
                
                if nWavelengths > 0 && nCond == 0
                    
                    for iWl = 1:nWavelengths
                        for iS = 1:length(srcs)
                            for iD = 1:length(dets)
                                
                                k = find(measurementListFull(:,1)==srcs(iS) & measurementListFull(:,2)==dets(iD) & measurementListFull(:,4)==wavelengths(iWl));
                                if ~isempty(k)
                                    iSDPair = find(measurementListSDpairs(:,1)==srcs(iS) & measurementListSDpairs(:,2)==dets(iD));
                                    d(:, iSDPair, iWl) = obj.dataTimeSeries(:,k); %#ok<*FNDSB>
                                    order(kk) = k;
                                    kk = kk+1;
                                end
                                
                            end
                        end
                    end
                    
                elseif nWavelengths > 0 && nCond > 0
                    
                    for iCond = 1:nCond
                        for iWl = 1:nWavelengths
                            for iS = 1:length(srcs)
                                for iD = 1:length(dets)
                                    
                                    k = find(measurementListFull(:,1)==srcs(iS) & measurementListFull(:,2)==dets(iD) & measurementListFull(:,3)==iCond &  measurementListFull(:,4)==wavelengths(iWl));
                                    if ~isempty(k)
                                        iSDPair = find(measurementListSDpairs(:,1)==srcs(iS) & measurementListSDpairs(:,2)==dets(iD));
                                        d(:, iSDPair, iWl, iCond) = obj.dataTimeSeries(:,k);
                                        order(kk) = k;
                                        kk = kk+1;
                                    end
                                    
                                end
                            end
                        end
                    end
                    
                elseif nDataTypeLabels > 0 && nCond == 0
                    
                    for iHbType = 1:length(hbTypes)
                        for iS = 1:length(srcs)
                            for iD = 1:length(dets)
                                
                                k = find(measurementListFull(:,1)==srcs(iS) & measurementListFull(:,2)==dets(iD) & measurementListFull(:,4)==iHbType);
                                if ~isempty(k)
                                    iSDPair = find(measurementListSDpairs(:,1)==srcs(iS) & measurementListSDpairs(:,2)==dets(iD));
                                    d(:, iSDPair, iHbType) = obj.dataTimeSeries(:,k);
                                    order(kk) = k;
                                    kk = kk+1;
                                end
                                
                            end
                        end
                    end
                    
                elseif nDataTypeLabels > 0 && nCond > 0
                    
                    for iCond = 1:nCond
                        for iHbType = 1:length(hbTypes)
                            for iS = 1:length(srcs)
                                for iD = 1:length(dets)
                                    
                                    k = find(measurementListFull(:,1)==srcs(iS) & measurementListFull(:,2)==dets(iD) & measurementListFull(:,3)==iCond &  measurementListFull(:,4)==iHbType);
                                    if ~isempty(k)
                                        iSDPair = find(measurementListSDpairs(:,1)==srcs(iS) & measurementListSDpairs(:,2)==dets(iD));
                                        d(:, iSDPair, iHbType, iCond) = obj.dataTimeSeries(:,k);
                                        order(kk) = k;
                                        kk = kk+1;
                                    end
                                    
                                end
                            end
                        end
                    end
                end
                
            end
            
            ml = measurementListFull(order,:);
            
            if contains(options, 'linear') 
                d = d(:,:);
            end
            if ~contains(options, 'matrix')
                ml = obj.measurementList;
                ml(order) = ml;
            end
            if contains(options, 'reshape')
                ml = measurementListSDpairs;
            end

            obj.SimulateErrors(d);
        end
        
        
            
        % ---------------------------------------------------------
        function d = SimulateErrors(obj, d)
            if obj.diagnostic == false
                return
            end
            d = simulateDataError(d);
        end
        
        
        
        % ---------------------------------------------------------
        function SetDataTimeSeries(obj, val)
            if ~exist('val','var')
                return;
            end
            obj.dataTimeSeries = val;
        end
        
        
        
        % ---------------------------------------------------------
        function SetInactiveChannelData(obj)
            if obj.IsEmpty()
                return
            end
            for iMeas = 1:size(obj.dataTimeSeries,2)
                % We set the criteria for deciding if a channel is inactive if ALL it's 
                % data points are zero. Is this a safe assumption? Maybe we should create 
                % a config parameter for this?
                if all(obj.dataTimeSeries(:,iMeas) == 0)
                    obj.dataTimeSeries(:,iMeas) = obj.dataTimeSeries(:,iMeas)/0;
                end
            end
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
            obj.CopyMeasurementList(obj2);
            obj.dataTimeSeries = obj2.dataTimeSeries;
            obj.time = obj2.time;
        end
        
        
        
        % ----------------------------------------------------------------------------------
        function CopyMeasurementList(obj, obj2)
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
                obj.dataTimeSeries( isnan(obj.dataTimeSeries(:)) | isinf(obj.dataTimeSeries(:)) ) = 0;
                obj2.dataTimeSeries( isnan(obj2.dataTimeSeries(:)) | isinf(obj2.dataTimeSeries(:)) ) = 0;
                if ~all(obj.dataTimeSeries(:)==obj2.dataTimeSeries(:))
                    return;
                end
            end
            if ~all(obj.time(:)==obj2.time(:))
                return;
            end
            if length(obj.measurementList)~=length(obj2.measurementList)
                return;
            end
            if ~obj.EqualMeasurementLists(obj2)
                return;
            end
            B = true;
        end
        
        
        % -------------------------------------------------------
        function B = EqualMeasurementLists(obj, obj2)
            B = false;
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

