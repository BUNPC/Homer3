% SYNTAX:
% [data_avg, data_std, nTrials, data_sum2, yTrials] = hmrR_BlockAvg( data, stim, trange )
%
% UI NAME:
% Block_Average
%
% DESCRIPTION:
% Calculate the block average given the stimulation conditions in s over
% the time range trange. The baseline of the average is set to zero by
% subtracting the mean of the average for t<0. If a stimulus occurs too
% close to the start or end of the data such that trange extends outside of
% the data range, then the trial is excluded from the average.
%
% INPUT:
% data: SNIRF.data container with the delta OD or delat concentration data
% stim: SNIRF.stim container with the stimulus condition data
% trange: defines the range for the block average [tPre tPost]
%
% OUTPUT:
% data_avg: SNIRF.data container with the averaged results
% data_std: SNIRF.data container with the standard deviation across trials
% nTrials: the number of trials averaged for each condition
% data_sum2: SNIRF.data container ...
% yTrials: a structure containing the individual trial responses
%
% USAGE OPTIONS:
% Block_Average_on_Concentration_Data: [dcAvg, dcAvgStd, nTrials, dcSum2] = hmrR_BlockAvg( dc, stim, trange )
% Block_Average_on_Delta_OD_Data: [dodAvg, dodAvgStd, nTrials, dodSum2] = hmrR_BlockAvg( dod, stim, trange )
%
% PARAMETERS:
% trange: [-2.0, 20.0]
%

function [data_avg, data_std, nTrials, data_sum2, yTrials] = hmrR_BlockAvg( data, stim, trange )

% Initialize outputs;
data_avg  = DataClass().empty();
data_std  = DataClass().empty();
data_sum2 = DataClass().empty();
yTrials   = [];

% Get stim vector by instantiating temporary SnirfClass object with this 
% function's stim argument as input, and then using the SnirfClass object's 
% GetStims method to convert stim to the s vector that this function needs. 
snirf = SnirfClass(data, stim);
t = snirf.GetTimeCombined();
s = snirf.GetStims(t);
nTrials = cell(length(data),1);

for kk=1:length(data)
    data_avg(kk) = DataClass();
    data_std(kk) = DataClass();
    data_sum2(kk) = DataClass();
    yavg = [];
    ystd = [];
    ysum2 = [];
    
    nTrials{kk} = zeros(1, size(s,2));
    
    datatype = data(kk).GetDataTypeLabel();  % Get the input data type
    y = data(kk).GetDataTimeSeries('reshape');    % Get the data vector 
    t = data(kk).GetTime();    % Get the time vector 
    dt = t(2)-t(1);
    nPre = round(trange(1)/dt);
    nPost = round(trange(2)/dt);
    nTpts = size(y,1);
    tHRF = nPre*dt:dt:nPost*dt;
    if strncmp(datatype{1}, 'Hb', 2)
        ml = data(kk).GetMeasListSrcDetPairs();
        yblk = zeros(nPost-nPre+1,size(y,2),size(y,3),size(s,2));
    elseif strcmp(datatype{1}, 'dOD')
        ml = data(kk).GetMeasList();
        yblk = zeros(nPost-nPre+1,size(y,2),size(s,2));
    else
        return;
    end
           
    for iC = 1:size(s,2)
        lstS = find(s(:,iC)==1);
        nBlk = 0;
        for iT = 1:length(lstS)
            if (lstS(iT)+nPre)>=1 && (lstS(iT)+nPost)<=nTpts
                if strncmp(datatype{1}, 'Hb', 2)
                    nBlk = nBlk + 1;
                    yblk(:,:,:,nBlk) = y(lstS(iT)+[nPre:nPost],:,:); %changed from yblk(:,:,:,end+1)
                elseif strcmp(datatype{1}, 'dOD')
                    nBlk = nBlk + 1;
                    yblk(:,:,nBlk) = y(lstS(iT)+[nPre:nPost],:); % changd from yblk(:,:,end+1)
                end
            else
                fprintf('WARNING: Trial %d for Condition %d EXCLUDED because of time range\n',iT,iC);
            end
        end
        
        if strncmp(datatype{1}, 'Hb', 2)
            yTrials(iC).yblk = yblk(:,:,:,1:nBlk);
            yavg(:,:,:,iC) = mean(yblk(:,:,:,1:nBlk),4);
            ystd(:,:,:,iC) = std(yblk(:,:,:,1:nBlk),[],4);
            nTrials{kk}(iC) = nBlk;
            
            % Loop over all channels
            for ii=1:size(yavg,3)
                foom = ones(size(yavg,1),1)*mean(yavg(1:-nPre,:,ii,iC),1);
                yavg(:,:,ii,iC) = yavg(:,:,ii,iC) - foom;
                
                for iBlk = 1:nBlk
                    yTrials(iC).yblk(:,:,ii,iBlk) = yTrials(iC).yblk(:,:,ii,iBlk) - foom;
                end
                ysum2(:,:,ii,iC) = sum( yTrials(iC).yblk(:,:,ii,1:nBlk).^2 ,4);
                
                % Snirf stuff: set channel descriptors
                % Concentration 
                data_avg(kk).AddChannelHbO(ml(ii,1), ml(ii,2), iC);
                data_avg(kk).AddChannelHbR(ml(ii,1), ml(ii,2), iC);
                data_avg(kk).AddChannelHbT(ml(ii,1), ml(ii,2), iC);
                
                % Standard deviation 
                data_std(kk).AddChannelHbO(ml(ii,1), ml(ii,2), iC);
                data_std(kk).AddChannelHbR(ml(ii,1), ml(ii,2), iC);
                data_std(kk).AddChannelHbT(ml(ii,1), ml(ii,2), iC);
                
                % 
                data_sum2(kk).AddChannelHbO(ml(ii,1), ml(ii,2), iC);
                data_sum2(kk).AddChannelHbR(ml(ii,1), ml(ii,2), iC);
                data_sum2(kk).AddChannelHbT(ml(ii,1), ml(ii,2), iC);
            end
            
            % Snirf stuff: set data vectors
            data_avg(kk).AppendDataTimeSeries(yavg(:,:,:,iC));
            data_std(kk).AppendDataTimeSeries(ystd(:,:,:,iC));
            data_sum2(kk).AppendDataTimeSeries(ysum2(:,:,:,iC));
        elseif strcmp(datatype{1}, 'dOD')
            yTrials(iC).yblk = yblk(:,:,1:nBlk);
            yavg(:,:,iC) = mean(yblk(:,:,1:nBlk),3);
            ystd(:,:,iC) = std(yblk(:,:,1:nBlk),[],3);
            nTrials{kk}(iC) = nBlk;

            % Loop over all wavelengths
            for ii=1:size(yavg,2)
                foom = ones(size(yavg,1),1)*mean(yavg(1:-nPre,ii,iC),1);
                yavg(:,ii,iC) = yavg(:,ii,iC) - foom;
                
                for iBlk = 1:nBlk
                    yTrials(iC).yblk(:,ii,iBlk) = yTrials(iC).yblk(:,ii,iBlk) - foom;
                end
                ysum2(:,ii,iC) = sum( yTrials(iC).yblk(:,ii,1:nBlk).^2 ,3);

                % Snirf stuff: set channel descriptors
                data_avg(kk).AddChannelDod(ml(ii,1), ml(ii,2), ml(ii,4), iC);
                data_std(kk).AddChannelDod(ml(ii,1), ml(ii,2), ml(ii,4), iC);
                data_sum2(kk).AddChannelDod(ml(ii,1), ml(ii,2), ml(ii,4), iC);
            end
            
            % Snirf stuff: set data vectors
            data_avg(kk).AppendDataTimeSeries(yavg(:,:,iC));
            data_std(kk).AppendDataTimeSeries(ystd(:,:,iC));
            data_sum2(kk).AppendDataTimeSeries(ysum2(:,:,iC));
        end
    end
    
    % Snirf stuff: set time vectors
    data_avg(kk).SetTime(tHRF, true);
    data_std(kk).SetTime(tHRF, true);
    data_sum2(kk).SetTime(tHRF, true);

end

