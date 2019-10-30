function GenerateSNIRFReaderWriter()

dirnameApp = [getAppDir(), 'DataTree/AcquiredData/'];
dirnameUtils = [getAppDir(), 'Utils/'];
dirnameInstall = fileparts(which('GenerateSNIRFReaderWriter.m'));
dirnameInstall(dirnameInstall=='\') = '/';
dirnameInstall(end+1)='/';

if exist([dirnameInstall, '/SNIRF_ReaderWriter'], 'dir')
    rmdir([dirnameInstall, '/SNIRF_ReaderWriter'], 's');
end
mkdir([dirnameInstall, '/SNIRF_ReaderWriter']);
mkdir([dirnameInstall, '/SNIRF_ReaderWriter/Utils']);

copyFiles([dirnameApp, 'DataFiles'],           [dirnameInstall, 'SNIRF_ReaderWriter/DataFiles']);
copyFiles([dirnameApp, 'Nirs'],                [dirnameInstall, 'SNIRF_ReaderWriter/Nirs']);
copyFiles([dirnameApp, 'Snirf'],               [dirnameInstall, 'SNIRF_ReaderWriter/Snirf']);
copyFiles([dirnameUtils, 'isproperty.m'],      [dirnameInstall, 'SNIRF_ReaderWriter/Utils']);
copyFiles([dirnameUtils, 'iswholenum.m'],      [dirnameInstall, 'SNIRF_ReaderWriter/Utils']);
copyFiles([dirnameUtils, 'propnames.m'],       [dirnameInstall, 'SNIRF_ReaderWriter/Utils']);
copyFiles([dirnameUtils, 'CopyHandles.m'],     [dirnameInstall, 'SNIRF_ReaderWriter/Utils']);
copyFiles([dirnameUtils, 'strtrim_improve.m'], [dirnameInstall, 'SNIRF_ReaderWriter/Utils']);
copyFiles([dirnameUtils, 'fullpath.m'],        [dirnameInstall, 'SNIRF_ReaderWriter']);
copyFiles([dirnameUtils, 'setpaths.m'],        [dirnameInstall, 'SNIRF_ReaderWriter']);
copyFiles([dirnameApp, 'AcqDataClass.m'],      [dirnameInstall, 'SNIRF_ReaderWriter']);
copyFiles([dirnameApp, 'README.md'],           [dirnameInstall, 'SNIRF_ReaderWriter']);
copyFiles([getAppDir(), 'cd_safe.m'],          [dirnameInstall, 'SNIRF_ReaderWriter']);



% -------------------------------------------------------------------
function copyFiles(src, dst, type)

if ~exist('type', 'var')
    type = 'file';
end
if ~exist('errtype', 'var')
    errtype = 'Error';
end

try
    % If src is one of several possible filenames, then src to any one of
    % the existing files.
    if iscell(src)
        for ii=1:length(src)
            if ~isempty(dir(src{ii}))
                src = src{ii};
                break;
            end
        end
    end
    
    assert(logical(exist(src, type)));
    
    % Check if we need to untar the file 
    k = findstr(src,'.tar.gz');
    if ~isempty(k)
        untar(src,fileparts(src));
        src = src(1:k-1);
    end
    
    % Copy file from source to destination folder
    fprintf('Copying %s to %s\n', src, dst);
    copyfile(src, dst);

catch ME

    printStack();
    if iscell(src)
        src = src{1};
    end
    MenuBox(sprintf('Error: Could not copy %s to installation folder.', src), {'OK'});
    pause(5);
    rethrow(ME);
    
end

