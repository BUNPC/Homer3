% SYNTAX:
% function data_dc = hmrR_MotionCorrectCbsi(data_dc, mlActAuto, turnon)
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
% Cbsi_Motion_Correction: dc = hmrR_MotionCorrectCbsi(dc, mlActAuto, turnon)
%
% PARAMETERS:
% turnon: 1
%
% LOG:
% created 10-17-2012, S. Brigadoi
%

function data_dc = hmrR_MotionCorrectCbsi(data_dc, mlActAuto, turnon)

% Added turn on/off option
if ~exist('turnon','var')
    turnon = 1;
end
if turnon==0
    return;
end
if isempty(mlActAuto)
    mlActAuto = cell(length(data_dc),1);
end

for iBlk=1:length(data_dc)
    dc = data_dc(iBlk).GetDataTimeSeries();
    ml = data_dc(iBlk).GetMeasListSrcDetPairs();
    
    dc = reshape(dc, size(dc,1), 3, size(dc,2)/3);
    
    if isempty(mlActAuto{iBlk})
        mlActAuto{iBlk} = ones(size(ml,1),1);
    end    
    mlAct = mlActAuto{iBlk};

    lstAct = find(mlAct(1:size(ml,1))==1);
    dcCbsi = dc;
    
    for ii = 1:length(lstAct)
        idx_ch = lstAct(ii);
        
        dc_oxy = squeeze(dc(:,1,idx_ch)-mean(dc(:,1,idx_ch),1));
        dc_deoxy = squeeze(dc(:,2,idx_ch)-mean(dc(:,2,idx_ch),1));
        
        sd_oxy = std(dc_oxy,0,1);
        sd_deoxy = std(dc_deoxy,0,1);
        
        alfa = sd_oxy/sd_deoxy;
        
        dcCbsi(:,1,idx_ch) = 0.5*(dc_oxy-alfa*dc_deoxy);
        dcCbsi(:,2,idx_ch) = -(1/alfa)*dcCbsi(:,1,idx_ch);
        dcCbsi(:,3,idx_ch) = dcCbsi(:,1,idx_ch) + dcCbsi(:,2,idx_ch);
    end
    dcCbsi = reshape(dcCbsi, size(dcCbsi,1), size(dcCbsi,2)*size(dcCbsi,3));    
    data_dc(iBlk).SetDataTimeSeries(dcCbsi);
end

