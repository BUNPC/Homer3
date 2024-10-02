function varargout = PlotProbe2(varargin)
% PLOTPROBE2 MATLAB code for PlotProbe2.fig
%      PLOTPROBE2, by itself, creates a new PLOTPROBE2 or raises the existing
%      singleton*.
%
%      H = PLOTPROBE2 returns the handle to a new PLOTPROBE2 or the handle to
%      the existing singleton*.
%
%      PLOTPROBE2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTPROBE2.M with the given input arguments.
%
%      PLOTPROBE2('Property','Value',...) creates a new PLOTPROBE2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotProbe2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotProbe2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlotProbe2

% Last Modified by GUIDE v2.5 09-May-2024 07:29:21

% Return if snirf object was not passed
if isempty(varargin)
    disp('Please pass snirf object as an argument');
    return
end 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotProbe2_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotProbe2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PlotProbe2 is made visible.
function PlotProbe2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotProbe2 (see VARARGIN)

% Choose default command line output for PlotProbe2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PlotProbe2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
if ischar(varargin{1})
    [fPath, fName, fExt] = fileparts(varargin{1});
    probePath = erase(fPath,'\derivatives\homer');
    snirffiles = dir([probePath '\*.snirf']);
    if ~isempty(snirffiles)
        snirfObj = SnirfClass([snirffiles(1).folder filesep snirffiles(1).name]);
        load(varargin{1});
        datasnirf = SnirfClass(output.dcAvg, [], [], []);
        snirfObj.data = datasnirf.data;
    else
        return
    end
else
    snirfObj = varargin{1};
end

% Update handles structure
guidata(hObject, handles);

dataTypeLabels = {};
dataTypeOrder = {};
measList = [];
wavelengths = GetWls(snirfObj.probe);
HbXList = {'None'};
dODList = {'None'};
for v = 1:length(snirfObj.data)
    for u = 1:length(snirfObj.data(v).measurementList)
        dataTypeLabel = GetDataTypeLabel(snirfObj.data(v).measurementList(u));
        
        % Make sure while saving snirf this is a string not cell array,
        % althogh its an issue but it should save consistantly but saves string
        % sometimes and as cell as sometimes
        if iscell(dataTypeLabel)
            dataTypeLabel = strcat((char(dataTypeLabel))');
%             snirfObj.data(v).measurementList(u) = dataTypeLabel;
        end
        
        if strcmp(dataTypeLabel,'dOD')
            wavelengthIndex = GetWavelengthIndex(snirfObj.data(v).measurementList(u));
            wavelength = wavelengths(wavelengthIndex);
            dataTypeLabel = [dataTypeLabel '_' num2str(wavelength)];
        end
        
        if ~any(strcmp(dataTypeLabels,dataTypeLabel))
            dataTypeLabels{end+1} = dataTypeLabel;
        end
        srcIdx = GetSourceIndex(snirfObj.data(v).measurementList(u));
        detIdx = GetDetectorIndex(snirfObj.data(v).measurementList(u));
        if isempty(measList)
            measList  = [srcIdx, detIdx];
        elseif sum(ismember(measList, [srcIdx, detIdx], 'rows')) == 0
            measList  = [measList;  [srcIdx, detIdx]];
        end

        if u == 1
            minAmp = min(snirfObj.data(v).dataTimeSeries(:,u));
            maxAmp = max(snirfObj.data(v).dataTimeSeries(:,u));
            snirfObj.data(v).dataTimeSeries(:,u) = snirfObj.data(v).dataTimeSeries(:,u) -(minAmp+ maxAmp)/2;
            minAmp = minAmp-(minAmp+ maxAmp)/2;
            maxAmp = maxAmp-(minAmp+ maxAmp)/2;
            if strcmp(dataTypeLabel,'HRF HbO') 
                dataTypeOrder{end+1} = 'HRF HbX';
            elseif contains(dataTypeLabel,'dOD')
                dataTypeOrder{end+1} = 'dOD';
            end
        else
            minAmp = min(minAmp,min(snirfObj.data(v).dataTimeSeries(:,u)));
            maxAmp = max(maxAmp,max(snirfObj.data(v).dataTimeSeries(:,u)));
            snirfObj.data(v).dataTimeSeries(:,u) = snirfObj.data(v).dataTimeSeries(:,u) -(minAmp+ maxAmp)/2;
            minAmp = minAmp-(minAmp+ maxAmp)/2;
            maxAmp = maxAmp-(minAmp+ maxAmp)/2;
        end
    end
    handles.data.minAmp(v) = minAmp;
    handles.data.maxAmp(v) = maxAmp;
end

for u = 1:length(dataTypeLabels)
   if contains(dataTypeLabels{u},'HRF') | contains(dataTypeLabels{u},'HbO') | contains(dataTypeLabels{u},'HbR') | contains(dataTypeLabels{u},'HbT')
       if ~any(strcmp(HbXList,dataTypeLabels{u}))
           HbXList{end+1} = dataTypeLabels{u};
       end
       set(handles.radiobutton_HbX, 'Enable', 'on');
       set(handles.listbox_selectActivity, 'Enable', 'on');
   end
   
   if contains(dataTypeLabels{u},'dOD') 
       if ~any(strcmp(dODList,dataTypeLabels{u}))
           dODList{end+1} = dataTypeLabels{u};
       end
       set(handles.radiobutton_dOD, 'Enable', 'on');
       set(handles.listbox_selectActivity, 'Enable', 'on');
   end
end

sPos = snirfObj.probe.sourcePos3D;
dPos = snirfObj.probe.detectorPos3D;
min_dist = 0;
max_dist = 0;
for v = 1:length(snirfObj.data)
    for u = 1:length(snirfObj.data(v).measurementList)
        srcIdx = GetSourceIndex(snirfObj.data(v).measurementList(u));
        detIdx = GetDetectorIndex(snirfObj.data(v).measurementList(u));
        channel_dist = sqrt(sum((sPos(srcIdx,:) - dPos(detIdx ,:)).^2));
        min_dist = min(min_dist, channel_dist);
        max_dist = max(max_dist, channel_dist);
    end
end
set(handles.edit_minDistForDisplay, 'String', min_dist);
set(handles.edit_maxDistForDisplay, 'String', max_dist);
defualtssFadeThres = 0;
set(handles.edit_ssFadeThres, 'String', num2str(defualtssFadeThres));

condition_names = {' All'};
for u = 1:length(snirfObj.stim)
    condition_names{u+1} = GetName(snirfObj.stim(u));
end
set(handles.listbox_selectConditions,'String',condition_names);

handles.data.snirfObj = snirfObj;
handles.data.measList = measList;
handles.data.HbXList = HbXList;
handles.data.dODList = dODList;
handles.data.dataTypeOrder = dataTypeOrder;

if isempty(snirfObj.probe.landmarkPos2D)
    set(handles.radiobutton_refPointsAsLabels,'Enable','Off');
    set(handles.radiobutton_refPointsAsCircles,'Enable','Off');
end

if ~isempty(HbXList)
    set(handles.radiobutton_HbX, 'Value', 1.0);
    set(handles.listbox_selectActivity,'String',HbXList);
end

if ~isempty(dODList) && isempty(HbXList)
    set(handles.radiobutton_dOD, 'Value', 1.0);
    set(handles.listbox_selectActivity,'String',dODList);
end

% % process data for displaying
% if ~isempty(snirfObj.data.dataTimeSeries)
%     nT = snirfObj.data.dataTimeSeries(:,1);
% else
%     nT = 0;
% end

% handles.data.display_activity = zeros(nT,length(dataTypeLabels),
display(handles);
guidata(hObject,handles)

function display(handles)

if isfield(handles, 'data') && isfield(handles.data, 'snirfObj')

    snirfObj = handles.data.snirfObj;
    measList = handles.data.measList;
    sPos = snirfObj.probe.sourcePos2D;
    dPos = snirfObj.probe.detectorPos2D;
    
    sourcePos3D = snirfObj.probe.sourcePos3D;
    detectorPos3D = snirfObj.probe.detectorPos3D;
    Distances=((sPos(measList(:,1),1) - dPos(measList(:,2),1)).^2 +...
           (sPos(measList(:,1),2) - dPos(measList(:,2),2)).^2 +...
           (sPos(measList(:,1),3) - dPos(measList(:,2),3)).^2).^0.5;
    
    sdMin = min([sPos;dPos]) - mean(Distances(:));
    sdMax = max([sPos;dPos]) + mean(Distances(:));

    sdWid = sdMax(1) - sdMin(1);
    sdHgt = sdMax(2) - sdMin(2);

    sd2axScl = max(sdWid,sdHgt);

    if isempty(snirfObj.probe.landmarkPos2D)
    sPos = sPos / sd2axScl;
    dPos = dPos / sd2axScl; 
    end
    
    nAcross=length(unique([sPos(:,1); dPos(:,1)]))+1;
    nUp=length(unique([sPos(:,2); dPos(:,2)]))+1;
    
%     nAcross=length(unique([sourcePos3D(:,1); sourcePos3D(:,1)]))+1;
%     nUp=length(unique([sourcePos3D(:,2); sourcePos3D(:,2)]))+1;
    
%     axFactor = [1,1];
    plot_Xscale = str2double(get(handles.edit_Xscale,'String'));
    plot_Yscale = str2double(get(handles.edit_Yscale,'String'));
    axWid = plot_Xscale * 1/nAcross;
    axHgt = plot_Yscale * 1/nUp;

    axXoff=mean([sPos(:,1);dPos(:,1)])-.5;
    axYoff=mean([sPos(:,2);dPos(:,2)])-.5;
    
    axes(handles.axes1);
    set(handles.axes1, 'xlim', [0,1], 'ylim', [0,1]);

    % Clear axes
    cla(handles.axes1); 
    axis off;
    % Plot the optodes on the axes
    if ismac() || islinux()
        fs = 14;
    else
        fs = 9;
    end  
    hold on

    for idx2=1:size(sPos,1)
        xa = sPos(idx2,1) - axXoff;
        ya = sPos(idx2,2) - axYoff;
        if get(handles.checkbox_optodesAsCircles,'Value')
            ht=plot(xa,ya,'.','markersize',10);
        else
            ht=text(xa,ya,sprintf('S%d',idx2));
            set(ht,'fontweight','bold','fontsize',fs)
        end
        set(ht,'color',[1 0 0])

    end
    for idx2=1:size(dPos,1)
        xa = dPos(idx2,1) - axXoff;
        ya = dPos(idx2,2) - axYoff;
        if get(handles.checkbox_optodesAsCircles,'Value')
            ht=plot(xa,ya,'.','markersize',10);
        else
            ht=text(xa,ya,sprintf('D%d',idx2));
            set(ht,'fontweight','bold','fontsize',fs)
        end
        set(ht,'color',[0 0 1])            
    end
    
    if ~isempty(snirfObj.probe.landmarkPos2D)
        if get(handles.radiobutton_refPointsAsLabels,'Value') || get(handles.radiobutton_refPointsAsCircles,'Value')
            refPos = snirfObj.probe.landmarkPos2D;
             if isempty(snirfObj.probe.landmarkPos2D)
            refPos = refPos / sd2axScl;
             end
            for idx2 =1:size(refPos,1)
                xa = refPos(idx2,1) - axXoff;
                ya = refPos(idx2,2) - axYoff;
                if get(handles.radiobutton_refPointsAsCircles,'Value')
                    ht=plot(xa,ya,'.','markersize',10);
                elseif get(handles.radiobutton_refPointsAsLabels,'Value')
                    ht=text(xa,ya,snirfObj.probe.landmarkLabels{idx2});
                    set(ht,'fontweight','bold','fontsize',6)
                end
                set(ht,'color',[0 0 0]) 
            end
        end
    end
    
    color=[1.00 0.00 0.00;
           0.00 0.00 1.00;
           0.00 1.00 0.00;
           1.00 0.00 1.00;
           0.00 1.00 1.00;
           0.50 0.80 0.30
              ];
          
    t = snirfObj.data(1).time;
    minT = min(t);
    maxT = max(t);
    EXPLODE_THRESH = 0.02;
    EXPLODE_VECTOR = [0.0, 0.0];
    xyas = [];
    minT = min(t);
    maxT = max(t);
    
    channel_min_dist = str2double(get(handles.edit_minDistForDisplay, 'String'));
    channel_max_dist = str2double(get(handles.edit_maxDistForDisplay, 'String'));
    ssFadeThres = str2double(get(handles.edit_ssFadeThres, 'String'));

%     contents = cellstr(get(handles.listbox_selectConditions,'String'));
    selected_conditions_index = get(handles.listbox_selectConditions,'Value');
    data_index = 0;
    selected_display_activities = {};
    
    if get(handles.radiobutton_HbX,'Value')
        selected_display_activities_index = get(handles.listbox_selectActivity,'Value');
        all_activities = get(handles.listbox_selectActivity,'String');
        selected_display_activities = all_activities(selected_display_activities_index);
        if ~contains(selected_display_activities,'None')
            data_index = find(contains(handles.data.dataTypeOrder,'HRF HbX'));
        end
    elseif get(handles.radiobutton_dOD,'Value')
        selected_display_activities_index = get(handles.listbox_selectActivity,'Value');
        all_activities = get(handles.listbox_selectActivity,'String');
        selected_display_activities = all_activities(selected_display_activities_index);
        if ~contains(selected_display_activities,'None')
            data_index = find(contains(handles.data.dataTypeOrder,'dOD'));
        end
    end
    if data_index~= 0
        for u = 1:length(snirfObj.data(data_index).measurementList)
            activityConditionIndex = GetCondition(snirfObj.data(data_index).measurementList(u));
            if any(selected_conditions_index == 1) || any(selected_conditions_index == activityConditionIndex+1)
                        
                % for HbO
                color_condition_1 = [0.862, 0.078, 0.235]; % Red for condition 1
                color_condition_2 = [1, 0, 1]; % Magenta for condition 2

                % for HbR
                color_condition_3 = [0, 0, 0.8]; % Blue for condition 1
                color_condition_4 = [0, 1, 1]; % Cyan for condition 2

                % for HbT
                color_condition_5 = [0.133, 0.545, 0.133]; % Dark green for condition 1
                color_condition_6 = [0.5, 1, 0]; % Light pastel green for condition 2

                % before selecting conditions, initialize the colors as:

                current_color_HbO = color_condition_1; 
                current_color_HbR = color_condition_3;
                current_color_HbT = color_condition_5;

                if ~~any(selected_conditions_index ==2, "all")
                    if any(selected_conditions_index == 2) && activityConditionIndex + 1 == 2
                        current_color_HbO = color_condition_1; % Red for condition 1
                        current_color_HbR = color_condition_3; % Blue for condition 2
                        current_color_HbT = color_condition_5; % for condition 3
                    elseif any(selected_conditions_index == 3) && activityConditionIndex + 1 == 3
                        current_color_HbO = color_condition_2; % Magenta for condition 2
                        current_color_HbR = color_condition_4; % Cyan for condition 2
                        current_color_HbT = color_condition_6; % for condition 2
                    end
                end
                        
                
                srcIdx = GetSourceIndex(snirfObj.data(data_index).measurementList(u));
                detIdx = GetDetectorIndex(snirfObj.data(data_index).measurementList(u));                  
                
                channel_dist = sqrt(sum((sourcePos3D(srcIdx,:) - detectorPos3D(detIdx ,:)).^2));

                lineWidth = 0.5;

                fade_factor = 0.7;
                
                if channel_dist >= 0 && channel_dist <= ssFadeThres
                    % Use a faded color or different line style for short separation
                     % Light gray color for faded effect
                     current_color_HbO = current_color_HbO + (1-current_color_HbO)*fade_factor;
                     current_color_HbR = current_color_HbR + (1-current_color_HbR)*fade_factor;
                     current_color_HbT = current_color_HbT + (1-current_color_HbT)*fade_factor;

                else

                end
                
                if channel_dist >= channel_min_dist & channel_dist <= channel_max_dist
                    xa = (sPos(srcIdx,1) + dPos(detIdx ,1))/2 - axXoff;
                    ya = (sPos(srcIdx,2) + dPos(detIdx ,2))/2 - axYoff;
                    
                    dataTypeLabel = GetDataTypeLabel(snirfObj.data(data_index).measurementList(u));
                    if iscell(dataTypeLabel)
                        dataTypeLabel = strcat((char(dataTypeLabel))');
                    end

                    % plot a line between source and detector
                    if get(handles.checkbox_displayMeasurementLine,'Value')
%                         if get(handles.checkbox_displayHbO, 'Value') || ...
%                                     get(handles.checkbox_displayHbR, 'Value') || ...
%                                     get(handles.checkbox_displayHbT, 'Value')
                            xPos = [sPos(srcIdx,1) dPos(detIdx,1)] - axXoff;
                            yPos = [sPos(srcIdx,2) dPos(detIdx,2)] - axYoff;
%                             plot(xPos ,yPos,'--','Color',[0.5 0.5 0.5])
                        if contains(dataTypeLabel,'HbO')
                            if ismember(u,SigCh)==0
                                plot(xPos ,yPos,'--','Color',[0.5 0.5 0.5])
                            elseif ismember(u,SigCh)==1
                                plot(xPos ,yPos,'-','Color','red')
                            end
                        end
%                         end
                    end
                    for i = 1:size(xyas, 1)
                       if sqrt((xyas(i, 1) - xa)^2 + (xyas(i, 2) - ya)^2) < EXPLODE_THRESH
                           xa = xa + EXPLODE_VECTOR(1);
                           ya = ya + EXPLODE_VECTOR(2);
                       end
                    end
                    xT = xa-axWid/4 + axWid*((t-minT)/(maxT-minT))/2;
                    xyas = [xyas; [xa, ya]];



                    Avg = snirfObj.data(data_index).dataTimeSeries(:,u);
            %         minAmp=squeeze(min(min(Avg)));
            %         maxAmp=squeeze(max(max(Avg)));
                    cmin = handles.data.minAmp(data_index);
                    cmax = handles.data.maxAmp(data_index);
            %         Avg = Avg-(cmin+cmax)/2;
                    AvgT = ya-axHgt/4 + axHgt*((Avg-cmin)/(cmax-cmin))/2;
            %         cmin = min(AvgT);
            %         cmax = max(AvgT);
            %          AvgT = AvgT-(cmin+cmax)/2;
                           
                    
                    
                    if any(contains(selected_display_activities,dataTypeLabel)) & contains(dataTypeLabel,'HbO')
                        plot(xT, AvgT, 'color', current_color_HbO, 'LineWidth', lineWidth);
                    elseif any(contains(selected_display_activities,dataTypeLabel)) & contains(dataTypeLabel,'HbR')
                        plot( xT, AvgT,'color', current_color_HbR,'LineWidth', lineWidth);
                    elseif any(contains(selected_display_activities,dataTypeLabel)) & contains(dataTypeLabel,'HbT')
                        plot( xT, AvgT,'color',current_color_HbT,'LineWidth', lineWidth);
                    elseif any(contains(selected_display_activities,dataTypeLabel))
                        plot( xT, AvgT,'color',color(4,:),'LineWidth', lineWidth);
                    end
                end
            end
        end
    end
    hold off
    %if get(handles.checkbox_axisImage,'Value')
        axis image
    %end
end




% --- Outputs from this function are returned to the command line.
function varargout = PlotProbe2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox_displayHbO.
function checkbox_displayHbO_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayHbO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayHbO
set(handles.checkbox_displayOD1,'Value',0)
set(handles.checkbox_displayOD2,'Value',0)
display(handles)


% --- Executes on button press in checkbox_displayHbR.
function checkbox_displayHbR_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayHbR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayHbR
set(handles.checkbox_displayOD1,'Value',0)
set(handles.checkbox_displayOD2,'Value',0)
display(handles)


% --- Executes on button press in checkbox_displayHbT.
function checkbox_displayHbT_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayHbT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayHbT
set(handles.checkbox_displayOD1,'Value',0)
set(handles.checkbox_displayOD2,'Value',0)
display(handles)


% --- Executes on button press in checkbox_displayOD1.
function checkbox_displayOD1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayOD1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayOD1
set(handles.checkbox_displayHbO,'Value',0)
set(handles.checkbox_displayHbR,'Value',0)
set(handles.checkbox_displayHbT,'Value',0)
display(handles)


% --- Executes on button press in checkbox_displayOD2.
function checkbox_displayOD2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayOD2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayOD2
set(handles.checkbox_displayHbO,'Value',0)
set(handles.checkbox_displayHbR,'Value',0)
set(handles.checkbox_displayHbT,'Value',0)
display(handles)


% --- Executes on button press in checkbox_displayOD3.
function checkbox_displayOD3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayOD3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayOD3


% --- Executes on button press in checkbox_displayOD4.
function checkbox_displayOD4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayOD4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayOD4



function edit_Xscale_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Xscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Xscale as text
%        str2double(get(hObject,'String')) returns contents of edit_Xscale as a double
axis image
display(handles)


% --- Executes during object creation, after setting all properties.
function edit_Xscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Xscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Yscale_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Yscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Yscale as text
%        str2double(get(hObject,'String')) returns contents of edit_Yscale as a double
axis image
display(handles)


% --- Executes during object creation, after setting all properties.
function edit_Yscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Yscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_XscaleDown.
function pushbutton_XscaleDown_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_XscaleDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Xscale = str2double(get(handles.edit_Xscale,'String'));
set(handles.edit_Xscale,'String',num2str(Xscale*0.5));
display(handles)


% --- Executes on button press in pushbutton_YscaleDown.
function pushbutton_YscaleDown_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_YscaleDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Yscale = str2double(get(handles.edit_Yscale,'String'));
set(handles.edit_Yscale,'String',num2str(Yscale*0.5));
display(handles)


% --- Executes on button press in pushbutton_XscaleUP.
function pushbutton_XscaleUP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_XscaleUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Xscale = str2double(get(handles.edit_Xscale,'String'));
set(handles.edit_Xscale,'String',num2str(Xscale*1.5));
display(handles)


% --- Executes on button press in pushbutton_YscaleUP.
function pushbutton_YscaleUP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_YscaleUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Yscale = str2double(get(handles.edit_Yscale,'String'));
set(handles.edit_Yscale,'String',num2str(Yscale*1.5));
display(handles)



function edit_minDistForDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to edit_minDistForDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_minDistForDisplay as text
%        str2double(get(hObject,'String')) returns contents of edit_minDistForDisplay as a double

display(handles)


% --- Executes during object creation, after setting all properties.
function edit_minDistForDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_minDistForDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_maxDistForDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to edit_maxDistForDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_maxDistForDisplay as text
%        str2double(get(hObject,'String')) returns contents of edit_maxDistForDisplay as a double

display(handles)


% --- Executes during object creation, after setting all properties.
function edit_maxDistForDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_maxDistForDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_optodesAsCircles.
function checkbox_optodesAsCircles_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_optodesAsCircles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_optodesAsCircles

display(handles)


% --- Executes on button press in radiobutton_refPointsAsLabels.
function radiobutton_refPointsAsLabels_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_refPointsAsLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_refPointsAsLabels

if get(handles.radiobutton_refPointsAsLabels,'Value')
    set(handles.radiobutton_refPointsAsCircles,'Value',0);
end

display(handles)


% --- Executes on button press in radiobutton_refPointsAsCircles.
function radiobutton_refPointsAsCircles_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_refPointsAsCircles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.radiobutton_refPointsAsCircles,'Value')
    set(handles.radiobutton_refPointsAsLabels,'Value',0);
end

display(handles)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_refPointsAsCircles


% --- Executes on button press in checkbox_displayMeasurementLine.
function checkbox_displayMeasurementLine_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayMeasurementLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayMeasurementLine

display(handles)

% --- Executes on selection change in popupmenu_selectConditions.
function popupmenu_selectConditions_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_selectConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_selectConditions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_selectConditions


% --- Executes during object creation, after setting all properties.
function popupmenu_selectConditions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_selectConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_selectConditions.
function listbox_selectConditions_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_selectConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_selectConditions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_selectConditions
display(handles)

% --- Executes during object creation, after setting all properties.
function listbox_selectConditions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_selectConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_axisImage.
function checkbox_axisImage_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_axisImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_axisImage
display(handles)


% --- Executes on button press in radiobutton_HbX.
function radiobutton_HbX_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_HbX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_HbX

if strcmp(get(handles.radiobutton_dOD,'Enable'),'on')
    set(handles.radiobutton_dOD,'Value',0);
    set(handles.listbox_selectActivity,'Value',1);
    set(handles.listbox_selectActivity,'String',handles.data.HbXList);
end


% --- Executes on button press in radiobutton_dOD.
function radiobutton_dOD_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_dOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_dOD

if strcmp(get(handles.radiobutton_HbX,'Enable'),'on')
    set(handles.radiobutton_HbX,'Value',0);
    set(handles.listbox_selectActivity,'Value',1);
    set(handles.listbox_selectActivity,'String',handles.data.dODList);
end


% --- Executes on selection change in listbox_selectActivity.
function listbox_selectActivity_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_selectActivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_selectActivity contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_selectActivity

display(handles)

% --- Executes during object creation, after setting all properties.
function listbox_selectActivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_selectActivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ssFadeThres_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ssFadeThres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ssFadeThres as text
%        str2double(get(hObject,'String')) returns contents of edit_ssFadeThres as a double
display(handles)


% --- Executes during object creation, after setting all properties.
function edit_ssFadeThres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ssFadeThres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


