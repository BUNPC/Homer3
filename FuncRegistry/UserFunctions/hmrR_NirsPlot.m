% SYNTAX:
% data2 = hmrR_NirsPlot(snirfData, FreqCut, window, windowOverlap, quality_threshold, conditionsMask, lambdaMask, dodFlag, guiFlag)
%
% UI NAME:
% hmrR_NirsPlot
%
% DESCRIPTION:
% Perform a bandpass filter on time course data.
%
% INPUT:
% data: Snirf Data
% FreqCut: 1x2 array [fmin fmax] representing the bandpass of the cardiac pulsation (default [0.5 2.5])
% window:  length in seconds of the window to partition the signal with (defaut: 5)
% windowOverlap: fraction overlap (0..0.99) between adjacent windows (default: 0, no overlap)
% qualityThreshold: The required quality value (normalized; 0 to 1) of good-quality windows in every channel (default: 0.75)
% conditionsMask: A binary mask (or the keyword 'all') to indicate the conditions for computing the periods of interest (default: 'all')
% lambdaMask: A binary array mapping the selected two wavelength to compute the SCI (default: [1 1], the first two WLs)
% dodFlag: A flag indicating to work from DOD data (default: 0)
% guiFlag: A flag indicating whether to start or not the GUI.
% 
% OUTPUT:
% qualityMatrices - is an structure that includes the set of fields:
%
% USAGE OPTIONS:
% nirsPlot_struct: [qualityMatrices] = hmrR_NirsPlot(snirfData, FreqCut, window, windowOverlap, quality_threshold, conditionsMask, lambdaMask, dodFlag, guiFlag)
% 
% PARAMETERS:
% FreqCut:[0.5 2.5]
% window: 5;
% windowOverlap: 0;
% quality_threshold: 0.75;
% conditionsMask: 0;
% lambdaMask: [1 1];
% dodFlag: 0;
% guiFlag: 0;

function qualityMatrices = hmrR_NirsPlot(snirfData, FreqCut, window, windowOverlap, quality_threshold, conditionsMask, lambdaMask, dodFlag, guiFlag)
    %---------Snirf -> Nirs data conversion--------
    %  'struct' containing the following fields: 
    %             d (required)
    %             t (required)
    %             s (required)
    %             SD (required)
    %             ml
    %             aux
    %             filename
    %             supportedFomats
    %             fileformat
    %             CondNames
    if ~exist('dirname','var')
     % if not given a path, set it to snirf path
      dirname = snirfData.filename;
    end
    
    struct.t = snirfData.data.time;
    struct.d = snirfData.data.dataTimeSeries;
    
%   following fields for stimData(SD)
    SDtest.Lambda = snirfData.probe.wavelengths;
    SDtest.SrcPos = snirfData.probe.sourcePos2D;
    SDtest.DetPos = snirfData.probe.detectorPos2D;
    SDtest.NSrcs = snirfData.data.measurementList(length(snirfData.data.measurementList)).sourceIndex;
    SDtest.NDets = snirfData.data.measurementList(length(snirfData.data.measurementList)).detectorIndex; 
    
    %     need further testing on this two
    SDtest.MeasListAct = ones(length(snirfData.data.measurementList),1);
    SDtest.MeasListVis = ones(length(snirfData.data.measurementList),1);
    if isfield(snirfData.metaDataTags.tags,'LengthUnit')
        SDtest.SpatialUnit = snirfData.metaDataTags.tags.LengthUnit;
    end
%   measList build    
    TempMeasList = zeros(length(snirfData.data.measurementList),4);
    TempMeasList(:,3) = 1;
    for i = 1:length(snirfData.data.measurementList)
        TempMeasList(i,1) = snirfData.data.measurementList(i).sourceIndex;
        TempMeasList(i,2) = snirfData.data.measurementList(i).detectorIndex;
        TempMeasList(i,4) = snirfData.data.measurementList(i).wavelengthIndex;
    end
    SDtest.MeasList = TempMeasList;
    struct.ml = TempMeasList;
    struct.SD = SDtest;
    
%     following for constructing Stim(S) field 
    Stemp = zeros(length(snirfData.data.time),1);
    for i = 1:size(snirfData.stim.data,1)
        index = round(snirfData.stim.data(i,1)*snirfData.stim.data(i,2));
        Stemp(index,1) = 1;
        
    end
    struct.s = Stemp;
    
%   AUX
    AuxTemp = zeros(length(snirfData.data.time),size(snirfData.aux,2));
    for i = 1:size(snirfData.aux,2)
        AuxTemp(:,i) = snirfData.aux(i).dataTimeSeries;
        
        
    end
    struct.aux = AuxTemp;
    
    
%   filenames
    struct.filename = dirname;
        
    
    struct.supportedFomats = snirfData.supportedFomats;
    struct.fileformat = 'mat';
    
%   CondNames
    struct.CondNames={};
    for ii = 1:length(snirfData.stim.name)
        struct.CondNames{ii} =  snirfData.stim.name;
        
    end
    
    
%   --------NirsPlot starts from here---------  
    %defalt conditionMask is 'all';
    if conditionsMask == 0
        conditionsMask = 'all';
    end
    rawDotNirs = datasnirfData;
    filepath = pwd;
    name = 'NirsplotAnalized';
    ext = '.nirs';

    % 'freqCut'
    if isfloat(FreqCut) && length(FreqCut)==2
        fcut_ = [min(FreqCut) max(FreqCut)];
    end

    % 'window'
    if length(window)==1
        window_ = ceil(window);
    end

    % 'overlap'
    if isfloat(windowOverlap) && windowOverlap >= 0 && windowOverlap <= 1
        overlap_ = windowOverlap;
    end

    % 'qualityThreshold'
    if isfloat(quality_threshold) && quality_threshold >= 0 && quality_threshold <= 1
        q_threshold = quality_threshold;
    end

    % 'conditionsMask'
    if (ischar(conditionsMask) && strcmp(conditionsMask,'all')) || ~(any(conditionsMask>1 | conditionsMask<0))
        cond_mask = conditionsMask;
    end

    % 'lambdaMask'
    if (ischar(lambdaMask) && strcmp(lambdaMask,'all')) || ~(any(lambdaMask>1 | lambdaMask<0))
        lambda_mask_ = lambdaMask;
    end

    % 'dodFlag'
    if dodFlag == 1
        dodFlag_ = 1;
    else
        dodFlag_ = 0;
    end
    % 'guiFlag'
    if guiFlag == 1
        guiFlag_ = 1;
    else
        guiFlag_ = 0;
    end

%------ Sorting for nirstoolbox compatibility ------
varNames = {'source','detector','dummy','type'};
MeasList_table = table(rawDotNirs.SD.MeasList(:,1),...
    rawDotNirs.SD.MeasList(:,2),...
    rawDotNirs.SD.MeasList(:,3),...
    rawDotNirs.SD.MeasList(:,4),...
    'VariableNames',varNames);

colsToSortBy = {'source', 'detector', 'type'};
[MeasList_table, idxML] = sortrows(MeasList_table, colsToSortBy);
rawDotNirs.SD.MeasList = table2array(MeasList_table);
rawDotNirs.d = rawDotNirs.d(:,idxML);
%---------------------------------------------------

frequency_samp = 1/mean(diff(rawDotNirs.t));
% Creating 's' variable (stimuli matrix) from the information in StimDesign
if ~isfield(rawDotNirs,'s')
    if isfield(rawDotNirs,'StimDesign')
        nStim = length(rawDotNirs.StimDesign);
        sTmp = zeros(size(rawDotNirs.d,1),nStim);
        for iStim = 1:nStim
            for iOnset=1:length(rawDotNirs.StimDesign(iStim).onset)
                onsetTmp = floor(rawDotNirs.StimDesign(iStim).onset(iOnset) * frequency_samp);
                durTmp = floor(rawDotNirs.StimDesign(iStim).dur(iOnset)* frequency_samp);
                %sTmp(floor(rawDotNirs.StimDesign(iStim).onset(iOnset) * frequency_samp),iStim) = 1;
                sTmp(onsetTmp:(onsetTmp+durTmp),iStim) = 1;
            end
        end
        rawDotNirs.s = sTmp;
        clear sTmp;
    else
        disp('Stimuli information is not available.');
    end
end


% set default
if ~exist('fcut_','var')
    fcut_ = [0.5 2.5];
end

if ~exist('window_','var')
    window_ = 5;
end
if ~exist('overlap_','var')
    overlap_ = 0;
end
if ~exist('q_threshold','var')
    q_threshold = 0.75;
end
if ~exist('cond_mask','var') || strcmp(cond_mask,'all')
    cond_mask = ones(1,size(rawDotNirs.s,2));
end
lambdas_ = unique(rawDotNirs.SD.MeasList(:,4));
if ~exist('lambda_mask_','var')
    lambdas_ = unique(rawDotNirs.SD.MeasList(:,4));
    lambda_mask_ = ones(length(lambdas_),1);
end
if ~exist('dodFlag_','var')
    dodFlag_ = 0;
end
if ~exist('guiFlag_','var')
    guiFlag_ = 0;
end

nirsplot_parameters.dotNirsPath = filepath;
nirsplot_parameters.dotNirsFile = name;
nirsplot_parameters.fcut = fcut_;
nirsplot_parameters.window = window_;
nirsplot_parameters.overlap = overlap_;
nirsplot_parameters.lambda_mask = lambda_mask_;
nirsplot_parameters.lambdas = lambdas_;
nirsplot_parameters.dodFlag = dodFlag_;
nirsplot_parameters.mergewoi_flag = true;
nirsplot_parameters.quality_threshold = q_threshold;
nirsplot_parameters.n_channels = size(rawDotNirs.d,2)/2;
nirsplot_parameters.n_sources = size(rawDotNirs.SD.SrcPos,1);
nirsplot_parameters.n_detectors = size(rawDotNirs.SD.DetPos,1);
nirsplot_parameters.s = rawDotNirs.s;
nirsplot_parameters.t = rawDotNirs.t;


nirsplot_parameters.fs = frequency_samp;
nirsplot_parameters.mergewoiFlag = true;
nirsplot_parameters.cond_mask = cond_mask;
nirsplot_parameters.save_report_table = false;
nirsplot_parameters.sclAlpha = 0.65;
nirsplot_parameters.rectangle_line_width = 1.2;
nirsplot_parameters.guiFlag = guiFlag_;

% Call the GUI for parameter inputs
S=dbstack;
if length(S)== 1 && guiFlag_ == 1
    disp('please open the GUI from tool menu in Homer3')
end
report_table = [];

% calculation of the qualityMatrices

        raw = rawDotNirs;
        nirsplot_param = nirsplot_parameters;
        fcut = nirsplot_param.fcut;
        window = nirsplot_param.window;
        overlap = nirsplot_param.overlap;
        lambda_mask = nirsplot_param.lambda_mask;
        lambdas = nirsplot_param.lambdas;
        n_channels = nirsplot_param.n_channels;
        qltyThld = nirsplot_param.quality_threshold;
        
        dodFlag = nirsplot_param.dodFlag;
        if dodFlag
           dm = mean(abs(raw.d),1);
           raw.d = exp(-raw.procResult.dod).*(ones(size(raw.d,1),1)*dm);
        end
        
        % Set the bandpass filter parameters
        %fs = 1/mean(diff(raw.t));
        fs = nirsplot_param.fs;
        fcut_min = fcut(1);
        fcut_max = fcut(2);
        if fcut_max >= (fs)/2
            fcut_max = (fs)/2 - eps;
            warning(['The highpass cutoff has been reduced from ',...
                num2str(fcut(2)), ' Hz to ', num2str(fcut_max),...
                ' Hz to satisfy the Nyquist sampling criterion']);
        end
        [B1,A1]=butter(1,[fcut_min*(2/fs) fcut_max*(2/fs)]);
        
        nirs_data = zeros(length(lambdas),size(raw.d,1),n_channels);
        cardiac_data = zeros(length(lambdas),size(raw.d,1),n_channels); % Lambdas x time x channels
        for j = 1:length(lambdas)
            % Filter everything but the cardiac component
            idx = find(raw.SD.MeasList(:,4) == lambdas(j));
            nirs_data(j,:,:) = raw.d(:,idx);
            filtered_nirs_data=filtfilt(B1,A1,squeeze(nirs_data(j,:,:)));
            cardiac_data(j,:,:)=filtered_nirs_data./repmat(std(filtered_nirs_data,0,1),size(filtered_nirs_data,1),1); % Normalized heartbeat
        end
        overlap_samples = floor(window*fs*overlap);
        window_samples = floor(window*fs);
        n_windows = floor((size(cardiac_data,2)-overlap_samples)/(window_samples-overlap_samples));
        cardiac_data = cardiac_data(find(lambda_mask),:,:);
        sci_array = zeros(size(cardiac_data,3),n_windows);    % Number of optode is from the user's layout, not the machine
        power_array = zeros(size(cardiac_data,3),n_windows);
        %fpower_array = zeros(size(cardiac_data,3),n_windows);
        cardiac_windows = zeros(length(lambdas),window_samples,n_channels,n_windows);
        for j = 1:n_windows
            interval = (j-1)*window_samples-(j-1)*(overlap_samples)+1 : j*window_samples-(j-1)*(overlap_samples);
            cardiac_windows(:,:,:,j) = cardiac_data(:,interval,:);
        end
        for j = 1:n_windows
            cardiac_window = cardiac_windows(:,:,:,j);
            sci_array_channels = zeros(1,size(cardiac_window,3));
            power_array_channels = zeros(1,size(cardiac_window,3));
            fpower_array_channels = zeros(1,size(cardiac_window,3));
            for k = 1:size(cardiac_window,3) % Channels iteration
                %cross-correlate the two wavelength signals - both should have cardiac pulsations
                similarity = xcorr(squeeze(cardiac_window(1,:,k)),squeeze(cardiac_window(2,:,k)),'unbiased');
                if any(abs(similarity)>eps)
                    % this makes the SCI=1 at lag zero when x1=x2 AND makes the power estimate independent of signal length, amplitude and Fs
                    similarity = length(squeeze(cardiac_window(1,:,k)))*similarity./sqrt(sum(abs(squeeze(cardiac_window(1,:,k))).^2)*sum(abs(squeeze(cardiac_window(2,:,k))).^2));
                else
                    warning('Similarity results close to zero');
                end
                [pxx,f] = periodogram(similarity,hamming(length(similarity)),length(similarity),fs,'power');
                [pwrest,idx] = max(pxx(f<fcut_max)); % FIX Make it age-dependent
                sci=similarity(length(squeeze(cardiac_window(1,:,k))));
                power=pwrest;
                fpower=f(idx);
                sci_array_channels(k) = sci;
                power_array_channels(k) = power;
                fpower_array_channels(k) = fpower;
            end
            sci_array(:,j) = sci_array_channels;    % Adjust not based on machine
            power_array(:,j) = power_array_channels;
            %    fpower_array(:,j) = fpower_array_channels;
        end
        
        % calculate WOI
        % Assuming no overlaped trials
        % The maximum number of allowed samples is window_samples*n_windows to consider
        % an integer number of windows, module(total_samples,n_windows) = 0
        
        fs = nirsplot_parameters.fs;
        n_channels = nirsplot_parameters.n_channels;
        s = nirsplot_parameters.s;
        t = nirsplot_parameters.t;
        mergewoi_flag = nirsplot_parameters.mergewoi_flag;
        n_channels = nirsplot_parameters.n_channels;
        if strcmp(nirsplot_parameters.cond_mask,'all')
            conditions_mask = ones(1,size(s,2));
        else
            conditions_mask = logical(nirsplot_parameters.cond_mask);
        end
        
        allowed_samp = window_samples*n_windows;
        poi = sum(s(1:allowed_samp,conditions_mask),2);
        poi = poi(1:allowed_samp);
        % Sometimes 's' variable encodes the stimuli durations by including consecutive
        % values of 1. We are interested on the onsets, then we remove consecutive ones.
        idxpoi = find(poi);
        poi = zeros(size(poi));
        poi(idxpoi(diff([0;idxpoi])>1)) = 1;
        nOnsets = length(find(poi));
        idxStim = find(poi);
        interOnsetTimes = t(idxStim(2:end)) - t(idxStim(1:end-1));
        medIntTime = median(interOnsetTimes);
        iqrIntTime = iqr(interOnsetTimes);
        %blckDurTime = (medIntTime/2) + (0.5*iqrIntTime);
        blckDurTime = medIntTime + (0.5*iqrIntTime);
        blckDurSamp = round(fs*blckDurTime);
        blckDurWind = floor(blckDurSamp/window_samples);
        woi = struct('mat',zeros(n_channels,n_windows),...
            'start',zeros(1,nOnsets),...
            'end',zeros(1,nOnsets));
        woi_array = zeros(1,n_windows);
        % Since we are relying on windows, we do not need the POIs variables instead
        % we need WOIs variables information
        for i=1:nOnsets
            startPOI = idxStim(i)-blckDurSamp;
            if startPOI < 1
                startPOI = 1;
            end
            startWOI = floor(startPOI/window_samples);
            if startWOI==0
                startWOI = 1;
            end
            
            endPOI = idxStim(i)+blckDurSamp;
            if endPOI > allowed_samp
                endPOI = allowed_samp;
            end
            endWOI = ceil(endPOI/window_samples);
            poi(startPOI:endPOI) = 1;
            woi_array(startWOI:endWOI) = 1;
            woi.start(i) = startWOI;
            woi.end(i) = endWOI;
        end
        
        % See my comment about the preference of WOIs rather than of POIs, if POI
        % information is needed, uncomment next two lines and return POIs variables
        % poi = poi';
        % poiMat_ = repmat(poi,n_channels,1);
        
        woiblank = 0;
        idxInit = [];
        %woitmp = woi_array;
        woitmp = woi_array;
        
        % If the gap's duration between two consecutives blocks of interest is less than the
        % block's average duration, then those two consecutives blocks will merge.
        % This operation has a visual effect (one bigger green block instead of
        % two green blocks with a small gap in between), and for quality
        % results, the windows inside of such a gap are now considered for quality computation.
        for i =1:n_windows
            if woitmp(i) == 0
                if isempty(idxInit)
                    idxInit = i;
                end
                woiblank = woiblank +1;
            else
                if ~isempty(idxInit)
                    if (woiblank <= blckDurWind)
                        woitmp(idxInit:i) = 1;
                    end
                    woiblank = 0;
                    idxInit = [];
                end
            end
        end
        if mergewoi_flag == true
            woi_array = woitmp;
        end
        woi.mat = repmat(woi_array,n_channels,1);


        % Summary analysis
        idxPoi = logical(woi.mat(1,:));
        
        
        mean_sci_link  = mean(sci_array(:,idxPoi),2);
        std_sci_link  = std(sci_array(:,idxPoi),0,2);
        good_sci_link = sum(sci_array(:,idxPoi)>=0.8,2)/size(sci_array(:,idxPoi),2);
        mean_sci_window  = mean(sci_array(:,idxPoi),1);
        std_sci_window  = std(sci_array(:,idxPoi),0,1);
        good_sci_window = sum(sci_array(:,idxPoi)>=0.8,1)/size(sci_array(:,idxPoi),1);
        
        mean_power_link  = mean(power_array(:,idxPoi),2);
        std_power_link  = std(power_array(:,idxPoi),0,2);
        good_power_link = sum(power_array(:,idxPoi)>=0.1,2)/size(power_array(:,idxPoi),2);
        mean_power_window  = mean(power_array(:,idxPoi),1);
        std_power_window  = std(power_array(:,idxPoi),0,1);
        good_power_window = sum(power_array(:,idxPoi)>=0.1,1)/size(power_array(:,idxPoi),1);
        
        combo_array = (sci_array >= 0.8) & (power_array >= 0.10);
        combo_array_expanded = 2*(sci_array >= 0.8) + (power_array >= 0.10);
        
        mean_combo_link  = mean(combo_array,2);
        std_combo_link  = std(combo_array,0,2);
        
        good_combo_link  = mean(combo_array(:,idxPoi),2);
        mean_combo_window  = mean(combo_array,1);
        std_combo_window  = std(combo_array,0,1);
        
        idx_gcl = good_combo_link>=qltyThld;
        good_combo_window = mean(combo_array(idx_gcl,:),1);
        
        % Detecting experimental blocks
        exp_blocks = zeros(1,length(woi.start));
        for iblock = 1:length(woi.start)
            block_start_w = woi.start(iblock);
            block_end_w = woi.end(iblock);
            exp_blocks(iblock) = mean(good_combo_window(block_start_w:block_end_w));
        end
        
        % Detect artifacts and bad links
        bad_links = find(mean_combo_link<qltyThld);
        bad_windows = find(mean_combo_window<qltyThld);
        
        % Packaging sci, peakpower and combo
        qualityMatrices.sci_array    = sci_array;
        qualityMatrices.power_array  = power_array;
        qualityMatrices.combo_array  = combo_array;
        qualityMatrices.combo_array_expanded = combo_array_expanded;
        qualityMatrices.bad_links    = bad_links;
        qualityMatrices.bad_windows  = bad_windows;
        qualityMatrices.sampPerWindow = window_samples;
        qualityMatrices.fs = fs;
        qualityMatrices.n_windows = n_windows;
        qualityMatrices.cardiac_data = cardiac_data;
        qualityMatrices.good_combo_link = good_combo_link;
        qualityMatrices.good_combo_window = good_combo_window;
        qualityMatrices.woi = woi;
        qualityMatrices.MeasListAct = [idx_gcl; idx_gcl];


end
