function setpaths_proprietary(inp1)
ns = getNamespace();
if isempty(ns)
    return;
end
if strcmp(ns, 'AtlasViewerGUI')
    if nargin == 0
        setpaths_proprietary_AtlasViewerGUI();
    elseif nargin == 1
        setpaths_proprietary_AtlasViewerGUI(inp1);
    end
elseif strcmp(ns, 'Homer3')
    if nargin == 0
        setpaths_proprietary_Homer3();
    elseif nargin == 1
        setpaths_proprietary_Homer3(inp1);
    end
end


% ---------------------------------------------------------
function setpaths_proprietary_AtlasViewerGUI(~)
genMultWlFluenceFiles_CurrWorkspace;

r = checkToolboxes('AtlasViewer');

fprintf('\n');
if all(r==1)
    fprintf('All required toolboxes are installed.\n');
elseif ismember(3, r)
    fprintf('Unable to verify if all required toolboxes are installed ...\n');
elseif ismember(4, r)
    fprintf('Unable to verify if all required toolboxes are installed with older Matlab release...\n');
else
    fprintf('Some required toolboxes are missing...\n');
end

pause(2);

fullpathappl = fileparts(which('AtlasViewerGUI.m'));

msg{1} = sprintf('For instructions to perform basic test of AtlasViewerGUI, open the PDF file %s', ...
                 [fullpathappl, '/Test/Testing_procedure.pdf']);
fprintf('\n\n*** %s ***\n\n', [msg{:}]);





% ---------------------------------------------------------
function setpaths_proprietary_Homer3(~)

r = checkToolboxes('Homer3');

fprintf('\n');
if all(r==1)
    fprintf('All required toolboxes are installed.\n');
elseif ismember(3, r)
    fprintf('Unable to verify if all required toolboxes are installed ...\n');
elseif ismember(4, r)
    fprintf('Unable to verify if all required toolboxes are installed with older Matlab release...\n');
else
    fprintf('Some required toolboxes are missing...\n');
end

pause(2);
% Check if wavelet data db2.mat is available in toolbox.
% If no then create it from known data
fullpathhomer3 = fileparts(which('Homer3.m'));
if fullpathhomer3(end)~='/' & fullpathhomer3(end)~='\'
    fullpathhomer3(end+1)='/';
end
findWaveletDb2([fullpathhomer3, 'Install/']);

