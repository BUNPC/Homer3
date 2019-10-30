function GenerateSNIRFReaderWriter()

dirnameApp = [getAppDir(), 'DataTree/AcquiredData/'];
dirnameUtils = [getAppDir(), 'Utils/'];
dirnameInstall = fileparts(which('GenerateSNIRFReaderWriter.m'));
dirnameInstall(dirnameInstall=='\') = '/';
dirnameInstall(end+1)='/';

if exist([dirnameInstall, '/SNIRFReaderWriter'], 'dir')
    rmdir([dirnameInstall, '/SNIRFReaderWriter'], 's');
end
mkdir([dirnameInstall, '/SNIRFReaderWriter']);
mkdir([dirnameInstall, '/SNIRFReaderWriter/Utils']);

copyFiles([dirnameApp, 'DataFiles'],           [dirnameInstall, 'SNIRFReaderWriter/DataFiles']);
copyFiles([dirnameApp, 'Nirs'],                [dirnameInstall, 'SNIRFReaderWriter/Nirs']);
copyFiles([dirnameApp, 'Snirf'],               [dirnameInstall, 'SNIRFReaderWriter/Snirf']);
copyFiles([dirnameUtils, 'isproperty.m'],      [dirnameInstall, 'SNIRFReaderWriter/Utils']);
copyFiles([dirnameUtils, 'iswholenum.m'],      [dirnameInstall, 'SNIRFReaderWriter/Utils']);
copyFiles([dirnameUtils, 'propnames.m'],       [dirnameInstall, 'SNIRFReaderWriter/Utils']);
copyFiles([dirnameUtils, 'CopyHandles.m'],     [dirnameInstall, 'SNIRFReaderWriter/Utils']);
copyFiles([dirnameUtils, 'strtrim_improve.m'], [dirnameInstall, 'SNIRFReaderWriter/Utils']);
copyFiles([dirnameApp, 'AcqDataClass.m'],      [dirnameInstall, 'SNIRFReaderWriter']);
copyFiles([getAppDir(), 'cd_safe.m'],          [dirnameInstall, 'SNIRFReaderWriter']);
copyFiles([dirnameUtils, 'fullpath.m'],        [dirnameInstall, 'SNIRFReaderWriter']);
copyFiles([dirnameApp, 'setpaths.m'],          [dirnameInstall, 'SNIRFReaderWriter']);
copyFiles([dirnameApp, 'README.md'],           [dirnameInstall, 'SNIRFReaderWriter']);



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

