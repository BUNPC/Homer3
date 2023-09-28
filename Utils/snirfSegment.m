function snirfSegment()
% Description: This function divides the nirs data into segments predefined by
% user input. User should input the time period of the segments of the nirs
% data as eg [0 200; 400:900; 950:1000] in *sec*
% Meryem A Yucel, Nov 2016
%%%%%%%%%%%%%%%
% Code refined for Homer3 and fNIRS files

% Homer3 Note
% Segment tool does not work for a flat file structure

global maingui;
if isempty(maingui)
    [files, pathnm] = uigetfile( '*.snirf', 'Pick the .snirf file', 'multiselect','on');
else
    fpath = [maingui.dataTree.currElem.path maingui.dataTree.currElem.name];
    [files, pathnm] = uigetfile( '*.snirf', 'Pick the .snirf file', fpath, 'multiselect','on');
end

if files==0
    return
end

if ~iscell(files)
    if files==0
        return;
    end
end

[~,name,~] = fileparts(files);

fsn = inputdlg( 'Select the time range (in seconds) for the segment of data to save in a separate file. You can enter multiple time ranges, separated by a '';'', to save different segments to different files. For example, [0 100; 300 400] would give you two segments of the original file from 0 to 100 and 300 to 400', 'Segment SNIRF file', 1 );
if isempty(fsn)
    return
end
fsn = str2num(fsn{1});

wd = cd;
cd(pathnm)

if ~iscell(files)
    foo{1} = files;
    files = foo;
end

for iFile = 1:length(files)
    snirfData = SnirfClass(files{iFile});
    fs = 1/(snirfData.data.time(2) - snirfData.data.time(1));
    maxT = max(snirfData.data.time);
    
    if fsn(1,1) == 0 % if time starts from 0, take the first data sample!
        fsn(1,1) = 1/fs;
    end
    
    
    for P = 1:size(fsn,1) % loop over different parts
        snirfData = SnirfClass(files{iFile});
        if fsn(P,1)> maxT || fsn(P,2) > maxT
            errordlg('Time period (in sec) exceeds the maximum time. Please re-try.','Retry');
            return
        elseif fsn(P,1) < 0 || fsn(P,2) < 0
            errordlg('Time period (in sec) should consist of positive numbers. Please re-try.','Retry');
            return
        end
        
        snirfData.data.dataTimeSeries = snirfData.data.dataTimeSeries(round(fsn(P,1)*fs):round(fsn(P,2)*fs),:);
        snirfData.data.time = snirfData.data.time(round(fsn(P,1)*fs):round(fsn(P,2)*fs));
        for iStim = 1:length(snirfData.stim)
            if ~isempty(snirfData.stim(iStim).data)
                snirfData.stim(iStim).data = snirfData.stim(iStim).data(snirfData.stim(iStim).data(:,1)>fsn(P,1) & snirfData.stim(iStim).data(:,1)<fsn(P,2),:);
            end
        end
        for iAux = 1:length(snirfData.aux)
            snirfData.aux(iAux).dataTimeSeries = snirfData.aux(iAux).dataTimeSeries(round(fsn(P,1)*fs):round(fsn(P,2)*fs));
            snirfData.aux(iAux).time = snirfData.aux(iAux).time(round(fsn(P,1)*fs):round(fsn(P,2)*fs));
        end
        
        snirfName = sprintf([name '_seg_' num2str(P) '.snirf']);
        snirfData.Save(snirfName);
        msgbox(['File created with name' snirfName], 'Notification');
    end
end

new_name = [files{1} '.orig'];
movefile (files{1}, new_name);
% if isempty(maingui)
%     %Nothing
% else
%     for iFile = 1:length(files)
%
%         maingui.dataTree.
%     end
% end

cd(wd);
