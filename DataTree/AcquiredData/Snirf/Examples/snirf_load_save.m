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
pname = filesepStandard(pname);
outfile = [pname, fname, '.snirf'];

% Load .nirs file
nirs = load(infile,'-mat');

% Save SNIRF: Convert .nirs format data to SnirfClass object, save it to .snirf file (HDF5)
fprintf('Saving %s ...\n', outfile);
snirf_saved = SnirfClass(nirs);
tic; snirf_saved.Save(outfile); toc

% Load SNIRF: Create another SnirfClass object, load SNIRF data from the .snirf file (HDF5)
fprintf('Loading %s ...\n', outfile);
tic; snirf_loaded = SnirfClass(outfile); toc

% NOTE: the SnirfClass constructor uses the Load() method which complements the Save() 
% method. If one wanted to be consistent with the Save operation above you could do  
% the loading this way:
%   
%   fprintf('Loading %s ...\n', outfile);
%   snirf_loaded = SnirfClass();
%   tic; snirf_loaded.Load(outfile); toc
%
% However in the actual code that loads .snirf files, it is much clearer and more concise 
% to use the constructor the way it's done in this function. 
%
