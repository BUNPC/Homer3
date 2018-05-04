%
% [files, filesErr, pathnm, listboxFiles, listboxFiles2] = GetNIRSDataSet(varargin)
%
% Find and return a set of valid .nirs files in the current or user-selected 
% directory and sets handles of listboxFiles and listboxFilesErr to the names 
% of valid and invalid .nirs files. 
% 
% If there are no .nirs files in the current directory, then this function 
% searches all the subdirectories for .nirs files and prepends the subdir 
% name to the name of the files entry.
% 
% This function can be run standalone on the matlab command line. To do
% this simply don't provide any arguments.
% 
%
% Input:
%
%    handles: 
%    pathnm: 
% 
% Examples:
%
%    files = GetNIRSDataSet(handles);
%    files = GetNIRSDataSet(1);
%
function [files, filesErr, pathnm, listboxFiles, listboxFiles2] = GetNIRSDataSet(varargin)


if nargin==0
    handles = [];
    pathnm = pwd;
elseif nargin==1
    if isstruct(varargin{1})
        handles = varargin{1};
        pathnm = pwd;
    elseif ischar(varargin{1})
        handles = [];
        pathnm = varargin{1};
    end
elseif nargin==2
    handles = varargin{1};
    pathnm = varargin{2};
end


if ~isempty(handles)
    hText     = handles.textStatus;
    hListbox1 = handles.listboxFiles;
    hListbox2 = handles.listboxFilesErr;
end

cd(pathnm);
currdir = pathnm;

% Init output parameters
% Get .nirs file names from current directory. If there are none
% check sub-directories.
files = findNIRSDataSet();
filesErr = struct([]);
pathnm = [];
listboxFiles = cell(length(files),1);
listboxFiles2 = cell(length(filesErr),1);

files0 = files;

% First get errors for .nirs files as individual files
[files filesErr] = getNIRSFileErrors(files);


% Now check the .nirs files data set as a whole. That is make 
% sure they all belong to the same group. This means only that the 
% SD geometries are compatible.
[loadData uniqueSD] = checkNIRSFormatAcrossFiles(files);
if ~loadData
    files = mydir('');
    filesErr = files0;
    if isempty( files )
        fprintf('No loadable .nirs files found. Choose another directory\n');

        % This pause is a workaround for a matlab bug in version 
        % 7.xx for Linux, where uigetfile/uigetdir won't block unless there's
        % a breakpoint. 
        pause(.5);       
        pathnm = uigetdir(currdir,'No loadable .nirs files found. Choose another directory' );
        if pathnm~=0
            [files filesErr pathnm listboxFiles listboxFiles2] = GetNIRSDataSet(handles,pathnm);
        end
    end
end


%%% Get listboxes names whether graphics exist or not

% Set listbox for valid .nirs files
listboxFiles = cell(length(files),1);
nFiles=0;
for ii=1:length(files)
    if files(ii).isdir
        listboxFiles{ii} = files(ii).name;
    elseif ~isempty(files(ii).subjdir)
        listboxFiles{ii} = ['    ', files(ii).filename];
        nFiles=nFiles+1;
    else
        listboxFiles{ii} = files(ii).name;
        nFiles=nFiles+1;
    end
end

% Set listbox for invalid .nirs files
listboxFiles2 = cell(length(filesErr),1);
nFilesErr=0;
for ii=1:length(filesErr)
    if filesErr(ii).isdir
        listboxFiles2{ii} = filesErr(ii).name;
    elseif ~isempty(filesErr(ii).subjdir)
        listboxFiles2{ii} = ['    ', filesErr(ii).filename];
        nFilesErr=nFilesErr+1;
    else
        listboxFiles2{ii} = filesErr(ii).name;
        nFilesErr=nFilesErr+1;
    end
end


% Check groupResults.mat file if it exists. 
% Standards for asking user about fixing errors in groupResults is lower
% because it's not original data. It's enough simply to move existing
% groupResults.mat to a safe filename 
if exist('./groupResults.mat','file')
    load( './groupResults.mat' );
    groupPrev = group;
    [group err] = getGroupErrors(group,'group');    
    if err
        q = menu('Error in groupResults.mat file...will fix and save original in groupResults.mat.orig', 'OK');
        if ~exist('./groupResults.mat.orig','file')
            movefile('./groupResults.mat','./groupResults.mat.orig');
        else
            q = menu('Save groupResults Options:', 'Ovewrite existing .orig file and save fixed', 'Just save fixed file', 'Do nothing');
            if q==1
                movefile('./groupResults.mat','./groupResults.mat.orig');
            end
        end
        if q ~= 3
            group = fixGroupErrors(group,'group');
            save( './groupResults.mat','group' );
        end
    end
end


% Set graphics objects: text and listboxes if handles exist
if ~isempty(handles)
    % Report status in the status text object 
    set( hText, 'string', ...
         {sprintf('%d files loaded successfully',nFiles),...
          sprintf('%d files failed to load',nFilesErr)} );

    if ~isempty(files)
        set(hListbox1,'value',1)
        set(hListbox1,'string',listboxFiles)
    end
       
    if ~isempty(filesErr)
        set(hListbox2,'visible','on');
        set(hListbox2,'value',1);
        set(hListbox2,'string',listboxFiles2)
    elseif isempty(filesErr)  && ishandle(hListbox2)
        set(hListbox2,'visible','off');
        pos1 = get(hListbox1, 'position');
        pos2 = get(hListbox2, 'position');
        set(hListbox1, 'position', [pos1(1) pos2(2) pos1(3) .98-pos2(2)]);
    end
end

