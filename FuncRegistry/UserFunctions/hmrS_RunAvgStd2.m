% SYNTAX:
% yAvgStd = hmrS_RunAvgStd2(yAvgStdRuns, nTrialsRuns)
%
% UI NAME:
% Run_Average_Standard_Deviation
%
% DESCRIPTION:
% Calculates a weighted avearge of HRF standard deviation across runs within a subject.
%
% INPUTS:
% yAvgStdRuns:
% nTrialsRuns:
%
% OUTPUTS:
% yAvgStdOut: the standard deviation across runs
%
% USAGE OPTIONS:
% Run_Average_Standard_Deviation_on_Concentration_Data:  dcAvgStd  = hmrS_RunAvgStd2(dcAvgStdRuns, nTrialsRuns)
%

function yAvgStdOut = hmrS_RunAvgStd2(yAvgStdRuns, nTrialsRuns)

yAvgStdOut = DataClass();
N = 0;
var = 0;
nDataBlks = length(yAvgStdRuns{1});

% find max nCond
for i = 1:size(nTrialsRuns, 2); niC(i) = size(nTrialsRuns{i}{1},2); end
niC = max(niC);

for iBlk = 1:nDataBlks
    % get tHRF and ml from yAvgRuns
    for iRun = 1:length(yAvgStdRuns)
    tHRF    = yAvgStdRuns{iRun}(iBlk).GetTime();
    ml    = yAvgStdRuns{iRun}(iBlk).GetMeasListSrcDetPairs();
    if ~isempty(ml)
        break
    end
    end
    yAvgStdOut(iBlk).SetTime(tHRF);
    
    
    for iC = 1:niC % across conditions
        
        % get total number of trials per given condition
        for iRun = 1:length(yAvgStdRuns)
            if ~isempty(nTrialsRuns{iRun}{iBlk})
                N = N + nTrialsRuns{iRun}{iBlk}(iC);
            end
        end
        
        %         if N ~= 0
        % get average of variance across runs weighted by number of trials within a run
        for iRun = 1:length(yAvgStdRuns)
            if  ~isempty(nTrialsRuns{iRun}{iBlk})
                if nTrialsRuns{iRun}{iBlk}(iC) ~= 0
                    yAvgStd    = yAvgStdRuns{iRun}(iBlk).GetDataTimeSeries('reshape');
                    if isempty(yAvgStd) ~= 1
                        var = var + (nTrialsRuns{iRun}{iBlk}(iC)-1)/(N-1) * yAvgStd(:,:,:,iC).^2;
                    end
                end
            end
        end
        
            % get std and append
            yAvgStd_wa = sqrt(var);
            if yAvgStd_wa == 0
               yAvgStd_wa = zeros(size(tHRF,1), 3, size(ml,1));
            end
            yAvgStdOut(iBlk).AppendDataTimeSeries(yAvgStd_wa);
            var = 0;
            N = 0;
            
            % add measlist field
%             if ~isempty(ml)
                for iCh = 1:size(ml,1)
                    yAvgStdOut(iBlk).AddChannelHbO(ml(iCh,1), ml(iCh,2), iC);
                    yAvgStdOut(iBlk).AddChannelHbR(ml(iCh,1), ml(iCh,2), iC);
                    yAvgStdOut(iBlk).AddChannelHbT(ml(iCh,1), ml(iCh,2), iC);
                end
%             end
%         end
        
    end
end

