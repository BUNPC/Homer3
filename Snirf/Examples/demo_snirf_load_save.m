function [snirf_saved, snirf_loaded] = demo_snirf_load_save(infile, outfile)

% 
% Function:
%   
%  [snirf_saved, snirf_loaded] = demo_snirf_load_save(infile, outfile)
%  
% Usage examples:
%   
%  [snirf_saved, snirf_loaded] = demo_snirf_load_save();
%  [snirf_saved, snirf_loaded] = demo_snirf_load_save('./Simple_Probe1.nirs');
%  [snirf_saved, snirf_loaded] = demo_snirf_load_save('./neuro_run01.nirs', 'myfile.h5');
%
%


if ~exist('infile','var')
    infile = './neuro_run01.nirs';
end
if ~exist('outfile','var')
    outfile = './myfile.h5';
end

if exist(outfile,'file')
    delete(outfile);
end

fprintf('Saving ...\n'); pause(4);
nirs = load(infile,'-mat');
snirf_saved = SnirfClass(nirs.d, nirs.t, nirs.s, nirs.SD, nirs.aux);
snirf_saved.Save(outfile);

fprintf('\n');

fprintf('Loading ...\n'); pause(4);
snirf_loaded = SnirfClass();
snirf_loaded.Load(outfile);

