function [y, t] = Raw_to_HRF_Example(filename, hbType, channels)
%
%    Example 1:   Plot channel 1 HbO HRF, derived from acquisition 
%                 file test.snirf
%
%       cd '<root folder>\Homer3\UnitTests\Example_RunFuncOffline'
%       Raw_to_HRF_Example('./test.snirf');
%    
%    Example 2:   Plot channels 1 and 2 HbT HRF, derived from acquisition file test.snirf
%                 
%       cd '<root folder>\Homer3\UnitTests\Example_RunFuncOffline'
%       Raw_to_HRF_Example('./test.snirf', 3, [1,2]);
%    
%    Example 3:   Plot channel 2 HbO and HbR HRF, derived from acquisition
%                 file test.snirf
%
%       cd '<root folder>\Homer3\UnitTests\Example_RunFuncOffline'
%       Raw_to_HRF_Example('./test.snirf', [1,2], 2);
%    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse args 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Arg 1
[pname, fname] = fileparts(filename);
if isempty(pname)
    pname = pwd;
end

% Arg 2:  Hb type - {1 -> HbO,  2 -> HbR,  3 -> HbT}
if ~exist('hbType','var') || isempty(hbType)
    hbType   = 1;
end

% Arg 3: 
if ~exist('channels','var') || isempty(channels)
    channels = 1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load acquisition file 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Acquired data (See SNIRF spec for list of acquired data parameters) 
acquired = SnirfClass([pname, '/', fname, '.snirf']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% String together user functions to get from acquired data 
% to HRF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dod   = hmrR_Intensity2OD(acquired.data); 
dod   = hmrR_BandpassFilt(dod, 0.01, 0.50);
dc    = hmrR_OD2Conc_new(dod, acquired.probe, [1,1]);
dcAvg = hmrR_BlockAvg (dc, acquired.stim, [-2,20]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract plot data from output of last function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = dcAvg.time;
y = dcAvg.GetDataTimeSeries('reshape');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PlotData(t, y, hbType, channels);


