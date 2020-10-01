function [y, t] = Raw_to_DeltaConc_Example(filename, hbType, channels)
%
%    Example 1:   Plot channel 1 delta HbO concentration, derived from
%                 acquisition file test.snirf
%
%       cd '<root folder>\Homer3\UnitTests\Example_RunFuncOffline'
%       Raw_to_DeltaConc_Example('./test.snirf');
%    
%    Example 2:   Plot channels 1 and 2 delta HbR concentration, derived 
%                 from acquisition file test.snirf
%
%       cd '<root folder>\Homer3\UnitTests\Example_RunFuncOffline'
%       Raw_to_DeltaConc_Example('./test.snirf', 2, [1,2]);
%    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse args 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Arg 1
[pname, fname] = fileparts(filename);

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
acquired = SnirfClass([pname, '/', fname, '.snirf']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call sequence of user functions to get from acquired data 
% to delta concentration 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dod = hmrR_Intensity2OD(acquired.data); 
dod = hmrR_BandpassFilt(dod, 0.01, 0.50);
dc  = hmrR_OD2Conc_new(dod, acquired.probe, [1,1]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract plot data from output of last function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = dc.time;
y = dc.GetDataTimeSeries('reshape');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PlotData(t, y, hbType, channels);


