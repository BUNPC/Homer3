% [yavg, yavgstd, tHRF, nTrials, ysum2] = hmrDeconvTB_SS3rd(y, s, t, SD, Aaux, trange, gstd, gms, rhoSD_ssThresh)
%
% UI NAME: 
% GLM_HRF_ShortSep_Drift
% This script estimates the HRF with a set a temporal basis functions,
% regresses the nearest short separation measurement,
% and uses a 3rd order polynomial regressor.
% The command line function call is
% [yavg, yavgstd, tHRF, nTrials, ysum2] = hmrDeconvTB_SS3rd(y, s, t, SD, Aaux, trange, gstd, gms, rhoSD_ssThresh)
% INPUTS:
% y - this is the data wavelength #time points x #channels
%    concentration data is #time points x [HbO/HbR/HbT] x #channels
% s - stimulation vector (# time points x #conditions)=1 at stim onset otherwise =0
% t - time vector corresponding with y and s
% SD - source detector stucture (units should be consistent with rhoSD_ssThresh)
% trange - defines the range for the block average [tPre tPost]
% gstd - std for gaussian shape temporal basis function (sec)
% gms - mean for gaussian shape temporal basis function (sec)
% rhoSD_ssThresh: max distance for a short separation measurement (cm)
% OUTPUTS:
% yavg - the averaged results
% ystd - the standard deviation across trials
% tHRF - the time vector
% nTrials - the number of trials averaged for each condition
% LOG
% created 1-14-2011 L. Gagnon


function [yavg, yavgstd, tHRF, nTrials, ynew, yresid, ysum2] = hmrDeconvTB_SS3rd(y, s, t, SD, Aaux, trange, gstd, gms, rhoSD_ssThresh)


%rhoSD_ssThresh = 1.5;  % max distance for a short separation measurement

nDec = 1; % I added code to decimate, but it does weird things to the estimate
    % the error is increasing when we decimate. This may be an indication
    % that we are actually underestimating the error without decimation
    % because we are not properly accounting for the temporal correlation.
    % Also, have to be careful about the temporal resolution of the basis
    % functions if we decimate.
    
dt = t(2)-t(1);
nPre = round(trange(1)/dt);
nPost = round(trange(2)/dt);
nTpts = size(y,1);
tHRF = (1*nPre*dt:dt:nPost*dt)';
ntHRF=length(tHRF);    
nT=length(t);
nTdec = length(t(1:nDec:end));


% find corresponding short separation channel for every channel
ml = SD.MeasList;
mlAct = SD.MeasListAct;
lst = find(ml(:,4)==1);
rhoSD = zeros(length(lst),1);
posM = zeros(length(lst),3);
for iML = 1:length(lst)
    rhoSD(iML) = sum((SD.SrcPos(ml(lst(iML),1),:) - SD.DetPos(ml(lst(iML),2),:)).^2).^0.5;
    posM(iML,:) = (SD.SrcPos(ml(lst(iML),1),:) + SD.DetPos(ml(lst(iML),2),:)) / 2;
end
lstSS = lst(find(rhoSD<=rhoSD_ssThresh & mlAct(lst)==1));

if isempty(lstSS)
    display(sprintf('There are no short separation channels in this probe...performing regular deconvolution.'));
    [yavg, yavgstd, tHRF, nTrials, ynew, yresid, ysum2] = ...
        hmrDeconvTB_3rd(y, s, t, Aaux, trange, gstd, gms);
    return;
end

for iML = 1:length(lst)
    rho = sum((ones(length(lstSS),1)*posM(iML,:) - posM(lstSS,:)).^2,2).^0.5;
    [foo,ii] = min(rho);
    iNearestSS(iML) = lstSS(ii);
end
mlSSlst = unique(iNearestSS);


%prune good stim if temporal basis exceeds t
nCond = size(s,2);
onset=zeros(nT,nCond);
for iCond = 1:nCond
    lstT=find(s(:,iCond)==1);
    lstp=find((lstT+nPre)>=1 & (lstT+nPost)<=nTpts);
    lst=lstT(lstp);
    nTrials(iCond)=length(lst);
    onset(lst+nPre,iCond)=1;
end

%temporal basis function (gaussian with std of .5 sec and their 
%means are separated by .5 sec)
%gstd=1; %std of 0.5 sec
%gms=1; %mean separated by 0.5 sec

%basis function and timing
nB=floor((trange(2)-trange(1))/gms)-1;
tbasis=zeros(ntHRF,nB);
for b=1:nB
    tbasis(:,b)=exp(-(tHRF-(trange(1)+b*gms)).^2/(2*gstd.^2));
    tbasis(:,b)=tbasis(:,b)./max(tbasis(:,b)); %normalize to 1
end

%construct design matrix    
dA=zeros(nTdec,nB*nCond);
iC = 0;
nCondRem = 0;
for iCond=1:nCond
    if nTrials(iCond)>0
        for b=1:nB
            iC = iC + 1;
            clmn=conv(onset(:,iCond),tbasis(:,b));
            clmn=clmn(1:nDec:nT);
            dA(:,iC)=clmn;
        end
    else
        nCondRem = nCondRem + 1;
    end
end
lstCond = find(nTrials>0);
nCond2 = nCond - nCondRem;
dA(:,(iC+1):end) = [];

%expand design matrix with 3rd polynomial
x0=ones(nTdec,1);
x1=(1:nTdec)';
x2=x1.*x1;
x3=x2.*x1;

%rescale polynomial to avoid bad conditionning
x1=x1./x1(end);
x2=x2./x2(end);
x3=x3./x3(end);

%expand design matrix with Aaux
nAux = size(Aaux,2);

% final design matrix
A=[dA x0 x1 x2 x3 Aaux]; 


% deconvolve

if ndims(y)==3
    %%%%%%%%%%%%%%%%
    % Concentration
    %%%%%%%%%%%%%%%%

    nCh = size(y,3);
    y = y(1:nDec:end,:,:); % decimate y to match A
    
    
    tb=zeros(nB,nCh,2,nCond);
    b=zeros(5+nAux,nCh,2);
    yavg=zeros(ntHRF,nCh,3,nCond);
    yavgstd=zeros(ntHRF,nCh,3,nCond);
    ysum2=zeros(ntHRF,nCh,3,nCond);
    foo=zeros(nB*nCond2+5+nAux,nCh,2); % 5 extra for 3rd order drift (4) + short separation regression (1)
    ynew = zeros(size(y));
    yresid = zeros(size(y));
    for conc=1:2 %only HbO and HbR
        
        % loop over short separation groups
        for iSS = 1:length(mlSSlst)
            
            lstML = find(iNearestSS==mlSSlst(iSS));
            Ass = y(:,conc,mlSSlst(iSS));
            At = [A Ass];
            
            %tcheck if the matrix is well conditionned
            ATA=At'*At;
            rco=rcond(full(ATA));
            if rco<10^-14 && rco>10^-25
                display(sprintf('Design matrix is poorly scaled...(RCond = %e)', rco))
            elseif rco<10^-25
                display(sprintf('Design matrix is VERY poorly scaled...(RCond = %e, cannot perform computation)', rco))
                return
            end
            
            %compute pseudo-inverse
            pinvA=ATA\At';
            
            %deconvolve
            foo(:,lstML,conc)=pinvA*squeeze(y(:,conc,lstML));
            b(:,lstML,conc)=foo(nB*nCond2+1:end,lstML,conc);
            for iCond=1:nCond2
                tb(:,lstML,conc,lstCond(iCond))=foo([1:nB]+(iCond-1)*nB,lstML,conc);
                yavg(:,lstML,conc,lstCond(iCond))=tbasis*tb(:,lstML,conc,lstCond(iCond));
            end
            
            % reconstruct y and yresid (y is obtained just from the HRF)
            yresid(:,conc,lstML) = y(:,conc,lstML) - permute(At*foo(:,lstML,conc),[1 3 2]);
            ynew(:,conc,lstML) = permute(dA*foo(1:(nB*nCond2),lstML,conc),[1 3 2]) + yresid(:,conc,lstML);
            
            %get error
            pAinvAinvD = diag(pinvA*pinvA');
            yest(:,lstML,conc) = At * foo(:,lstML,conc);
            yvar(1,lstML,conc) = std(squeeze(y(:,conc,lstML))-yest(:,lstML,conc),[],1).^2; % check this against eq(53) in Ye2009
            for iCh = 1:length(lstML)
                bvar(:,lstML(iCh),conc) = yvar(1,lstML(iCh),conc) * pAinvAinvD;
                for iCond=1:nCond2
                    yavgstd(:,lstML(iCh),conc,lstCond(iCond)) = diag(tbasis*diag(bvar([1:nB]+(iCond-1)*nB,lstML(iCh),conc))*tbasis').^0.5;
                    ysum2(:,lstML(iCh),conc,lstCond(iCond)) = yavgstd(:,lstML(iCh),conc,lstCond(iCond)).^2 + nTrials(lstCond(iCond))*yavg(:,lstML(iCh),conc,lstCond(iCond)).^2;
                end
            end
            
        end % end loop on short separation groups
    end
    
    yavg(:,:,3,:) = yavg(:,:,1,:) + yavg(:,:,2,:);
    yavg = permute(yavg,[1 3 2 4]);
    
    yavgstd(:,:,3,:) = yavgstd(:,:,1,:) + yavgstd(:,:,2,:);
    yavgstd = permute(yavgstd,[1 3 2 4]);
    
    ysum2(:,:,3,:) = ysum2(:,:,1,:) + ysum2(:,:,2,:);
    ysum2 = permute(ysum2,[1 3 2 4]);
    
    yresid(:,3,:) = yresid(:,1,:) + yresid(:,2,:);
    ynew(:,3,:) = ynew(:,1,:) + ynew(:,2,:);
    
    
    if nPre<0
        for iConc = 1:size(yavg,2)
            for iCh = 1:size(yavg,3)
                for iCond = 1:size(yavg,4)
                    yavg(:,iConc,iCh,iCond) = yavg(:,iConc,iCh,iCond) - ones(size(yavg,1),1)*mean(yavg(1:(-nPre),iConc,iCh,iCond),1);
                end
            end
        end
    end


else
    %%%%%%%%%%%%%%%%%%%%%%
    % dod
    %%%%%%%%%%%%%%%%%%%%%%
    
    nCh = size(y,2);
    nWav = length(SD.Lambda);
    
    y = y(1:nDec:end,:); % decimate y to match A
    
    
    tb=zeros(nB,nCh,nCond);
    b=zeros(5+nAux,nCh);
    yavg=zeros(ntHRF,nCh,nCond);
    yavgstd=zeros(ntHRF,nCh,nCond);
    ysum2=zeros(ntHRF,nCh,nCond);
    foo=zeros(nB*nCond2+5+nAux,nCh); % 5 extra for 3rd order drift (4) + short separation regression (1)
    ynew = zeros(size(y));
    yresid = zeros(size(y));
    for iWav=1:nWav 
        
        % loop over short separation groups
        for iSS = 1:length(mlSSlst)
            
            lstMLtmp = find(iNearestSS==mlSSlst(iSS));
            lstML = [];
            for ii=1:length(lstMLtmp)
                lstML(ii) = find(SD.MeasList(:,1)==SD.MeasList(lstMLtmp(ii),1) & SD.MeasList(:,2)==SD.MeasList(lstMLtmp(ii),2) & SD.MeasList(:,4)==iWav);
            end
            ssIdx = find(SD.MeasList(:,1)==SD.MeasList(mlSSlst(iSS),1) & SD.MeasList(:,2)==SD.MeasList(mlSSlst(iSS),2) & SD.MeasList(:,4)==iWav);
            
            Ass = y(:,ssIdx);
            At = [A Ass];
            
            %tcheck if the matrix is well conditionned
            ATA=At'*At;
            rco=rcond(full(ATA));
            if rco<10^-14 && rco>10^-25
                display(sprintf('Design matrix is poorly scaled...(RCond = %e)', rco))
            elseif rco<10^-25
                display(sprintf('Design matrix is VERY poorly scaled...(RCond = %e, cannot perform computation)', rco))
                return
            end
            
            %compute pseudo-inverse
            pinvA=ATA\At';
            
            %deconvolve
            foo(:,lstML)=pinvA*squeeze(y(:,lstML));
            b(:,lstML)=foo(nB*nCond2+1:end,lstML);
            for iCond=1:nCond2
                tb(:,lstML,lstCond(iCond))=foo([1:nB]+(iCond-1)*nB,lstML);
                yavg(:,lstML,lstCond(iCond))=tbasis*tb(:,lstML,lstCond(iCond));
            end
            
            % reconstruct y and yresid (y is obtained just from the HRF)
            yresid(:,lstML) = y(:,lstML) - At*foo(:,lstML);
            ynew(:,lstML) = dA*foo(1:(nB*nCond2),lstML) + yresid(:,lstML);
            
            
            %get error
            pAinvAinvD = diag(pinvA*pinvA');
            yest(:,lstML) = At * foo(:,lstML);
            yvar(1,lstML) = std(squeeze(y(:,lstML))-yest(:,lstML),[],1).^2; % check this against eq(53) in Ye2009
            for iCh = 1:length(lstML)
                bvar(:,lstML(iCh)) = yvar(1,lstML(iCh)) * pAinvAinvD;
                for iCond=1:nCond2
                    yavgstd(:,lstML(iCh),lstCond(iCond)) = diag(tbasis*diag(bvar([1:nB]+(iCond-1)*nB,lstML(iCh)))*tbasis').^0.5;
                    ysum2(:,lstML(iCh),lstCond(iCond)) = yavgstd(:,lstML(iCh),lstCond(iCond)).^2 + nTrials(lstCond(iCond))*yavg(:,lstML(iCh),lstCond(iCond)).^2;
                end
            end
            
        end % end loop on short separation groups
    end
    
    
    if nPre<0
        for iCh = 1:size(yavg,3)
            for iCond = 1:size(yavg,4)
                yavg(:,iCh,iCond) = yavg(:,iCh,iCond) - ones(size(yavg,1),1)*mean(yavg(1:(-nPre),iCh,iCond),1);
            end
        end
    end

end

return


