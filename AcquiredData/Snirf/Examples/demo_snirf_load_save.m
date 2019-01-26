function [snirf_saved, snirf_loaded, nirs] = demo_snirf_load_save(infile, outfile)

% 
% Function:
%   
%   [snirf_saved, snirf_loaded, nirs] = demo_snirf_load_save(infile, outfile)
%  
% Description:
% 
%   Verify that the SnirfClass saver/loaded work correctly to convert .nirs data 
%   to snirf. Function loads .nirs data, converts to SnirfClass object, saves in 
%   HDF5 file and loads back into empty SnirfClass object. User can compare the 
%   saved and loaded SnirfClass objects to verify they're equivalent.
% 
% Usage examples:
%   
%   [snirf_saved, snirf_loaded] = demo_snirf_load_save();
%   [snirf_saved, snirf_loaded, nirs] = demo_snirf_load_save('./Simple_Probe1.nirs');
%   [snirf_saved, snirf_loaded, nirs] = demo_snirf_load_save('./FingerTapping_run3_tdmlproc.nirs');
%   [snirf_saved, snirf_loaded] = demo_snirf_load_save('./neuro_run01.nirs', './myfile.h5');
%
%

%%%%% Get the input and output file names 

% Input file
if ~exist('infile','var')
    fpath = which('neuro_run01.nirs');
    infile = fpath;
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


% Load .nirs, create Snirf class object, and save it in HDF5 file
fprintf('Saving %s to %s ...\n', [fname1, ext1], [fname2, ext2]);
nirs = load(infile,'-mat');
snirf_saved = SnirfClass(nirs.d, nirs.t, nirs.SD, nirs.aux, nirs.s);
tic
snirf_saved.Save(outfile);
toc

% Create empty Snirf class object and load SNIRF data from the saved HDF5
% file. 
fprintf('Loading %s ...\n', [fname2, ext2]); 
snirf_loaded = SnirfClass();
tic
snirf_loaded.Load(outfile);
toc

% Manually compare snirf_saved with snirf_loaded.
% TBD: write function to compare structs and classes for equality and
% report on the differences



