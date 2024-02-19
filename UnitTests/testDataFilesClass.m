function [files0, files1, files2] = testDataFilesClass(options)
% Syntax:
%       [files0, files1, files2] = testDataFilesClass()
%       [files0, files1, files2] = testDataFilesClass(options)
%
% Examples:
%       [files0, files1, files2] = testDataFilesClass()
%       [files0, files1, files2] = testDataFilesClass('create')
%       [files0, files1, files2] = testDataFilesClass('create:remove')
%
%
if ~exist('options','var')
    options = '';
end
datasetDir = './group1';

if includes(options,'create')
    if ~exist(datasetDir,'dir')
        fprintf('mkdir(''%s'');\n', datasetDir)
        mkdir(datasetDir);
    end
    fprintf('cd(''%s'');\n', datasetDir)
    cd(datasetDir)
end
dirs = dir('sub-*');
if isempty(dirs)
    fprintf('generateSimDataset(pwd, 5, 3, 4);\n')
    if isempty(which('AtlasViewerGUI'))
        MenuBox('ERROR:   AtlasViewer has not been installed. You must add AtlasViewer to Matlab search paths to generate simulated dataset with generateSimDataset.m')
        return
    end
    generateSimDataset(pwd, 5, 3, 4);
end
fprintf('\n')
pause(2)


if exist('./derivatives','dir')
    fprintf('rmdir(''./derivatives'',''s'')\n');
    rmdir('./derivatives','s')
end
fprintf('tic; files0 = DataFilesClass(pwd, ''snirf''); toc;\n');
tic; files0 = DataFilesClass(pwd, 'snirf'); toc %#ok<*NASGU>
fprintf('\n')
pause(2)

% Update files
filesUpdated = {
    './sub-02/ses-01/sub-02_ses-01_run02.snirf';
    './sub-02/ses-03/sub-02_ses-03_run01.snirf';
    './sub-03/ses-02/sub-03_ses-02_run02.snirf';
    './sub-03/ses-02/sub-03_ses-02_run04.snirf';
    './sub-05/ses-01/sub-05_ses-01_run04.snirf';
    };
s = repmat(SnirfClass(),1,length(filesUpdated));
for ii = 1:length(filesUpdated)
    fprintf('Update file %s\n', filesUpdated{ii})
    s(ii) = SnirfClass(filesUpdated{ii});
    s(ii).Save();
end
fprintf('\n')
pause(2)


% Added files
filesAdded = {
    './sub-01/ses-02/sub-01_ses-02_run10.snirf';
    './sub-03/ses-02/sub-04_ses-02_run14.snirf';
    './sub-04/ses-02/sub-04_ses-02_run11.snirf';
    './sub-04/ses-03/sub-04_ses-03_run12.snirf';
    };
for ii = 1:length(filesAdded)
    fprintf('Added file %s\n', filesAdded{ii})
    s = SnirfClass('./sub-01/ses-01/sub-01_ses-01_run01.snirf');
    s.Save(filesAdded{ii});
end
fprintf('\n')
pause(2)


% Deleted files
filesDeleted = {
    './sub-02/ses-03/sub-02_ses-03_run02.snirf';
    './sub-04/ses-02/sub-04_ses-02_run01.snirf';
    './sub-05/ses-02/sub-05_ses-02_run03.snirf';
    };
for ii = 1:length(filesDeleted)
    fprintf('Delete file %s\n', filesDeleted{ii})
    delete(filesDeleted{ii})
end
fprintf('\n')
pause(2)



% Error files
filesError = {
    './sub-01/ses-01/sub-02_ses-01_run02.snirf';
    './sub-04/ses-03/sub-02_ses-03_run01.snirf';
    './sub-05/ses-02/sub-03_ses-02_run02.snirf';
    './sub-05/ses-02/sub-03_ses-02_run04.snirf';
    };
s = repmat(SnirfClass(),1,length(filesError));
for ii = 1:length(filesError)
    fprintf('Generate error file %s\n', filesError{ii})
    s(ii) = SnirfClass(filesError{ii});
    s(ii).data.dataTimeSeries(:,1) = [];
    s(ii).Save();
end
fprintf('\n')
pause(2)



fprintf('tic; files1 = DataFilesClass(pwd, ''snirf''); toc;\n');
tic; files1 = DataFilesClass(pwd, 'snirf'); toc
fprintf('\n')
pause(2)

fprintf('tic; files2 = DataFilesClass(pwd, ''snirf''); toc;\n');
tic; files2 = DataFilesClass(pwd, 'snirf'); toc
fprintf('\n')
pause(2)

if includes(options,'remove')
    fprintf('cd(''..'');\n')
    cd('..')
    fprintf('rmdir(''%s'',''s'');\n', datasetDir)
    rmdir(datasetDir,'s')
    fprintf('\n')
end


