% function dcCbsi = hmrMotionCorrectCbsi(dc,SD,flagSkip)
%
% UI NAME:
% Cbsi_Motion_Correction
%
% Perform a correlation-based signal improvement of the concentration
% changes in order to correct for motion artifacts.  
% The algorithm follows the procedure described by
% Cui et al.,NeuroImage, 49(4), 3039-46 (2010).
%
% INPUTS:
% dc:    Concentration changes (it works with HbO and HbR)
% SD:    SD structure
% flagSkip:  Skip this function if flagSkip=1. Otherwise execute function. 
%            Default is to execute function if this does not exist.
% 
%
% OUTPUTS:
% dcSpline:  dc after correlation-based signal improvement correction, same
%            size as dc (Channels that are not in the active ml remain unchanged)
%
% LOG:
% created 10-17-2012, S. Brigadoi
%

function dcCbsi = hmrMotionCorrectCbsi(dc,SD,flagSkip)

if ~exist('flagSkip')
    flagSkip = 0;
end
if flagSkip==1
    dcCbsi = dc;
    return;
end

mlAct = SD.MeasListAct; % prune bad channels

lstAct = find(mlAct(1:end/2)==1);
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