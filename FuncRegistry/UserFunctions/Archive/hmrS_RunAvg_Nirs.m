% SYNTAX:
% [yAvg, yAvgStd, tHRF, nTrials] = hmrS_RunAvg_Nirs(yAvgRuns, yAvgStdRuns, ySum2Runs, tHRFRuns, mlActRuns, nTrialsRuns)
%
% UI NAME:
% Run_Average
%
% DESCRIPTION:
% Calculate avearge HRF of all runs for one subject. 
%
% INPUTS:
% yAvgRuns:
% yAvgStdRuns:
% tHRFRuns: 
% mlActRuns:
% nTrialsRuns:
% trange: defines the range for the block average
% thresh: Threshold for excluding channels if it's data deviates too much
%         from mean 
%
% OUTPUTS:
% yavg: the averaged results
% yAvgStd: the standard deviation across trials
% tHRF: the time vector
% nTrials: the number of trials averaged for each condition across all runs
%
% USAGE OPTIONS:
% Run_Average_on_Concentration_Data:  [dcAvg, dcAvgStd, tHRF, nTrials]    = hmrS_RunAvg_Nirs(dcAvgRuns, dcAvgStdRuns, dcSum2Runs, tHRFRuns, mlActRuns, nTrialsRuns)
% Run_Average_on_Delta_OD_Data:       [dodAvg, dodAvgStd, tHRF, nTrials]  = hmrS_RunAvg_Nirs(dodAvgRuns, dodAvgStdRuns, dodSum2Runs, tHRFRuns, mlActRuns, nTrialsRuns)
%

function [yAvg, yAvgStd, tHRF, nTrials] = hmrS_RunAvg_Nirs(yAvgRuns, yAvgStdRuns, ySum2Runs, tHRFRuns, mlActRuns, nTrialsRuns)

yAvg = [];
yAvgStd = [];
tHRF = [];
nTrials_tot = [];
grp1=[];

for iRun = 1:length(yAvgRuns)
    
    yAvg      = yAvgRuns{iRun};
    yAvgStd   = yAvgStdRuns{iRun};
    ySum2     = ySum2Runs{iRun};
    tHRF      = tHRFRuns{iRun};
    nTrials   = nTrialsRuns{iRun};
    mlAct     = mlActRuns{iRun};
    
    if isempty(yAvg)
        break;
    end
    
    nCond = size(nTrials,2);
    
    if ndims(yAvg) == (3-(nCond<2))
        
        if isempty(mlAct)
            mlAct = 1:size(yAvg,2);
        end
        
        % grab tHRF to make common for group average
        if iRun==1
            grp1 = zeros(size(yAvg,1), size(yAvg,2), nCond);
            grp1Sum2 = zeros(size(yAvg,1), size(yAvg,2), nCond);
            nTrials_tot = zeros(size(yAvg,2), nCond);
        end
        
        for iC = 1:nCond
            nT = nTrials(iC);            
            if nT>0
                if iRun==1
                    grp1(:,mlAct,iC) = yAvg(:,mlAct,iC) * nT;
                    grp1Sum2(:,mlAct,iC) = ySum2(:,mlAct,iC);
                    nTrials_tot(mlAct,iC) = nT;
                else
                    for iCh=1:length(mlAct) %size(yAvg,2)
                        grp1(:,mlAct(iCh),iC) = grp1(:,mlAct(iCh),iC) + interp1(tHRF,yAvg(:,mlAct(iCh),iC),tHRF(:)) * nT;
                        grp1Sum2(:,mlAct(iCh),iC) = grp1Sum2(:,mlAct(iCh),iC) + interp1(tHRF,ySum2(:,mlAct(iCh),iC),tHRF(:));
                        nTrials_tot(mlAct(iCh),iC) = nTrials_tot(mlAct(iCh),iC) + nT;
                    end
                end
            end
        end
        yAvg    = [];
        yAvgStd = [];
        if ~isempty(grp1)
            for iC = 1:size(grp1,3)
                for iCh = 1:size(grp1,2)
                    yAvg(:,iCh,iC) = grp1(:,iCh,iC) / nTrials_tot(iCh,iC);
                    
                    % We want to distinguish between no trials and 1 trial:
                    % If there are no trials, we have no HRF data and no std which
                    % the first case will calculate as opposed to one trial (2nd case)
                    % where we have all zeros.
                    if(nTrials_tot(iCh,iC)~=1)
                        yAvgStd(:,iCh,iC) = ( (1/(nTrials_tot(iCh,iC)-1))*grp1Sum2(:,iCh,iC) - (nTrials_tot(iCh,iC)/(nTrials_tot(iCh,iC)-1))*(grp1(:,iCh,iC) / nTrials_tot(iCh,iC)).^2).^0.5 ;
                    else
                        yAvgStd(:,iCh,iC) = zeros(size(grp1Sum2(:,iCh,iC)));
                    end
                end
            end
        end
        
    elseif ndims(yAvg) == (4-(nCond<2))
        
        if isempty(mlAct)
            mlAct = 1:size(yAvg,3);
        end
        
        % grab tHRF to make common for group average
        if iRun==1
            grp1 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
            grp1Sum2 = zeros(size(yAvg,1), size(yAvg,2), size(yAvg,3), nCond);
            nTrials_tot = zeros(size(yAvg,3), nCond);
        end
        
        for iC = 1:1:nCond
            nT = nTrials(iC);
            if nT>0
                if iRun==1
                    grp1(:,:,mlAct,iC) = yAvg(:,:,mlAct,iC) * nT;
                    grp1Sum2(:,:,mlAct,iC) = ySum2(:,:,mlAct,iC);
                    nTrials_tot(mlAct,iC) = nT;
                else
                    for iCh=1:length(mlAct) %size(yAvg,3)
                        for iHb=1:size(yAvg,2)
                            grp1(:,iHb,mlAct(iCh),iC) = grp1(:,iHb,mlAct(iCh),iC) + interp1(tHRF,yAvg(:,iHb,mlAct(iCh),iC),tHRF(:)) * nT;
                            grp1Sum2(:,iHb,mlAct(iCh),iC) = grp1Sum2(:,iHb,mlAct(iCh),iC) + interp1(tHRF,ySum2(:,iHb,mlAct(iCh),iC),tHRF(:));
                        end
                        nTrials_tot(mlAct(iCh),iC) = nTrials_tot(mlAct(iCh),iC) + nT;
                    end
                end
            end
        end
        yAvg    = [];
        yAvgStd = [];
        if ~isempty(grp1)
            for iC = 1:size(grp1,4)
                for iCh = 1:size(grp1,3)
                    yAvg(:,:,iCh,iC) = grp1(:,:,iCh,iC) / nTrials_tot(iCh,iC);
                    
                    % We want to distinguish between no trials and 1 trial:
                    % If there are no trials, we have no HRF data and no std which
                    % the first case will calculate as opposed to one trial (2nd case)
                    % where we have all zeros.
                    if(nTrials_tot(iCh,iC)~=1)
                        yAvgStd(:,:,iCh,iC) = ( (1/(nTrials_tot(iCh,iC)-1))*grp1Sum2(:,:,iCh,iC) - (nTrials_tot(iCh,iC)/(nTrials_tot(iCh,iC)-1))*(grp1(:,:,iCh,iC) / nTrials_tot(iCh,iC)).^2).^0.5 ;
                    else
                        yAvgStd(:,:,iCh,iC) = zeros(size(grp1Sum2(:,:,iCh,iC)));
                    end
                end
            end
        end
    end
end
nTrials = nTrials_tot;
