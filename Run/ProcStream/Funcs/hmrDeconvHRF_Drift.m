% [yavg, yavgstd, tHRF, nTrials, ysum2] = hmrDeconvTB_3rd(y, s, t, Aaux, trange, gstd, gms)
%
% UI NAME: 
% GLM_HRF_Drift
%
% This script estimates the HRF with a set a temporal basis without any
% preprocessing but uses a 3rd order polynomial drift regressor
%
% LOG:
% created 1-14-2011 L. Gagnon

function [yavg, yavgstd, tHRF, nTrials, ynew, yresid, ysum2] = hmrDeconvHRF_Drift(y, s, t, Aaux, tIncAuto, trange, idxBasis, paramsBasis, driftOrder, flagMotionCorrect )


dt = t(2)-t(1);
nPre = round(trange(1)/dt);
nPost = round(trange(2)/dt);
nTpts = size(y,1);
tHRF = (1*nPre*dt:dt:nPost*dt)';
ntHRF=length(tHRF);    
nT=length(t);

%%%%%%%%%%%%%%%%
%prune good stim
%%%%%%%%%%%%%%%%
nCond = size(s,2);
onset=zeros(nT,nCond);
for iCond = 1:nCond
    lstT=find(s(:,iCond)==1);
    lstp=find((lstT+nPre)>=1 & (lstT+nPost)<=nTpts);
    lst=lstT(lstp);
    nTrials(iCond)=length(lst);
    onset(lst+nPre,iCond)=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construct the basis functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if idxBasis==1
    % Gaussians
    gms = paramsBasis(1);
    gstd = paramsBasis(2);
    
    nB=floor((trange(2)-trange(1))/gms)-1;
    tbasis=zeros(ntHRF,nB);
    for b=1:nB
        tbasis(:,b)=exp(-(tHRF-(trange(1)+b*gms)).^2/(2*gstd.^2));
        tbasis(:,b)=tbasis(:,b)./max(tbasis(:,b)); %normalize to 1
    end

elseif idxBasis==2
    % Modified Gamma 
    if length(paramsBasis)==3
        nConc = 1;
    elseif length(paramsBasis)==6
        nConc = 2;
    end

    nB = 1;
    tbasis=zeros(ntHRF,nB,nConc);    
    for iConc = 1:nConc
        tau = paramsBasis((iConc-1)*3+1);
        sigma = paramsBasis((iConc-1)*3+2);
        T = paramsBasis((iConc-1)*3+3);
        
        tbasis(:,1,iConc) = (exp(1)*(tHRF-tau).^2/sigma^2) .* exp( -(tHRF-tau).^2/sigma^2 );
        
        if tHRF(1)<tau
            tbasis(1:round((tau-tHRF(1))/dt),1,iConc) = 0;
        end
        
        for ii=1:nB
            foo = conv(tbasis(:,ii,iConc),ones(round(T/dt),1)) / round(T/dt);
            tbasis(:,ii,iConc) = foo(1:ntHRF,1);
        end
    end
    
elseif idxBasis==3
    % Modified Gamma and Derivative
    tau = paramsBasis(1);
    sigma = paramsBasis(2);
    T = paramsBasis(3);
    
    nB = 2;
    tbasis=zeros(ntHRF,nB);    
    tbasis(:,1) = (exp(1)*(tHRF-tau).^2/sigma^2) .* exp( -(tHRF-tau).^2/sigma^2 );
    tbasis(:,2) = 2*exp(1)*( (tHRF-tau)/sigma^2 - (tHRF-tau).^3/sigma^4 ) .* exp( -(tHRF-tau).^2/sigma^2 );
    
    if tHRF(1)<tau
        tbasis(1:round((tau-tHRF(1))/dt),1:2) = 0;
    end
    
    for ii=1:nB
        foo = conv(tbasis(:,ii),ones(round(T/dt),1)) / round(T/dt);
        tbasis(:,ii) = foo(1:ntHRF,1);
    end
    
end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construct design matrix    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dA=zeros(nT,nB*nCond,2);
for iConc = 1:2
    iC = 0;
    for iCond=1:nCond
        for b=1:nB
            iC = iC + 1;
            if size(tbasis,3)==1
                clmn=conv(onset(:,iCond),tbasis(:,b));
            else
                clmn=conv(onset(:,iCond),tbasis(:,b,iConc));
            end
            clmn=clmn(1:nT);
            dA(:,iC,iConc)=clmn;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%expand design matrix nth order polynomial for drift correction
%rescale polynomial to avoid bad conditionning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xDrift = ones(nT,driftOrder);
for ii=2:(driftOrder+1)
    xDrift(:,ii) = ([1:nT]').^(ii-1);
    xDrift(:,ii) = xDrift(:,ii) / xDrift(end,ii);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%expand design matrix with Aaux
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAux = size(Aaux,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%expand design matrix for Motion Correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flagMotionCorrect==1
    idxMA = find(diff(tIncAuto)==1);  % number of motion artifacts
    if isempty(idxMA)
        nMC = 0;
        Amotion = [];
    else
        nMA = length(idxMA);
        nMC = nMA+1;
        Amotion = zeros(nT,nMC);
        Amotion(1:idxMA(1),1) = 1;
        for ii=2:nMA
            Amotion((idxMA(ii-1)+1):idxMA(ii),ii) = 1;
        end
        Amotion((idxMA(nMA)+1):end,end) = 1;
    end
    
%    lstInc = find(tIncAuto==1);
else
    nMC = 0;
    Amotion = [];
%    lstInc = [1:nT]';
end

lstInc = find(tIncAuto==1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%final design matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iConc=1:2
    A(:,:,iConc)=[dA(:,:,iConc) xDrift Aaux Amotion]; 
end

nCh = size(y,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOLVE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tb=zeros(nB,nCh,2,nCond);
%b=zeros(driftOrder+1+nAux,nCh,2);
yavg=zeros(ntHRF,nCh,3,nCond);
yavgstd=zeros(ntHRF,nCh,3,nCond);
ysum2=zeros(ntHRF,nCh,3,nCond);
yresid=zeros(nT,nCh,3);
ynew=zeros(nT,nCh,3);
foo=zeros(nB*nCond+driftOrder+1+nAux+nMC,nCh,2); % 4 extra for 3rd order drift + nAux
for conc=1:2 %only HbO and HbR

    %tcheck if the matrix is well conditionned
    ATA=A(lstInc,:,conc)'*A(lstInc,:,conc);
    rco=rcond(full(ATA));
    if rco<10^-14 && rco>10^-25
        display(sprintf('Design matrix is poorly scaled...(RCond=%e)', rco))
    elseif rco<10^-25
        display(sprintf('Design matrix is VERY poorly scaled...(RCond=%e), cannot perform computation', rco))
        yavg = permute(yavg,[1 3 2 4]);
        yavgstd = permute(yavgstd,[1 3 2 4]);
        ysum2 = permute(ysum2,[1 3 2 4]);        
        return
    end

    %compute pseudo-inverse
    pinvA=ATA\A(lstInc,:,conc)';

    %deconvolve
    foo(:,:,conc)=pinvA*squeeze(y(lstInc,conc,:));
%    b(:,:,conc)=foo(nB*nCond+1:end,:,conc);
    for iCond=1:nCond
        tb(:,:,conc,iCond)=foo([1:nB]+(iCond-1)*nB,:,conc);
        if size(tbasis,3)==1
            yavg(:,:,conc,iCond)=tbasis*tb(:,:,conc,iCond);
        else
            yavg(:,:,conc,iCond)=tbasis(:,:,conc)*tb(:,:,conc,iCond);
        end
    end
    
    % construct ynew and yresid
    yresid(lstInc,:,conc) = squeeze(y(lstInc,conc,:)) - A(lstInc,:,conc)*foo(:,:,conc);
    ynew(lstInc,:,conc) = dA(lstInc,:,conc)*foo(1:(nB*nCond),:,conc) + yresid(lstInc,:,conc);
    
    %get error
    pAinvAinvD = diag(pinvA*pinvA');
    yest(:,:,conc) = A(:,:,conc) * foo(:,:,conc);
    yvar(1,:,conc) = std(squeeze(y(:,conc,:))-yest(:,:,conc),[],1).^2; % check this against eq(53) in Ye2009
    for iCh = 1:nCh
        bvar(:,iCh,conc) = yvar(1,iCh,conc) * pAinvAinvD;
        for iCond=1:nCond
            if size(tbasis,3)==1
                yavgstd(:,iCh,conc,iCond) = diag(tbasis*diag(bvar([1:nB]+(iCond-1)*nB,iCh,conc))*tbasis').^0.5;
            else
                yavgstd(:,iCh,conc,iCond) = diag(tbasis(:,:,conc)*diag(bvar([1:nB]+(iCond-1)*nB,iCh,conc))*tbasis(:,:,conc)').^0.5;
            end
            ysum2(:,iCh,conc,iCond) = yavgstd(:,iCh,conc,iCond).^2 + nTrials(iCond)*yavg(:,iCh,conc,iCond).^2;
        end
    end
    
end

yavg(:,:,3,:) = yavg(:,:,1,:) + yavg(:,:,2,:);
yavg = permute(yavg,[1 3 2 4]);

yavgstd(:,:,3,:) = yavgstd(:,:,1,:) + yavgstd(:,:,2,:);
yavgstd = permute(yavgstd,[1 3 2 4]);

ysum2(:,:,3,:) = ysum2(:,:,1,:) + ysum2(:,:,2,:);
ysum2 = permute(ysum2,[1 3 2 4]);

yresid(:,:,3) = yresid(:,:,1) + yresid(:,:,2);
yresid = permute(yresid,[1 3 2]);

ynew(:,:,3) = ynew(:,:,1) + ynew(:,:,2);
ynew = permute(ynew,[1 3 2]);


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


