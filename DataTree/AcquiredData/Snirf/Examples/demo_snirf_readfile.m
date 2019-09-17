function demo_snirf_readfile(fname)

% Syntax: 
%    demo_snirf_readfile() 
%
% Description:
%    Demo of how to read individual SNIRF fields using SnirfClass methods.
%  
% Examples:
%    demo_snirf_readfile();
%    demo_snirf_readfile('Simple_Probe.snirf');
%    demo_snirf_readfile('FingerTapping_run3_tdmlproc.snirf');
%    demo_snirf_readfile('neuro_run01.snirf');
%

if nargin==0
    fname = 'neuro_run01.snirf';
end
[rootdirexamples, currdir] = findexamplesdir(); 
fnamefullpath = findfile(rootdirexamples, fname, currdir);


%%%%% This is the actual demo showing how to read a .snirf file on the command line

% Create empty snirf object
snirf = SnirfClass();

% Read meta data tags from file
fprintf('Read metaDataTags from %s.\n', fnamefullpath);
snirf.LoadMetaDataTags(fnamefullpath,'/nirs');      % Use the SnirfClass LoadYYYY method to load whichever field you want 
for ii=1:length(snirf.metaDataTags)
    fprintf('metaDataTag(%d): {key = ''%s'', value = ''%s''}\n', ii, snirf.metaDataTags(ii).key, snirf.metaDataTags(ii).value);
end
fprintf('\n');

% Read meta stims from file
fprintf('Read stim data from %s.\n', fnamefullpath);
snirf.LoadStim(fnamefullpath,'/nirs');      % Use the SnirfClass LoadYYYY method to load whichever field you want
for ii=1:length(snirf.stim)
    fprintf('stim(%d): {name = ''%s'', data = [', ii, snirf.stim(ii).name);
    for jj=1:size(snirf.stim(ii).data,1)
        if jj==size(snirf.stim(ii).data,1)
            fprintf('%0.1f', snirf.stim(ii).data(jj,1));
        else
            fprintf('%0.1f, ', snirf.stim(ii).data(jj,1));
        end
    end
    fprintf(']}\n');    
end
fprintf('\n');


%%%%% Return to original folder
cd(currdir);

