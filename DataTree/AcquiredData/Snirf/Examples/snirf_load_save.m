function [snirf_saved, snirf_loaded, nirs] = snirf_load_save(infile)

% 
% Syntax:
%   
%   [snirf_saved, snirf_loaded, nirs] = snirf_load_save(infile)
%  
% Description:
% 
%   Verify that the SnirfClass saver/loaded work correctly to convert .nirs data 
%   to snirf. Function loads .nirs data, converts to SnirfClass object, saves in 
%   HDF5 file and loads back into empty SnirfClass object. 
% 
% Usage examples:
%   
%   [snirf_saved, snirf_loaded, nirs] = snirf_load_save('./Simple_Probe1.nirs');
%   [snirf_saved, snirf_loaded, nirs] = snirf_load_save('./FingerTapping_run3_tdmlproc.nirs');
%

snirf_saved = [];
snirf_loaded = [];
nirs = [];

% Error check
if nargin == 0
    return;
end

% Get the input and output file names 
[pname, fname] = fileparts(infile);
outfile = [pname, fname, '.snirf'];

% Load .nirs, and convert it to SnirfClass object then save it in HDF5 file
nirs = load(infile,'-mat');
snirf_saved = SnirfClass(nirs);
fprintf('Saving %s ...\n', outfile);
tic; snirf_saved.Save(outfile); toc

% Create another SnirfClass object and load SNIRF data from the saved HDF5
% file. 
fprintf('Loading %s ...\n', outfile);
tic; snirf_loaded = SnirfClass(outfile); toc


