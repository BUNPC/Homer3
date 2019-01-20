% [yavg, ystd, tHRF, nTrials, ysum2, yTrials] = hmrBlockAvg( y, s, t, trange )
%
% UI NAME:
% Block_Average
%
%
% Calculate the block average given the stimulation conditions in s over
% the time range trange. The baseline of the average is set to zero by
% subtracting the mean of the average for t<0. If a stimulus occurs too
% close to the start or end of the data such that trange extends outside of
% the data range, then the trial is excluded from the average.
%
% INPUTS:
% y: this is the data wavelength #time points x #channels
%    concentration data is #time points x [HbO/HbR/HbT] x #channels
% s: stimulation vector (# time points x #conditions)=1 at stim onset otherwise =0
% t: time vector corresponding with y and s
% trange: defines the range for the block average [tPre tPost]
% 
% OUTPUTS:
% yavg: the averaged results
% ystd: the standard deviation across trials
% tHRF: the time vector
% nTrials: the number of trials averaged for each condition
% yTrials: a structure containing the individual trial responses



function [yavg, ystd, tHRF, nTrials, ysum2, yTrials] = hmrBlockAvg( y, s, t, trange )



ndim = ndims(y);
dt = t(2)-t(1);
nPre = round(trange(1)/dt);
nPost = round(trange(2)/dt);
nTpts = size(y,1);
tHRF = [nPre*dt:dt:nPost*dt];

for iS = 1:size(s,2)
    lstS = find(s(:,iS)==1);
    yblk = zeros(nPost-nPre+1,size(y,2),size(y,3),length(lstS));
    
    nBlk = 0;
    for iT = 1:length(lstS)
        if (lstS(iT)+nPre)>=1 && (lstS(iT)+nPost)<=nTpts
            if ndim==3
                nBlk = nBlk + 1;
                yblk(:,:,:,nBlk) = y(lstS(iT)+[nPre:nPost],:,:); %changed from yblk(:,:,:,end+1)
            elseif ndim==2
                nBlk = nBlk + 1;
                yblk(:,:,nBlk) = y(lstS(iT)+[nPre:nPost],:); % changd from yblk(:,:,end+1)
            end
        else
            disp( sprintf('WARNING: Trial %d for Condition %d EXCLUDED because of time range',iT,iS) );
        end
    end

    if ndim==3
        yTrials(iS).yblk = yblk(:,:,:,1:nBlk);
        yavg(:,:,:,iS) = mean(yblk(:,:,:,1:nBlk),4);
        ystd(:,:,:,iS) = std(yblk(:,:,:,1:nBlk),[],4);
        nTrials(iS) = nBlk;
        for ii = 1:size(yavg,3) 
            foom = ones(size(yavg,1),1)*mean(yavg(1:-nPre,:,ii,iS),1);
            yavg(:,:,ii,iS) = yavg(:,:,ii,iS) - foom;

            for iBlk = 1:nBlk
                yTrials(iS).yblk(:,:,ii,iBlk) = yTrials(iS).yblk(:,:,ii,iBlk) - foom;
            end
            ysum2(:,:,ii,iS) = sum( yTrials(iS).yblk(:,:,ii,1:nBlk).^2 ,4);
        end

    elseif ndim==2
        yTrials(iS).yblk = yblk(:,:,1:nBlk);
        yavg(:,:,iS) = mean(yblk(:,:,1:nBlk),3);
        ystd(:,:,iS) = std(yblk(:,:,1:nBlk),[],3);
        nTrials(iS) = nBlk;
        for ii = 1:size(yavg,2) 
            foom = ones(size(yavg,1),1)*mean(yavg(1:-nPre,ii,iS),1);
            yavg(:,ii,iS) = yavg(:,ii,iS) - foom;

            for iBlk = 1:nBlk
                yTrials(iS).yblk(:,ii,iBlk) = yTrials(iS).yblk(:,ii,iBlk) - foom;
            end
            ysum2(:,ii,iS) = sum( yTrials(iS).yblk(:,ii,1:nBlk).^2 ,3);
        end
        
    end

end
