% snirfDownsample()
%
% A utility that let's you pick fNIRS files in a file dialog box that
% are then decimated to the specified frequency using a low pass filter as
% implemented by the matlab 'downsample' command.
%
% Note that original copies of the fNIRS files are not preserved. It is
% advised that you create a back up of your fNIRS files in case you want to
% recover the higher sample rate date.
% Modified from resample code
% Fixed the problem with edges
% Fixed the problem with s vector - Meryem Oct 2016
% Add code to allow non-integer downsampling factor - Meryem Oct 2018
% Code refined for Homer3 and fNIRS files

% Homer3 Note
% Downsample tool does not work for a flat file structure

function snirfDownsample()

global maingui;
if isempty(maingui)
    [files, pathnm] = uigetfile( '*.snirf', 'Pick the .snirf file', 'multiselect','on');
else
    fpath = [maingui.dataTree.currElem.path maingui.dataTree.currElem.name];
    [files, pathnm] = uigetfile( '*.snirf', 'Pick files to downsample', fpath, 'multiselect','on');
end

if ~iscell(files)
    if files==0
        return;
    end
end

[~,name,~] = fileparts(files); 

fsn = inputdlg( 'Decrease the sampling rate of a sequence by a factor of', 'Downsample SNIRF files', 1 );
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
%     varLst = whos();
    
%     fs = 1/(snirfData.data.time(2)-snirfData.data.time(1));
    
    if floor(fsn) == fsn % integer check
      
        snirfData.data.dataTimeSeries = downsample(snirfData.data.dataTimeSeries,fsn);
        if ~isempty(snirfData.aux)
            for iAux = 1:length(snirfData.aux)
                snirfData.aux(iAux).dataTimeSeries = downsample(snirfData.aux(iAux).dataTimeSeries,fsn);
                snirfData.aux(iAux).time = downsample(snirfData.aux(iAux).time,fsn);
            end
        end
        snirfData.data.time = downsample(snirfData.data.time,fsn);
%         s_sampled = zeros(size(snirfData.data.time,1),length(snirfData.aux));
%         for j=1:size(snirfData.stim,2)
%             lst_1 = snirfData.stim(j).data(:,3) == 1;
% %             lst_1 = round(lst_1/fsn);
%             s_sampled(lst_1,j) = 1;
%             lst_2 = snirfData.stim(j).data(:,3) == -1;
% %             lst_2 = round(lst_2/fsn);
%             s_sampled(lst_2,j) = -1;
%             snirfData.stim(j).data = s_sampled(:,j);
%         end
    else  % if downsample factor is not an integer (first upsample then downsample)
        t_new = linspace(1, size(snirfData.data.dataTimeSeries,1), 10*size(snirfData.data.dataTimeSeries,1));
        snirfData.data.dataTimeSeries = interp1(snirfData.data.dataTimeSeries, t_new);
        snirfData.data.dataTimeSeries = downsample(snirfData.data.dataTimeSeries,round(fsn*10));
        
        if ~isempty(snirfData.aux)
            for iAux = 1:length(snirfData.aux)
                snirfData.aux(iAux).dataTimeSeries = interp1(snirfData.aux(iAux).dataTimeSeries,t_new);
                snirfData.aux(iAux).dataTimeSeries = downsample(snirfData.aux(iAux).dataTimeSeries,round(fsn*10))';
                snirfData.aux(iAux).time = interp1(snirfData.aux(iAux).time,t_new);
                snirfData.aux(iAux).time = downsample(snirfData.aux(iAux).time,round(fsn*10))';
            end
        end
        
        snirfData.data.time = interp1(snirfData.data.time, t_new);
        snirfData.data.time = downsample(snirfData.data.time,round(fsn*10))';
        
%         s_sampled = zeros(size(snirfData.data.time,1),length(snirfData.aux));
%         for j=1:size(snirfData.stim,2)
%             lst_1 = snirfData.stim(j).data(:,3) == 1;
% %             lst_1 = round(lst_1/fsn);
%             s_sampled(lst_1,j) = 1;
%             lst_2 = snirfData.stim(j).data(:,3) == -1;
% %             lst_2 = round(lst_2/fsn);
%             s_sampled(lst_2,j) = -1;
%             snirfData.stim(j).data = s_sampled(:,j);
%         end
    
    end
    
    snirfName = sprintf([name '_downsample_' num2str(fsn) '.snirf']);
    snirfData.Save(snirfName);
    msgbox(['File created with name' snirfName]);
end

new_name = [files{1} '.orig'];
movefile (files{1}, new_name);
    
cd(wd);
