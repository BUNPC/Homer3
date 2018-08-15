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

%%%%% Get the input and output file names 

% Input file
if ~exist('infile','var')
    p = which('neuro_run01.nirs');
    infile = [p, '/neuro_run01.nirs'];
else
    p = fileparts(infile);
    if isempty(p)
        infile = [pwd, '/', infile];
    end
end
[~, fname1, ext1] = fileparts(infile);

% Output file
if ~exist('outfile','var')
    [~,f] = fileparts(infile);    
    outfile = [f, '.h5'];
else
    p = fileparts(outfile);
    if isempty(p)
        outfile = [pwd, '/', outfile];
    end
end
[~, fname2, ext2] = fileparts(outfile);


if exist(outfile,'file')
    delete(outfile);
end


fprintf('Saving %s to %s ...\n', [fname1, ext1], [fname2, ext2]);
nirs = load(infile,'-mat');
snirf_saved = SnirfClass(nirs.d, nirs.t, nirs.s, nirs.SD, nirs.aux);
tic
snirf_saved.Save(outfile);
toc

fprintf('Loading %s ...\n', [fname2, ext2]); 
snirf_loaded = SnirfClass();
tic
snirf_loaded.Load(outfile);
toc
