function demo_snirf()

% Syntax: 
%    demo_snirf() 
%
% Description:
%    Convert sample .nirs files included in the Homer3 project to SNIRF files (*.snirf) and 
%    compare the saved and loaded SnirfClass objects for each coberted file to make sure 
%    saving and loading of the .snirf is working correctly. 
%

% Find the Homer3 Examples folder and cd to it
[~, currdir] = findexamplesdir(); 

% Delete any previously generated .snirf files to make sure to start from scratch
DeleteSnirfFiles('standalone');

% Start with .nirs files
nirsfiles = mydir('./*.nirs');

fprintf('\n')

% Go through all the sample .nirs files
for ii=1:length(nirsfiles)
    
    % Convert sample .nirs file to SNIRF file (*.snirf) 
    [pname,fname,ext] = fileparts([nirsfiles(ii).pathfull, '/', nirsfiles(ii).filename]);    
    fprintf('Converting %s to %s\n', [pname,'/',fname,ext], [pname,'/',fname,'.snirf']);
    [snirf_saved, snirf_loaded, nirs] = snirf_load_save(nirsfiles(ii).name);
    
    % Compare the saved and loaded SnirfClass objects, using overloaded == operator 
    if snirf_saved == snirf_loaded
        fprintf('Saved and loaded SnirfClass objects for %s are equal\n', [fname,'.snirf']);
    else
        fprintf('ERROR: Saved and loaded SnirfClass objects for %s are NOT equal\n', [fname,'.snirf']);
    end
    fprintf('\n');
end

% Return to original folder
cd(currdir);

