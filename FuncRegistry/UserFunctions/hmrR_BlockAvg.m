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
data_avg  = DataClass();
data_std  = DataClass();
data_sum2 = DataClass();
nTrials   = [];
yTrials   = [];

% Get stim vector by instantiating temporary SnirfClass object with this 
% function's stim argument as input, and then using the SnirfClass object's 
% GetStims method to convert stim to the s vector that this function needs. 
snirf = SnirfClass(data, stim);
s = snirf.GetStims();

for kk=1:length(data)
    datatype = data(kk).GetDataTypeLabel();  % Get the input data type
    y = data(kk).GetD();    % Get the data vector 
    if datatype(1)==6
        y = reshape(y, size(y,1), 3, size(y,2)/3);
    end
    t = data(kk).GetT();    % Get the time vector 
    dt = t(2)-t(1);
    nPre = round(trange(1)/dt);
    nPost = round(trange(2)/dt);
    nTpts = size(y,1);
    tHRF = [nPre*dt:dt:nPost*dt];
    if datatype(1)==6
        ml = data(kk).GetMeasListSrcDetPairs();
    elseif datatype(1)==1
        ml = data(kk).GetMeasList();
    else
        return;
    end
    
    for iS = 1:size(s,2)
        lstS = find(s(:,iS)==1);
        if datatype(1)==6
            yblk = zeros(nPost-nPre+1,size(y,2),size(y,3),length(lstS));
        elseif datatype(1)==1
            yblk = zeros(nPost-nPre+1,size(y,2),length(lstS));
        end
        nBlk = 0;
        for iT = 1:length(lstS)
            if (lstS(iT)+nPre)>=1 && (lstS(iT)+nPost)<=nTpts
                if datatype(1)==6
                    nBlk = nBlk + 1;
                    yblk(:,:,:,nBlk) = y(lstS(iT)+[nPre:nPost],:,:); %changed from yblk(:,:,:,end+1)
                elseif datatype(1)==1
                    nBlk = nBlk + 1;
                    yblk(:,:,nBlk) = y(lstS(iT)+[nPre:nPost],:); % changd from yblk(:,:,end+1)
                end
            else
                fprintf('WARNING: Trial %d for Condition %d EXCLUDED because of time range\n',iT,iS);
            end
        end
        
        if datatype(1)==6
            yTrials(iS).yblk = yblk(:,:,:,1:nBlk);
            yavg(:,:,:,iS) = mean(yblk(:,:,:,1:nBlk),4);
            ystd(:,:,:,iS) = std(yblk(:,:,:,1:nBlk),[],4);
            nTrials(iS) = nBlk;
            
            % Loop over all channels
            for ii=1:size(yavg,3)
                foom = ones(size(yavg,1),1)*mean(yavg(1:-nPre,:,ii,iS),1);
                yavg(:,:,ii,iS) = yavg(:,:,ii,iS) - foom;
                
                for iBlk = 1:nBlk
                    yTrials(iS).yblk(:,:,ii,iBlk) = yTrials(iS).yblk(:,:,ii,iBlk) - foom;
                end
                ysum2(:,:,ii,iS) = sum( yTrials(iS).yblk(:,:,ii,1:nBlk).^2 ,4);
                
                % Snirf stuff: set channel descriptors
                % Concentration 
                data_avg(kk).AddChannelDc(ml(ii,1), ml(ii,2), 6, iS);
                data_avg(kk).AddChannelDc(ml(ii,1), ml(ii,2), 7, iS);
                data_avg(kk).AddChannelDc(ml(ii,1), ml(ii,2), 8, iS);
                
                % Standard deviation 
                data_std(kk).AddChannelDc(ml(ii,1), ml(ii,2), 6, iS);
                data_std(kk).AddChannelDc(ml(ii,1), ml(ii,2), 7, iS);
                data_std(kk).AddChannelDc(ml(ii,1), ml(ii,2), 8, iS);
                
                % 
                data_sum2(kk).AddChannelDc(ml(ii,1), ml(ii,2), 6, iS);
                data_sum2(kk).AddChannelDc(ml(ii,1), ml(ii,2), 7, iS);
                data_sum2(kk).AddChannelDc(ml(ii,1), ml(ii,2), 8, iS);
            end
            
            % Snirf stuff: set data vectors
            data_avg(kk).AppendD(yavg(:,:,:,iS));
            data_std(kk).AppendD(ystd(:,:,:,iS));
            data_sum2(kk).AppendD(ysum2(:,:,:,iS));
        elseif datatype(1)==1
            yTrials(iS).yblk = yblk(:,:,1:nBlk);
            yavg(:,:,iS) = mean(yblk(:,:,1:nBlk),3);
            ystd(:,:,iS) = std(yblk(:,:,1:nBlk),[],3);
            nTrials(iS) = nBlk;

            % Loop over all wavelengths
            for ii=1:size(yavg,2)
                foom = ones(size(yavg,1),1)*mean(yavg(1:-nPre,ii,iS),1);
                yavg(:,ii,iS) = yavg(:,ii,iS) - foom;
                
                for iBlk = 1:nBlk
                    yTrials(iS).yblk(:,ii,iBlk) = yTrials(iS).yblk(:,ii,iBlk) - foom;
                end
                ysum2(:,ii,iS) = sum( yTrials(iS).yblk(:,ii,1:nBlk).^2 ,3);

                % Snirf stuff: set channel descriptors
                data_avg(kk).AddChannelDod(ml(ii,1), ml(ii,2), ml(ii,4), iS);
                data_std(kk).AddChannelDod(ml(ii,1), ml(ii,2), ml(ii,4), iS);
                data_sum2(kk).AddChannelDod(ml(ii,1), ml(ii,2), ml(ii,4), iS);
            end
            
            % Snirf stuff: set data vectors
            data_avg(kk).AppendD(yavg(:,:,iS));
            data_std(kk).AppendD(ystd(:,:,iS));
            data_sum2(kk).AppendD(ysum2(:,:,iS));
        end
    end
    
    % Snirf stuff: set time vectors
    data_avg(kk).SetT(tHRF);
    data_std(kk).SetT(tHRF);
    data_sum2(kk).SetT(tHRF);

end
