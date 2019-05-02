% SYNTAX:
% data_dod = hmrR_MotionCorrectRLOESS(data_dod, span, turnon)
%
% UI NAME:
% Motion_Correct_RLOESS
%
% DESCRIPTION:
%
% INPUTS:
% data_dod: SNIRF data structure containing delta_OD
% span:
% turnon:   Optional argument to enable/disable this function in a processing stream chain
%
% OUTPUTS:
% data_dod: SNIRF data structure containing delta_OD after motion correction,
%           same size as dod (Channels that are not in the active ml remain unchanged)
%
% USAGE OPTIONS:
% Motion_Correct_RLOESS: dod = hmrR_MotionCorrectRLOESS(dod, span, turnon)
%
% PARAMETERS:
% span: 0.02
% turnon: 1
%
% LOG:
%
function data_dod = hmrR_MotionCorrectRLOESS(data_dod, span, turnon)

% span = 0.02 (default)
if span<0
    return
end

% Meryem Yucel, Oct, 2017
% Added turn on/off option Meryem Nov 2017
if ~exist('turnon','var')
    turnon = 1;
end
if turnon==0
    return;
end

for iBlk=1:length(data_dod)
    dod = data_dod(iBlk).GetDataTimeSeries();
    t   = data_dod(iBlk).GetTime();
    for i=1:size(dod,2)
        dod(:,i) = smooth(t, dod(:,i), span, 'rloess');
    end
    data_dod(iBlk).SetDataTimeSeries(dod);    
end