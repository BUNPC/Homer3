function quality_matrices = nirsplot(dotNirsFilePath,varargin)
% NIRSPLOT is a Matlab-based tool for the quality assessment of fNIRS data. 
% Nirsplot can quantify the quality of an fNIRS recording in two different ways, by using a GUI or through a function call.
% Graphically, the Nirsplot GUI allows the user to locate a working folder for processing and quantifying the .nirs files within the working folder. 
% Programmatically, the users also can retrieve a set of quality measures by calling nirsplot from a Matlab script. 
%

% Usage information
% Using Nirsplot inside of a script allows the users to specify a set of 
% parameters for the quality assessment. The 'dotNirsFilePath' parameter 
% can be the path of a .nirs file or the path to a folder containing 
% several .nirs files or a struct containing:
%              d 
%              t 
%      CondNames
%            aux
%              s 
%             SD 
%     procResult
%       userdata 
%      procInput

% In addition to the .nirs path, the user 
% can specify a list of parameters in a pairwise mode including:
% 
% Parameter keyword Description
%  freqCut:   1x2 array [fmin fmax] representing the bandpass of the cardiac pulsation (default [0.5 2.5])
%  window :   length in seconds of the window to partition the signal with (defaut: 5)
%  overlap:     fraction overlap (0..0.99) between adjacent windows (default: 0, no overlap)
%  qualityThreshold:   The required quality value (normalized; 0-1) of good-quality windows in every channel (default: 0.75)
%  conditionsMask:   A binary mask (or the keyword 'all') to indicate the conditions for computing the periods of interest (default: 'all')
%  lambdaMask:    A binary array mapping the selected two wavelength to compute the SCI (default: [1 1], the first two WLs)
%  dodFlag:     A flag indicating to work from DOD data (default: 0)
%  guiFlag:     A flag indicating whether to start or not the GUI.

%
% 
% An example of Nirsplot usage is:
% 
% bpFmin = 0.5; bpFmax = 2.5;
% windowSec = 5;
% windowOverlap = 0;
% quality_threshold = 0.9;
% qualityMatrices = nirsplot([pwd,filesep,'tmpDotNirs.nirs'],...
%                 'freqCut',[bpFmin, bpFmax],...
%                 'window',windowSec,...
%                 'overlap',windowOverlap,....
%                 'qualityThreshold',quality_threshold,...
%                 'conditionsMask','all',...
%                 'dodFlag',0,...
%                 'guiFlag',0);
% 
% The 'qualityMatrices' output variable is an structure that includes the set of fields:
% 
% sci_array: Matrix containing the SCI values (dimension: #timewindows X #channels)
% power_array: Matrix containing the PeakPower values (dimension: #timewindows X #channels)
% combo_array: Matrix containing the QualityMask values (dimension: #timewindows X #channels)
% combo_array_expanded: Matrix containing the QualityMask values for the advanced mode (#timewindows X #channels)
% bad_links: List of the channels (averaged across timewindows) below the 'qualityThreshold' value
% bad_windows: List of the timewindows (averaged across channels) below the 'qualityThreshold' value
% sampPerWindow: Samples within a time window
% fs: Sampling frequency
% n_windows: Number of time windows
% cardiac_data: Filtered version of the fNIRS data (dimension: #WLs X #samples X #channels)
% good_combo_link: List of the channels (averaged across the time windows) above the 'qualityThreshold' value
% good_combo_window: List of the time windows (averaged across the channels) above the 'qualityThreshold' value
% woi: Data structure cointaining the Windows of Interest information (epochs of interest throughout the recording)
% MeasListAct: Array mask of the channels achieving the required level of quality (length: #Channels X #WLs)

if nargin < 1
    nirsplotLoadFileGUI();
    return;
end

if ischar(dotNirsFilePath)
    if isfile(dotNirsFilePath)
        [filepath,name,ext] = fileparts(dotNirsFilePath);
        if strcmpi(ext,'.nirs')
            rawDotNirs = load(dotNirsFilePath,'-mat');
        else
            error('The input file should be a .nirs file format');
            %We should check that the required variables are in the file
        end
    elseif isfolder(dotNirsFilePath)
        disp(['The input data is a folder. ',...
            'All .nirs files inside ',dotNirsFilePath,' will be evaluated.']);
        nirsplotLoadFileGUI(dotNirsFilePath);
        return;
    else
        error('The input path does not exist.');
    end
elseif isstruct(dotNirsFilePath) || isa(dotNirsFilePath,'NirsClass')
    rawDotNirs = dotNirsFilePath;
    filepath = pwd;
    name = 'NirsplotAnalized';
    ext = '.nirs';
end

propertyArgIn = varargin;
while length(propertyArgIn) >= 2
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
        case 'freqCut'
            if isfloat(val) && length(val)==2
                fcut_ = [min(val) max(val)];
            end
            
        case 'window'
            if length(val)==1
                window_ = ceil(val);
            end
            
        case 'overlap'
            if isfloat(val) && val >= 0 && val <= 1
                overlap_ = val;
            end
            
        case 'qualityThreshold'
            if isfloat(val) && val >= 0 && val <= 1
                q_threshold = val;
            end
            
        case 'conditionsMask'
            if (ischar(val) && strcmp(val,'all')) || ~(any(val>1 | val<0))
                cond_mask = val;
            end
            
        case 'lambdaMask'
            if (ischar(val) && strcmp(val,'all')) || ~(any(val>1 | val<0))
                lambda_mask_ = val;
            end
            
        case 'dodFlag'
            if val == 1
                dodFlag_ = 1; 
            else
                dodFlag_ = 0;
            end
        case 'guiFlag'
            if val == 1
                guiFlag_ = 1;
            else
                guiFlag_ = 0;
            end
    end
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
if ~(sum(strcmp(fieldnames(rawDotNirs), 's')) == 1)
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
        error('Stimuli information is not available.');
    end
end


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
    nirsplotLoadFileGUI(nirsplot_parameters)
end
report_table = [];


% Create GUI
[main_fig_axes,main_fig] = createGUI();

nirsplot_parameters.main_fig_axes = main_fig_axes;
setappdata(main_fig,'nirsplot_parameters',nirsplot_parameters);
setappdata(main_fig,'rawDotNirs',rawDotNirs);

% Computation
[quality_matrices] = qualityCompute(main_fig);
nirsplot_parameters.quality_matrices = quality_matrices;

setappdata(main_fig,'nirsplot_parameters',nirsplot_parameters);

if guiFlag_ == 1
    main_fig.Visible = 'on';
    detViewCheckb = findobj('Tag','detViewCheckb');
    updateQPlots(detViewCheckb,[]);
    %rawNT = nirs.io.loadDotNirs(dotNirsFilePath,true);
    %rawNT.draw(1:(nirsplot_parameters.n_channels * 2),[],main_fig_axes.inspector);
else
    close(main_fig);
end

if nirsplot_parameters.save_report_table == true
    report_table = saveQuality(quality_matrices);
end
% Wait for calls


%% -------------------------------------------------------------------------
    function [main_fig_axes,main_fig] = createGUI()
        
        % Main figure container
        pos.main = [0.125 0.05 0.75 0.85]; % left, bottom, width, height
        main_fig = figure('Units','normalized',...
            'Position',pos.main,'Visible','off',...
            'Name','NIRSPlot','NumberTitle','off','MenuBar','none');
        
        % Axes
        % SCI
        myAxDim.width = 0.9;
        myAxDim.height = (1/4)*0.75; % Four axes over the 80% of the figure
        myAxDim.xSep = 0.04;
        myAxDim.ySep = (1 - myAxDim.height*4) / 5;
        
        pos.inspAx = [myAxDim.xSep,myAxDim.ySep+(0*(myAxDim.height+myAxDim.ySep)),...
            myAxDim.width,myAxDim.height];
        main_fig_axes.inspector = axes(main_fig,'Units','normalized',...
            'Position',pos.inspAx,...
            'Title','Inspector');
        main_fig_axes.inspector.XLabel.String = 'Time (s)';
        main_fig_axes.inspector.YLabel.String = 'Channel #';
        
        pos.comboAx = [myAxDim.xSep,myAxDim.ySep+(1.05*(myAxDim.height+myAxDim.ySep)),...
            myAxDim.width,myAxDim.height];
        main_fig_axes.combo = axes(main_fig,'Units','normalized',...
            'Position',pos.comboAx,...
            'Title','Overall quality');
        main_fig_axes.combo.YLabel.String = 'Channel #';
        main_fig_axes.combo.YLabel.FontWeight = 'bold';
        colorbar(main_fig_axes.combo,'Visible','off','Tag','colorb_combo')
        
        
        pos.powerAx = [myAxDim.xSep,myAxDim.ySep+(2*(myAxDim.height+myAxDim.ySep)),...
            myAxDim.width,myAxDim.height];
        main_fig_axes.power = axes(main_fig,'Units','normalized',...
            'Position',pos.powerAx,...
            'Title','Power peak');
        main_fig_axes.power.YLabel.String = 'Channel #';
        main_fig_axes.power.YLabel.FontWeight = 'bold';
        colorbar(main_fig_axes.power,'Visible','off','Tag','colorb_power')
        
        
        pos.sciAx = [myAxDim.xSep,myAxDim.ySep+(3*(myAxDim.height+myAxDim.ySep)),...
            myAxDim.width,myAxDim.height];
        main_fig_axes.sci = axes(main_fig,'Units','normalized',...
            'Position',pos.sciAx,...
            'Title','SCI');
        main_fig_axes.sci.YLabel.String = 'Channel #';
        main_fig_axes.sci.YLabel.FontWeight = 'bold';
        colorbar(main_fig_axes.sci,'Visible','on','Tag','colorb_sci')
        
        pos.inspectBtn = [myAxDim.xSep, (myAxDim.height+myAxDim.ySep)*1.025,...
            0.08, myAxDim.ySep*0.7];
        uicontrol(main_fig,'Style', 'pushbutton', 'String', 'Inspect',...
            'FontSize',12,'FontWeight','bold','Units','normalized','Position', pos.inspectBtn,...
            'Callback', @inspectActive,'Tag','inspectBtn');
        
        pos.helpBtn = [pos.inspectBtn(1)+pos.inspectBtn(3)+myAxDim.xSep,...
            pos.inspectBtn(2),0.05,pos.inspectBtn(4)];
        uicontrol(main_fig,'Style','pushbutton','String','?',...
            'FontSize',12,'FontWeight','bold','Units','normalized','Position',...
            pos.helpBtn,'Callback', @showHelp,'Tag','helpBtn');
        
        pos.chSelBtn = [pos.helpBtn(1)+pos.helpBtn(3)+myAxDim.xSep,...
            pos.inspectBtn(2),0.15,pos.inspectBtn(4)];
        uicontrol(main_fig,'Style','pushbutton','String','Channel selection',...
            'FontSize',12,'FontWeight','bold','Units','normalized','Position',...
            pos.chSelBtn,'Callback', @selectGoodChannels,'Tag','chSelBtn');
        
        % pos.woiSelBtn = [(pos.chSelBtn(1)+pos.chSelBtn(3))*1.15,...
        %     pos.inspectBtn(2),0.15,pos.inspectBtn(4)];
        % woiSelBtn = uicontrol(mainFig,'Style','pushbutton','String','WOI selection',...
        %     'FontSize',14,'FontWeight','bold','Units','normalized','Position',...
        %     pos.woiSelBtn,'Callback', @selectGoodWOI);
        
        
        pos.AdvView = [pos.chSelBtn(1)+pos.chSelBtn(3)+myAxDim.xSep,...
            pos.inspectBtn(2),...
            0.1,...
            pos.inspectBtn(4)];
        uicontrol(main_fig,'Style','checkbox','String','Advanced',...
            'FontSize',12,'FontWeight','bold','Units','normalized','Position',...
            pos.AdvView,'Callback', @updateQPlots,'Tag','detViewCheckb');
        
        pos.SaveBtn = [pos.AdvView(1)+pos.AdvView(3)+myAxDim.xSep,...
            pos.inspectBtn(2),0.1,pos.inspectBtn(4)];
        uicontrol(main_fig,'Style','pushbutton','String','Save .nirs',...
            'FontSize',12,'FontWeight','bold','Units','normalized','Position',...
            pos.SaveBtn,'Callback', @save2dotnirs, 'Tag','saveBtn','Enable','off');
        
        %main_fig.Visible = 'on';
        
    end

%% -------------------------------------------------------------------------
    function showHelp(source,event)
        helpFig =  figure('Units','normalized',...
            'Visible','off','Position',[0.3,0.3,0.3,0.2],...
            'Name','NIRSPlot Help','NumberTitle','off','MenuBar','none');
        helpStr = sprintf(['Controls\nLeft-click: Select a window and channel \n',...
            'Right-click: Select the complete channel \n',...
            'Up|Down key: move up/down one channel \n',...
            'Left|Right key: move forward/backward one window \n',...
            'ESC key: exit from the Inspector mode']);
        pos.helpTxt = [0.1,0,0.9,0.9];
        uicontrol(helpFig,'Style','text','String',helpStr,...
            'FontSize',14,'Units','normalized','Position',pos.helpTxt,...
            'HorizontalAlignment','left');
        helpFig.Visible='on';
    end

%% -------------------------------------------------------------------------
    function inspectActive(source,event)
        
        nirsplot_param = getappdata(source.Parent,'nirsplot_parameters');
        n_channels = nirsplot_param.n_channels;
        qMats = nirsplot_param.quality_matrices;
        s = nirsplot_param.s;
        t = nirsplot_param.t;
        
        button = 0;
        flagDispWindow = false;
        pastChannel = 0;
        pastWindow = 0;
        while button ~= 27
            [iWindow,iChannel,button] = my_ginput(1);
            iWindow = round(iWindow);
            iChannel = round(iChannel);
            switch button
                case 1
                    flagDispWindow = true;
                case 3
                    xLimWindow = [1,(qMats.sampPerWindow*qMats.n_windows)];
                    pastChannel = iChannel;
                    flagDispWindow = false;
                case 28 % left-arrow key
                    if flagDispWindow==true
                        iWindow = pastWindow - 1;
                    end
                    iChannel = pastChannel;
                case 29 % right-arrow key
                    if flagDispWindow==true
                        iWindow = pastWindow + 1;
                    end
                    iChannel = pastChannel;
                case 30 % up-arrow key
                    if flagDispWindow==true
                        iChannel = pastChannel - 1;
                        iWindow = pastWindow;
                    else
                        iChannel = pastChannel - 1;
                    end
                case 31 % down-arrow key
                    if flagDispWindow==true
                        iChannel = pastChannel + 1;
                        iWindow = pastWindow;
                    else
                        iChannel = pastChannel + 1;
                    end
            end
            if flagDispWindow == true
                %xLimWindow = [(qMats.sampPerWindow*iWindow)+1,...
                %    qMats.sampPerWindow*(iWindow+1)];
                xLimWindow = [(qMats.sampPerWindow*(iWindow-1))+1,...
                    (qMats.sampPerWindow*iWindow)];
            end
            if button ~=27
                if iChannel>0 && iChannel<=n_channels && iWindow>0 && iWindow<=qMats.n_windows
                    updateIPlot(source,iChannel,xLimWindow,iWindow,s,t);
                    pastWindow = iWindow;
                    pastChannel = iChannel;
                end
            end
        end
    end

%% -------------------------------------------------------------------------
    function updateQPlots(source,event)
        % UpdatePlot updates the quality plots with the 'qualityMats' input arg
        % bad channels are ploted according to 'plot_bad' flag
        nirsplot_param = getappdata(source.Parent,'nirsplot_parameters');
        qMats = nirsplot_param.quality_matrices;
        myAxes = nirsplot_param.main_fig_axes;
        n_channels = nirsplot_param.n_channels;
        woi = nirsplot_param.quality_matrices.woi;
        sclAlpha = nirsplot_param.sclAlpha;
        
        %Unpacking
        sci_array = qMats.sci_array;
        power_array = qMats.power_array;
        combo_array = qMats.combo_array;
        combo_array_expanded = qMats.combo_array_expanded;
        
        woiMatrgb = zeros(n_channels,qMats.n_windows,3);
        woiMatrgb(:,:,:) = repmat(~woi.mat,1,1,3)*(hex2dec('bf')/255);
        alphaMat = ~woi.mat * sclAlpha;
        
        advancedView = source.Value;
        mygray = [0 0 0; repmat([0.7 0.7 0.7],100,1); 1 1 1];
        mymap = [0 0 0;repmat([1 0 0],100,1);1 1 1 ];
        
        colorb_sci = findobj('Tag','colorb_sci');
        if advancedView
            % WE USE OPTION 1, BUT ONLY NEED TO "EXTEND" THE COMBO VIEW
            sci_threshold = 0.8;
            sci_mask = sci_array>=sci_threshold;
            power_threshold = 0.1;
            power_mask = power_array>=power_threshold;
            qualityColor = [0 0 0; 0.6 0.6 0.6; 1 1 1];
            % Scalp Contact Index
            %cla(myAxes.sci)
            

            % thresholds a & b
            a = 0.6;
            b = 0.8;
            sci_expanded = zeros(size(sci_array));
            sci_expanded(sci_array <  a) = 0;
            sci_expanded(sci_array >= a & sci_array<b) = 1;
            sci_expanded(sci_array >= b) = 2;
            %--             Option 1
            %imagesc(myAxes.sci,sci_expanded);
            %colormap(myAxes.sci,qualityColor);
            imagesc(myAxes.sci,sci_mask);
            colormap(myAxes.sci,[0 0 0; 1 1 1]);
            myAxes.sci.CLim = [0,2];
            colorbar(myAxes.sci,"eastoutside",...
                "Ticks",[ 0 1 2 ],...
                'TickLabels',{[char(hex2dec('2717')), 'SCI <=',num2str(a)],...
                [num2str(a),'< SCI <',num2str(b)],...
                [char(hex2dec('2713')), 'SCI >=',num2str(b)]},...
                'Limits',[0 2],...
                'ButtonDownFcn',@sciThreshold);
            %--             Option 2
            %             imagesc(myAxes.sci,sci_expanded);
            %             myAxes.sci.CLim = [a, b];
            %             colormap(myAxes.sci,mygray);
            %             colorbar(myAxes.sci,"eastoutside",...
            %                 "Ticks",[(a-(b-a)) a  b b+(b-a)],...
            %                 'TickLabels',{['<',num2str(a-(b-a))],...
            %                 num2str(a),num2str(b),...
            %                 ['>',num2str(b+(b-a))]},...
            %                 'Limits',[(a-(b-a)) b+(b-a)]);
            
            
            % Power peak
            a = 0.06;
            b = 0.1;
            power_expanded = zeros(size(power_array));
            power_expanded(power_array <  a) = 0;
            power_expanded(power_array >= a & power_array<b) = 1;
            power_expanded(power_array >= b) = 2;
            %imagesc(myAxes.power,power_expanded);
            %colormap(myAxes.power,qualityColor);
            imagesc(myAxes.power,power_mask);
            colormap(myAxes.power,[0 0 0; 1 1 1]);
            myAxes.power.CLim = [0,2];
            colorbar(myAxes.power,"eastoutside",...
                "Ticks",[ 0 1 2 ],...
                'TickLabels',{[char(hex2dec('2717')), 'Power <=',num2str(a)],...
                [num2str(a),'< Power <',num2str(b)],...
                [char(hex2dec('2713')), 'Power >=',num2str(b)]},...
                'Limits',[0 2]);
            %             imagesc(myAxes.power,power_array);
            %             a = 0.06;
            %             b = 0.1;
            %             myAxes.power.CLim = [a, b];
            %             myAxes.power.YLim =[1, n_channels];
            %             colormap(myAxes.power,mygray);
            %             colorbar(myAxes.power,"eastoutside",...
            %                 "Ticks",[(a-(b-a)) a  b b+(b-a)],...
            %                 'TickLabels',{['<',num2str(a-(b-a))],...
            %                 num2str(a),num2str(b),...
            %                 ['>',num2str(b+(b-a))]},...
            %                 'Limits',[(a-(b-a)) b+(b-a)]);
            %             myAxes.power.YLabel.String = 'Channel #';
            %             myAxes.power.YLabel.FontWeight = 'bold';
            
            % Combo quality
            imagesc(myAxes.combo,combo_array_expanded);
            myAxes.combo.CLim = [1, 3];
            %myAxes.combo.YLim =[1, n_channels];
            %myAxes.combo.XLim =[1, size(combo_array,2)];
            %colormap(myAxes.combo,[0 0 0;1 1 1]);
            % SCI,Power   combo_array_expanded    QualityColor
            %  0,0              0                   [0 0    0]
            %  0,1              1                   [0 0    0]
            %  2,0              2                   [0.7 0.7 0.7]
            %  2,1              3                   [0 1    0]
            qualityColor = [0 0 0; 0 0 0; 1 0 0; 1 1 1];
            colormap(myAxes.combo,qualityColor);
            colorbar(myAxes.combo,"eastoutside","Ticks",[1.3 1.5 2.25 2.75],...
                'TickLabels',...
                {[char(hex2dec('2717')),'SCI  ', char(hex2dec('2717')),'Power'],...
                [char(hex2dec('2717')),'SCI  ', char(hex2dec('2713')),'Power'],...
                [char(hex2dec('2713')),'SCI  ', char(hex2dec('2717')),'Power'],...
                [char(hex2dec('2713')),'SCI  ', char(hex2dec('2713')),'Power']});
            myAxes.combo.YLabel.String = 'Channel #';
            myAxes.combo.YLabel.FontWeight = 'bold';
            
            hold(myAxes.sci,'on');
            hold(myAxes.power,'on');
            hold(myAxes.combo,'on');
            
            % Drawing green bands
            imagesc(myAxes.sci,woiMatrgb,'AlphaData',alphaMat);
            %hold(myAxes.power,'on');
            imagesc(myAxes.power,woiMatrgb,'AlphaData',alphaMat);
            %hold(myAxes.combo,'on');
            imagesc(myAxes.combo,woiMatrgb,'AlphaData',alphaMat);
        else
            % Scalp Contact Index
            sci_threshold = 0.8;
            sci_mask = sci_array>=sci_threshold;
            
            %cla(myAxes.sci);
            imagesc(myAxes.sci,sci_mask);
            myAxes.sci.CLim = [0,1];
            %myAxes.sci.YLim =[0.5, n_channels+0.5];
            %myAxes.sci.XLim = [0.5 size(sci_mask,2)+0.5];
            ticksVals = linspace(0,qMats.n_windows,8);
            myAxes.sci.XAxis.TickValues=ticksVals(2:end-1);
            ticksLab = round(linspace(0,nirsplot_param.t(end),8));
            myAxes.sci.XAxis.TickLabels=split(num2str(ticksLab(2:end-1)));
            myAxes.sci.Colormap = [0 0 0;1 1 1];
            colorbar(myAxes.sci,'eastoutside',...
                'Tag','colorb_sci',...
                'Ticks',[0.25 0.75],...
                'Limits',[0,1],'TickLabels',{'Bad','Good'});
            myAxes.sci.YLabel.String = 'Channel #';
            myAxes.sci.YLabel.FontWeight = 'bold';
            
            
            % Power peak
            power_threshold = 0.1;
            power_mask = power_array>=power_threshold;
            imagesc(myAxes.power,power_mask);
            myAxes.power.CLim = [0, 1];
            %myAxes.power.YLim =[1, n_channels];
            myAxes.power.XAxis.TickValues=ticksVals(2:end-1);
            myAxes.power.XAxis.TickLabels=split(num2str(ticksLab(2:end-1)));
            myAxes.power.Colormap = [0 0 0;1 1 1];
            colorbar(myAxes.power,"eastoutside","Ticks",[0.25 0.75],...
                'Limits',[0,1],'TickLabels',{'Bad','Good'});
            myAxes.power.YLabel.String = 'Channel #';
            myAxes.power.YLabel.FontWeight = 'bold';
            
            % Combo quality
            imagesc(myAxes.combo,combo_array);
            myAxes.combo.CLim = [0, 1];
            %myAxes.combo.YLim =[1, n_channels];
            myAxes.combo.Colormap = [0 0 0;1 1 1];
            myAxes.combo.XAxis.TickValues=ticksVals(2:end-1);
            myAxes.combo.XAxis.TickLabels=split(num2str(ticksLab(2:end-1)));
            colorbar(myAxes.combo,"eastoutside","Ticks",[0.25 0.75],...
                'Limits',[0,1],'TickLabels',{'Bad','Good'});
            myAxes.combo.YLabel.String = 'Channel #';
            myAxes.combo.YLabel.FontWeight = 'bold';
            
            % Drawing grey bands (periods of no interest)
            hold(myAxes.sci,'on');
            hold(myAxes.power,'on');
            hold(myAxes.combo,'on');
            imagesc(myAxes.sci,woiMatrgb,'AlphaData',alphaMat);
            imagesc(myAxes.power,woiMatrgb,'AlphaData',alphaMat);
            imagesc(myAxes.combo,woiMatrgb,'AlphaData',alphaMat);
        end
        
        % For visual consistency among axes
        myAxes.inspector.YLimMode = 'manual';
        myAxes.inspector.YLabel.String = 'Channel #';
        myAxes.inspector.XLabel.String = 'Time (s)';
        myAxes.inspector.YLabel.FontWeight = 'bold';
        myAxes.inspector.XLabel.FontWeight = 'bold';
        colorbar(myAxes.inspector,'Visible','off');
        
    end

%% -------------------------------------------------------------------------
    function updateIPlot(source,iChannel,xLimWindow,iWindow,s,t)
        raw = getappdata(source.Parent,'rawDotNirs');
        nirsplot_param = getappdata(source.Parent,'nirsplot_parameters');
        qMats = nirsplot_param.quality_matrices;
        myAxes = nirsplot_param.main_fig_axes;
        n_channels = nirsplot_param.n_channels;
        conditions_mask = nirsplot_param.cond_mask;
        woi = nirsplot_param.quality_matrices.woi;
        fs = nirsplot_param.fs;
        fcut = nirsplot_param.fcut;
      
        rectangle_line_width = nirsplot_param.rectangle_line_width;
        sclAlpha = nirsplot_param.sclAlpha;
        dViewCheckb = findobj('Tag','detViewCheckb');
        
        myAxes.inspector.XLim= [t(xLimWindow(1)),t(xLimWindow(2))];
        YLimStd = [min(qMats.cardiac_data(:,xLimWindow(1):xLimWindow(2),iChannel),[],'all'),...
            max(qMats.cardiac_data(:,xLimWindow(1):xLimWindow(2),iChannel),[],'all')]*1.05;
        XLimStd = myAxes.inspector.XLim;
        
        % Normalization of cardiac_data between [a,b]
        a = -1;
        b =  1;
        cardiac_wl1_norm = a + (((qMats.cardiac_data(1,xLimWindow(1):xLimWindow(2),iChannel)-YLimStd(1)).*(b-a))./ (YLimStd(2)-YLimStd(1)));
        cardiac_wl2_norm = a + (((qMats.cardiac_data(2,xLimWindow(1):xLimWindow(2),iChannel)-YLimStd(1)).*(b-a))./ (YLimStd(2)-YLimStd(1)));
        YLimStd = [a,b].*1.05;
        cla(myAxes.inspector);
        
        plot(myAxes.inspector,t(xLimWindow(1):xLimWindow(2)),...
            cardiac_wl1_norm,'-b');
        hold(myAxes.inspector,'on');
        plot(myAxes.inspector,t(xLimWindow(1):xLimWindow(2)),...
            cardiac_wl2_norm,'-r');
        
        if(isfield(raw.SD,'Lambda'))
             WLs = raw.SD.Lambda;
            strLgnds = {num2str(WLs(1)),num2str(WLs(2))};
        else
            strLgnds = {'\lambda 1','\lambda 2'};
        end
        
        updateQPlots(dViewCheckb,[]);
        
        if (xLimWindow(2)-xLimWindow(1)+1) == (qMats.n_windows*qMats.sampPerWindow)
            xRect = 0.5; %Because of the offset at the begining of a window
            yRect = iChannel-0.5;
            wRect = qMats.n_windows;
            hRect = 1;
            poiMatrgb = zeros(n_channels,xLimWindow(2),3);
            poiMatrgb(:,:,:) = repmat(repelem(~woi.mat(1,:),qMats.sampPerWindow),n_channels,1,3).*(hex2dec('bf')/255);
            alphaMat = poiMatrgb(:,:,1) * sclAlpha;
            
            impoiMat = imagesc(myAxes.inspector,'XData',...
                [t(xLimWindow(1)),t(xLimWindow(2))],...
                'YData',YLimStd,'CData',poiMatrgb,'AlphaData',alphaMat);
            ticksVals = linspace(0,XLimStd(2),8);
            myAxes.inspector.XAxis.TickValues=ticksVals(2:end-1);
            ticksLab = round(linspace(0,nirsplot_param.t(end),8));
            myAxes.inspector.XAxis.TickLabels=split(num2str(ticksLab(2:end-1)));
            % Drawing onsets
            c = sum(conditions_mask);
            COI = find(conditions_mask);
            if c<9
                colorOnsets = colorcube(8);
            else
                colorOnsets = colorcube(c+1);
                colorOnsets = colorOnsets(1:end-1,:);
            end
            
            for j=1:c
                %mapping from 0,1 to 0,25%ofPeakToPeak
                yOnset = (s(xLimWindow(1):xLimWindow(2),COI(j))*(YLimStd(2)-YLimStd(1))*0.25)-abs(YLimStd(1));
                plot(myAxes.inspector,t(xLimWindow(1):xLimWindow(2)),...
                    yOnset,'LineWidth',2,...
                    'Color',colorOnsets(j,:));
                strLgnds(2+j) = {['Cond ',num2str(COI(j))]};
            end
            
        else
            ticksVals = linspace(myAxes.inspector.XAxis.Limits(1),myAxes.inspector.XAxis.Limits(2),8);
            myAxes.inspector.XAxis.TickValues=ticksVals(2:end-1);
            ticksLab = round(ticksVals);
            myAxes.inspector.XAxis.TickLabels=split(num2str(ticksLab(2:end-1)));
            
            xRect = iWindow-0.5;
            yRect = iChannel-0.5;
            xQlabels = xRect + 1;
            yQlabels = yRect + 1;
            wRect = 1;
            hRect = 1;
            
            fprintf('SCI:%.3f \t Power:%.3f\n',qMats.sci_array(iChannel,iWindow),qMats.power_array(iChannel,iWindow));
            textHAlign = 'left';
            textVAlign = 'top';
            if xRect > (qMats.n_windows/2)
                textHAlign = 'right';
                 xQlabels = xRect - 0.5;
            end
            if yRect > (n_channels/2)
                textVAlign = 'bottom';
                yQlabels = yRect - 0.5;
            end
            text(myAxes.power,xQlabels,yQlabels,num2str(qMats.power_array(iChannel,iWindow),'%.3f'),...
                'Color','red','FontSize',10,'FontWeight','bold','BackgroundColor','#FFFF00',...
                'Margin',1,'Clipping','on',...
                'HorizontalAlignment',textHAlign,'VerticalAlignment',textVAlign);
            text(myAxes.sci,xQlabels,yQlabels,num2str(qMats.sci_array(iChannel,iWindow),'%.3f'),...
                'Color','red','FontSize',10,'FontWeight','bold','BackgroundColor','#FFFF00',...
                'Margin',1,'Clipping','on',...
                'HorizontalAlignment',textHAlign,'VerticalAlignment',textVAlign);
            %--graphical debug
            %graphicDebug(qMats.cardiac_data(1,xLimWindow(1):xLimWindow(2),iChannel),...
            %     qMats.cardiac_data(2,xLimWindow(1):xLimWindow(2),iChannel),fs,fcut);
            %figure(source.Parent); 
        end
        myAxes.inspector.YLim = YLimStd;
        myAxes.inspector.XLim = XLimStd;
        myAxes.inspector.YLabel.String = ['Channel ', num2str(iChannel)];
        
        lgn = legend(myAxes.inspector,strLgnds,'Box','off','FontSize',10);
        
        rectangle(myAxes.combo,'Position',[xRect yRect wRect hRect],...
            'EdgeColor','m','FaceColor','none','Linewidth',rectangle_line_width);
        rectangle(myAxes.power,'Position',[xRect yRect wRect hRect],...
            'EdgeColor','m','FaceColor','none','Linewidth',rectangle_line_width);
        rectangle(myAxes.sci,'Position',[xRect yRect wRect hRect],...
            'EdgeColor','m','FaceColor','none','Linewidth',rectangle_line_width);
        
    end

%% -------------------------------------------------------------------------
    function [qualityMats] = qualityCompute(main_fig)
        raw = getappdata(main_fig,'rawDotNirs');
        nirsplot_param = getappdata(main_fig,'nirsplot_parameters');
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
        
        % Summary analysis
        [woi] = getWOI(window_samples,n_windows,nirsplot_param);
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
        qualityMats.sci_array    = sci_array;
        qualityMats.power_array  = power_array;
        qualityMats.combo_array  = combo_array;
        qualityMats.combo_array_expanded = combo_array_expanded;
        qualityMats.bad_links    = bad_links;
        qualityMats.bad_windows  = bad_windows;
        qualityMats.sampPerWindow = window_samples;
        qualityMats.fs = fs;
        qualityMats.n_windows = n_windows;
        qualityMats.cardiac_data = cardiac_data;
        qualityMats.good_combo_link = good_combo_link;
        qualityMats.good_combo_window = good_combo_window;
        qualityMats.woi = woi;
        qualityMats.MeasListAct = [idx_gcl; idx_gcl];
        %
    end




%% -------------------------------------------------------------------------
    function [woi] = getWOI(window_samples,n_windows,nirsplot_parameters)
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
    end

%% -------------------------------------------------------------------------
    function dotNirsOutput = selectGoodChannels(source, events)
        bpGoodQuality(source.Parent);
        uiwait(source.Parent);
        nirsplot_param = getappdata(source.Parent,'nirsplot_parameters');
        if isfield(nirsplot_param.quality_matrices,'active_channels')
            disp(['Threshold was changed to ',num2str(nirsplot_param.quality_threshold)]);
            saveBtn = findobj('Tag','saveBtn');
            saveBtn.Enable = 'on';
        end
        dotNirsOutput = 0;
    end

%% -------------------------------------------------------------------------
%!This function is not tested yet!
    function report_table = saveQuality()
        qMats = getappdata(source.Parent,'qualityMats');
        
        report_table = table({qMats.bad_links'}, {qMats.bad_windows});
        report_table.Properties.VariableNames = {'file_idx','Bad_Links','Bad_Windows'};
        
        for i=1:size(report_table,1)
            a = report_table.Bad_Links{i};
            b = report_table.Bad_Windows{i};
            a1 = num2str(a);
            b1 = num2str(b);
            report_table.Bad_Links{i} = a1;
            report_table.Bad_Windows{i} = b1;
        end
        
        
        writetable(report_table,'Quality_Report.xls');
    end

%% -------------------------------------------------------------------------
    function saving_status = save2dotnirs(source, events)
        nirsplot_param = getappdata(source.Parent,'nirsplot_parameters');
        raw = getappdata(source.Parent,'rawDotNirs');
        active_channels = nirsplot_param.quality_matrices.active_channels;
        dotNirsFileName = nirsplot_param.dotNirsFile;
        dotNirsPath = nirsplot_param.dotNirsPath;        
        % saving the indices of good-quality channels
        SD = raw.SD;
%        SD.MeasListAct = [active_channels; ones(size(SD.MeasList,1)/2,1)];
        SD.MeasListAct = [active_channels; active_channels];
        t = raw.t;
        d = raw.d;
        s = raw.s;
        if isfield(raw, 'aux')
            aux = raw.aux;
        else
            aux = [];
        end
        tIncMan = ones(length(t),1);
        save([dotNirsPath,filesep,dotNirsFileName,'_nirsplot-proc.nirs'],'SD','t','d','s','aux','tIncMan');
        %Notify to the user if the new file was succesfully created
        saving_status = exist([dotNirsPath,filesep,dotNirsFileName,'_nirsplot-proc.nirs'],'file');
        if saving_status
            msgbox('Operation Completed','Success');
        else
            msgbox('Operation Failed','Error');
        end
        
    end

%%
    function graphicDebug(window1,window2,fs,fcut)
        %cross-correlate the two wavelength signals - both should have cardiac pulsations
        [similarity,lags] = xcorr(window1,window2,'unbiased');
        if any(abs(similarity)>eps)
            % this makes the SCI=1 at lag zero when x1=x2 AND makes the power estimate independent of signal length, amplitude and Fs
            similarity = length(window1)*similarity./sqrt(sum(abs(window1).^2)*sum(abs(window2).^2));
        else
            warning('Similarity results close to zero');
        end
        [pxx,f] = periodogram(similarity,hamming(length(similarity)),length(similarity),fs,'power');
        f3=figure(3);
        clf(f3);
        subplot(2,1,1);
        plot(f3.Children(1),lags,similarity);
        ylabel('Xcorr');
        subplot(2,1,2);
        plot(f3.Children(1),f,pxx);
        xline(f3.Children(1),fcut(1),'r--');
        xline(f3.Children(1),fcut(2),'r--');
        ylabel('Power');
        ylim([0 0.125]);
        yline(0.1,'--');
    end

    function sciThreshold(source, event)
        event.IntersectionPoint
        
    end


%% -------------------------------------------------------------------------
    function [qualityMats] = qualityCompute2(main_fig)
        raw = getappdata(main_fig,'rawDotNirs');
        nirsplot_param = getappdata(main_fig,'nirsplot_parameters');
        fcut = nirsplot_param.fcut;
        window = nirsplot_param.window;
        overlap = nirsplot_param.overlap;
        lambda_mask = nirsplot_param.lambda_mask;
        lambdas = nirsplot_param.lambdas;
        n_channels = nirsplot_param.n_channels;
        qltyThld = nirsplot_param.quality_threshold;
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
        overlap_samples = floor(window*fs*overlap);
        window_samples = floor(window*fs);
        n_windows = floor((size(raw.d,1)-overlap_samples)/(window_samples-overlap_samples));

        cardiac_windows = zeros(length(lambdas),window_samples,n_channels,n_windows);
        nirs_data = zeros(length(lambdas),window_samples,n_channels);
        cardiac_data = zeros(length(lambdas),window_samples,n_channels); % #Lambdas x #Windows x #Channels
        for lam = 1:length(lambdas)
            for j = 1:n_windows
                interval = (j-1)*window_samples-(j-1)*(overlap_samples)+1 : j*window_samples-(j-1)*(overlap_samples);
                idx = raw.SD.MeasList(:,4) == lambdas(lam);
                nirs_data(lam,:,:) = raw.d(interval,idx);
                filtered_nirs_data=filtfilt(B1,A1,squeeze(nirs_data(lam,:,:)));
                cardiac_data(lam,:,:)=filtered_nirs_data./repmat(std(filtered_nirs_data,0,1),size(filtered_nirs_data,1),1); % Normalized heartbeat
                cardiac_windows(lam,:,:,j) = cardiac_data(lam,:,:);
            end
        end
        overlap_samples = floor(window*fs*overlap);
        window_samples = floor(window*fs);
        n_windows = floor((size(raw.d,1)-overlap_samples)/(window_samples-overlap_samples));
        cardiac_data = cardiac_data(lambda_mask,:,:);
        sci_array = zeros(size(cardiac_data,3),n_windows);    % Number of optode is from the user's layout, not the machine
        power_array = zeros(size(cardiac_data,3),n_windows);
        parfor j = 1:n_windows
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
        
        % Summary analysis
        [woi] = getWOI(window_samples,n_windows,nirsplot_param);
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
        qualityMats.sci_array    = sci_array;
        qualityMats.power_array  = power_array;
        qualityMats.combo_array  = combo_array;
        qualityMats.combo_array_expanded = combo_array_expanded;
        qualityMats.bad_links    = bad_links;
        qualityMats.bad_windows  = bad_windows;
        qualityMats.sampPerWindow = window_samples;
        qualityMats.fs = fs;
        qualityMats.n_windows = n_windows;
        qualityMats.cardiac_data = cardiac_data;
        qualityMats.good_combo_link = good_combo_link;
        qualityMats.good_combo_window = good_combo_window;
        qualityMats.woi = woi;
        %
    end
end %end of nirsplot function definition