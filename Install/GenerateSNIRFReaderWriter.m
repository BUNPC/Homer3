function GenerateSNIRFReaderWriter()

dirnameApp = [getAppDir(), 'DataTree/AcquiredData/'];
dirnameUtils = [getAppDir(), 'Utils/'];
dirnameInstall = fileparts(which('GenerateSNIRFReaderWriter.m'));
dirnameInstall(dirnameInstall=='\') = '/';
dirnameInstall(end+1)='/';

if exist([dirnameInstall, '/snirf_homer3'], 'dir')
    rmdir([dirnameInstall, '/snirf_homer3'], 's');
end
mkdir([dirnameInstall, '/snirf_homer3']);
mkdir([dirnameInstall, '/snirf_homer3/Utils']);

copyFiles([dirnameApp, 'DataFiles'],           [dirnameInstall, 'snirf_homer3/DataFiles']);
copyFiles([dirnameApp, 'Nirs'],                [dirnameInstall, 'snirf_homer3/Nirs']);
copyFiles([dirnameApp, 'Snirf'],               [dirnameInstall, 'snirf_homer3/Snirf']);
copyFiles([dirnameUtils, 'pretty_print_struct.m'], [dirnameInstall, 'snirf_homer3']);
copyFiles([dirnameUtils, 'isproperty.m'],      [dirnameInstall, 'snirf_homer3/Utils']);
copyFiles([dirnameUtils, 'iswholenum.m'],      [dirnameInstall, 'snirf_homer3/Utils']);
copyFiles([dirnameUtils, 'propnames.m'],       [dirnameInstall, 'snirf_homer3/Utils']);
copyFiles([dirnameUtils, 'CopyHandles.m'],     [dirnameInstall, 'snirf_homer3/Utils']);
copyFiles([dirnameUtils, 'strtrim_improve.m'], [dirnameInstall, 'snirf_homer3/Utils']);
copyFiles([dirnameUtils, 'fullpath.m'],        [dirnameInstall, 'snirf_homer3']);
copyFiles([dirnameUtils, 'setpaths.m'],        [dirnameInstall, 'snirf_homer3']);
copyFiles([dirnameUtils, 'convertToStandardPath.m'], [dirnameInstall, 'snirf_homer3/Utils']);
copyFiles([dirnameUtils, 'cell2str_new.m'], [dirnameInstall, 'snirf_homer3/Utils']);
copyFiles([dirnameApp, 'AcqDataClass.m'],      [dirnameInstall, 'snirf_homer3']);
copyFiles([dirnameApp, 'README.md'],           [dirnameInstall, 'snirf_homer3']);
copyFiles([getAppDir(), 'cd_safe.m'],          [dirnameInstall, 'snirf_homer3']);
copyFiles([getAppDir(), 'str2cell.m'],          [dirnameInstall, 'snirf_homer3/Utils']);



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

