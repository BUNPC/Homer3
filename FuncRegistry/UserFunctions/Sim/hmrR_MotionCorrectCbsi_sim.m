% SYNTAX:
% function data_dc = hmrR_MotionCorrectCbsi_sim(data_dc, mlActAuto, turnon)
%
% UI NAME:
% Cbsi_Motion_Correction
%
% DESCRIPTION:
% Perform a correlation-based signal improvement of the concentration
% changes in order to correct for motion artifacts.
% The algorithm follows the procedure described by
% Cui et al.,NeuroImage, 49(4), 3039-46 (2010).
%
% INPUTS:
% data_dc:   Concentration changes (it works with HbO and HbR)
% mlActAuto: 
% turnon:    Skip this function if turnon=1. Otherwise execute function.
%            Default is to execute function if this does not exist.
%
%
% OUTPUTS:
% data_dc:  dc after correlation-based signal improvement correction, same
%           size as dc (Channels that are not in the active ml remain unchanged)
%
% USAGE OPTIONS:
% Cbsi_Motion_Correction: dc = hmrR_MotionCorrectCbsi_sim(dc, mlActAuto, turnon)
%
% PARAMETERS:
% turnon: 1
%
% PREREQUISITES:
% Delta_OD_to_Conc: dc = hmrR_OD2Conc( dod, probe, ppf )
%
% LOG:
% created 10-17-2012, S. Brigadoi
%

function data_dc = hmrR_MotionCorrectCbsi_sim(data_dc, mlActAuto, turnon)

% Added turn on/off option
if ~exist('turnon','var')
    turnon = 1;
end
if turnon==0
    return;
end
for iBlk = 1:length(data_dc)
    dc0 = data_dc(iBlk).GetDataTimeSeries();
    ml0 = data_dc(iBlk).GetMeasurementList();
    [dc, ~, ~, order] = data_dc(iBlk).GetDataTimeSeries('reshape');
    ml = data_dc(iBlk).GetMeasurementList('matrix','reshape');
    dcCbsi = dc;
    dcCbsi(:,order) = dcCbsi(:,:);
    data_dc(iBlk).SetDataTimeSeries(dcCbsi);
end

