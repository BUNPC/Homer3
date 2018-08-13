function [snirf, snirf2] = demo_snirf_load_save(nirsfile)

% 
% Function:
%   
%  [snirf, snirf2] = demo_snirf_load_save(nirsfile)
%  
% Usage examples:
%   
%  [snirf, snirf2] = demo_snirf_load_save();
%
%  [snirf, snirf2] = demo_snirf_load_save('./Simple_Probe1.nirs');
%
%  [snirf, snirf2] = demo_snirf_load_save('./neuro_run01.nirs');
%
%


if ~exist('nirsfile','var')
    nirsfile = './neuro_run01.nirs';
end

if exist('myfile.h5','file')
    delete('myfile.h5');
end

nirs = load(nirsfile,'-mat');
snirf = SNIRFClass(nirs.d, nirs.t, nirs.s, nirs.SD, nirs.aux);
snirf.Save('myfile.h5')

snirf2 = SNIRFClass();
snirf2.Load('myfile.h5');

