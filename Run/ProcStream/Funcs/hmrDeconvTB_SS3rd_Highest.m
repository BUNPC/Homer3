% [yavg, yavgstd, tHRF, nTrials, ysum2] = hmrDeconvTB_SS3rd_Highest(y, s, t, SD, cc, Aaux, trange, gstd, gms, rhoSD_ssThresh)
%
% UI NAME:  
% Block_Avg_Short_Sep_Highest  
% This script estimates the HRF with a set a temporal basis without any  
% preprocessing but uses a 3rd order polynomial regressor. Also it finds short separations with highest correlation.  
% INPUTS:  
% y: this is the data wavelength #time points x #channels 
% concentration data is #time points x [HbO/HbR/HbT] x #channels  
% s: stimulation vector (# time points x #conditions)=1 at stim onset otherwise =0  
% t: time vector corresponding with y and s .
% SD: source detector stucture (units should be consistent with rhoSD_ssThresh)  
% trange: defines the range for the block average [tPre tPost]  
% gstd: std for gaussian shape temporal basis function (sec)  
% gms: mean for gaussian shape temporal basis function (sec)  
% rhoSD_ssThresh: max distance for a short separation measurement (cm)  
% OUTPUTS:  
% yavg: the averaged results  
% ystd: the standard deviation across trials  
% tHRF: the time vector  
% nTrials: the number of trials averaged for each condition 
% LOG 
% created 1-14-2011 L. Gagnon

function [yavg, yavgstd, tHRF, nTrials, ysum2] = hmrDeconvTB_SS3rd_Highest(y, s, t, SD, cc, Aaux, trange, gstd, gms, rhoSD_ssThresh)


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


% find short separation channels
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
    [yavg, yavgstd, tHRF, nTrials, ysum2] = ...
        hmrDeconvTB_3rd(y, s, t, Aaux, trange, gstd, gms);
    return;
end

% find short separation channel with highest correlation
for iML = 1:length(lst)
    % HbO
    [foo,ii] = max(cc(iML,lstSS,1));
    iNearestSS(iML,1) = lstSS(ii);
    % HbR
    [foo,ii] = max(cc(iML,lstSS,2));
    iNearestSS(iML,2) = lstSS(ii);
end


%prune good stim
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
for iCond=1:nCond
    for b=1:nB
        iC = iC + 1;
        clmn=conv(onset(:,iCond),tbasis(:,b));
        clmn=clmn(1:nDec:nT);
        dA(:,iC)=clmn;
    end
end

%expand design matrix with 3rd polynomial
x0=ones(nTdec,1);
x1=(1:nTdec)';
x2=x1.*x1;
x3=x2.*x1;

%rescale polynomial to avoid bad conditionning
x1=x1./x1(end);
x2=x2./x2(end);
x3=x3./x3(end);
A=[dA x0 x1 x2 x3]; 


% deconvolve
nCh = size(y,3);

y = y(1:nDec:end,:,:); % decimate y to match A

tb=zeros(nB,nCh,2,nCond);
b=zeros(5,nCh,2);
yavg=zeros(ntHRF,3,nCh,nCond);
yavgstd=zeros(ntHRF,3,nCh,nCond);
ysum2=zeros(ntHRF,3,nCh,nCond);
foo=zeros(nB*nCond+5,nCh,2); % 5 extra for 3rd order drift (4) + short separation regression (1)
for conc=1:2 %only HbO and HbR

    % loop over short separation groups
    mlSSlst = unique(iNearestSS(:,conc));
    for iSS = 1:length(mlSSlst)
        
        lstML = find(iNearestSS(:,conc)==mlSSlst(iSS));
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
        b(:,lstML,conc)=foo(nB*nCond+1:end,lstML,conc);
        for iCond=1:nCond
            tb(:,lstML,conc,iCond)=foo([1:nB]+(iCond-1)*nB,lstML,conc);
            yavg(:,lstML,conc,iCond)=tbasis*tb(:,lstML,conc,iCond);
        end
        
        %get error
        pAinvAinvD = diag(pinvA*pinvA');
        yest(:,lstML,conc) = At * foo(:,lstML,conc);
        yvar(1,lstML,conc) = std(squeeze(y(:,conc,lstML))-yest(:,lstML,conc),[],1).^2; % check this against eq(53) in Ye2009
        for iCh = 1:length(lstML)
            bvar(:,lstML(iCh),conc) = yvar(1,lstML(iCh),conc) * pAinvAinvD;
            for iCond=1:nCond
                yavgstd(:,lstML(iCh),conc,iCond) = diag(tbasis*diag(bvar([1:nB]+(iCond-1)*nB,lstML(iCh),conc))*tbasis').^0.5;
                ysum2(:,lstML(iCh),conc,iCond) = yavgstd(:,lstML(iCh),conc,iCond).^2 + nTrials(iCond)*yavg(:,lstML(iCh),conc,iCond).^2;
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


if nPre<0
    for iConc = 1:size(yavg,2)
        for iCh = 1:size(yavg,3)
            for iCond = 1:size(yavg,4)
                yavg(:,iConc,iCh,iCond) = yavg(:,iConc,iCh,iCond) - ones(size(yavg,1),1)*mean(yavg(1:(-nPre),iConc,iCh,iCond),1);
            end
        end
    end
end


return


