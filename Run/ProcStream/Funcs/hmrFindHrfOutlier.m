% [s,yAvg,yStd,nTrials,ysum2,yTrials] = hmrFindHrfOutlier( s, tHRF, yTrials, tRange, stdThresh, minNtrials )
%
% UI NAME:
% Find_Outlier_Trials
%
% Find trials that are outliers with respect to the average HRF. Remove
% those trials from the stimulus vector s and reaverage the results. The
% mean and standard deviation of the trials are found over the time range
% specified by tRange. Outliers are trials with a mean deviating more
% than stdThresh standard deviations from the mean.
%
% INPUTS:
% s: The stimulus vector
% tHRF: The time vector for the HRF. This is generally returned with the
%       HRF from hmrBlockAvg() or comparable functions.
% yTrials: This structure contains the response to each trial for each
%          stimulus condition. This structure is obtained from hmrBlockAvg().
% tRange: The time range over which the mean is estimated.
% stdThresh: The number of standard deviations that a trial must deviate
%            to be considered an outlier.
% minNtrials: Only remove outliers if number of trials for the given 
%             condition is equal to our greater than this limit.
%
% OUTPUTS:
% s: the stimulus vector revised for any trials removed as outliers
% yAvg: the averaged results
% yStd: the standard deviation across trials
% nTrials: the number of trials averaged for each condition
% ysum2: A variable that enables calculation of the standard deviation
%        across multiple runs for a single subject.
% yTrials: a structure containing the individual trial responses
%
% TO DO:
% This function assumes the data is hemoglobin concentrations. The code
% should be modified to handle either wavelength data or hemoglobin
% concentration data.
%


function [s,yAvg,yStd,nTrials,ysum2,yTrials] = hmrFindHrfOutlier( s, tHRF, yTrials, tRange, stdThresh, minNtrials )

lst = find(tHRF>=tRange(1) & tHRF<=tRange(2));
nPre = length(find(tHRF<0));

nStim = length(yTrials);

for iS=1:nStim
    
    lstS = find(s(:,iS)==1);
    
    nTrials = size(yTrials(iS).yblk,4);
    outTrial = zeros(nTrials,2);
    
    if nTrials>=minNtrials
        for iHb = 1:2
            yRange = squeeze( mean( mean(yTrials(iS).yblk(lst,iHb,:,:),1), 4) );
            yRangeStd = squeeze( std( mean(yTrials(iS).yblk(lst,iHb,:,:),1), 0, 4) );
            yRangeTrial = squeeze( mean(yTrials(iS).yblk(lst,iHb,:,:),1) );
            
            for iT = 1:nTrials
                
                lstOut = find( yRangeTrial(:,iT) > yRange+yRangeStd*stdThresh | ...
                    yRangeTrial(:,iT) < yRange-yRangeStd*stdThresh );
                
                if ~isempty(lstOut)
                    outTrial(iT,iHb) = 1;
                    s(lstS(iT),iS) = -2;
                end
                
            end %Hb loop
        end %trial loop
    end %check nTrials

    lstInc = find( sum(outTrial,2)==0 );
    
    yTrials(iS).yblk = yTrials(iS).yblk(:,:,:,lstInc);
    yAvg(:,:,:,iS) = mean( yTrials(iS).yblk, 4);
    yStd(:,:,:,iS) = std( yTrials(iS).yblk, [], 4);
    nTrials(iS) = length(lstInc);
    
    
    for ii = 1:size(yAvg,3)
        foom = ones(size(yAvg,1),1)*mean(yAvg(1:-nPre,:,ii,iS),1);
        yAvg(:,:,ii,iS) = yAvg(:,:,ii,iS) - foom;
        
        nBlk = length(lstInc);
        for iBlk = 1:nBlk
            yTrials(iS).yblk(:,:,ii,iBlk) = yTrials(iS).yblk(:,:,ii,iBlk) - foom;
        end
        ysum2(:,:,ii,iS) = sum( yTrials(iS).yblk(:,:,ii,1:nBlk).^2 ,4);
    end
        
end % stim loop
