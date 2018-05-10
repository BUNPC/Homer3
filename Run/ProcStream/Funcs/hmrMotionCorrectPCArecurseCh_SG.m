function [dN,tInc,svs,nSV,tInc0] = hmrMotionCorrectPCArecurseCh_SG( dod, t, SD, tIncMan, nSV, maxIter, FrameSize_sec, turnon)
% This function first finds baseline shifts and corrects them with tPCA_Ch
% and then corrects the remaining spikes with Savitzky-Golay smoothing.
% Sahar Jahani, Oct 2017
% added turn on/off option Meryem, Nov 2017


if exist('turnon')
   if turnon==0
       dN = dod;
       tInc = tIncMan;
       svs = [];
       tInc0 = [tIncMan];      
   return;
   end
end




%% tPCA by channel
fs = abs(1/(t(1)-t(2)));
[tIncCh, tInc] = hmrtInc_baselineshift_Ch(dod, t);
tInc0 = tInc;
dN = dod;
svs = [];
mlAct = SD.MeasListAct;
lstAct = find(mlAct==1);

ii=0;
while length(find(tInc==0))>0 & ii<maxIter
    ii=ii+1;
    [dN,svs(:,ii),nSV] = hmrMotionCorrectPCA_Ch( SD, dod, min([tInc tIncMan],[],2),  tIncCh, nSV);
    [tIncCh, tInc] = hmrtInc_baselineshift_Ch(dN, t);
    dod = dN;
end
dod(end,:)=dod(end-1,:);
dN=dod;
%% Savitzky_Golay filter
K = 3; % polynomial order
FrameSize_sec = round(FrameSize_sec * fs);
if mod(FrameSize_sec,2)==0
    FrameSize_sec = FrameSize_sec  + 1;
end
dN=sgolayfilt(dN,K,FrameSize_sec);