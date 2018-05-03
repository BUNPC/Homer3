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

function [yavg, yavgstd, tHRF, nTrials, ynew, yresid, ysum2] = hmrDeconvTB_3rd(y, s, t, Aaux, trange, gstd, gms)


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

%expand design matrix with Aaux
nAux = size(Aaux,2);
 
%rescale polynomial to avoid bad conditionning
x1=x1./x1(end);
x2=x2./x2(end);
x3=x3./x3(end);

%final design matrix
A=[dA x0 x1 x2 x3 Aaux]; 


% deconvolve

if ndims(y)==3
    %%%%%%%%%%%%%%%%
    % Concentration
    %%%%%%%%%%%%%%%%

    nCh = size(y,3);
    y = y(1:nDec:end,:,:); % decimate y to match A
    
    tb=zeros(nB,nCh,2,nCond);
    b=zeros(4+nAux,nCh,2);
    yavg=zeros(ntHRF,nCh,3,nCond);
    yavgstd=zeros(ntHRF,nCh,3,nCond);
    ysum2=zeros(ntHRF,nCh,3,nCond);
    foo=zeros(nB*nCond2+4+nAux,nCh,2); % 5 extra for 3rd order drift (4) 
    ynew = zeros(size(y));
    yresid = zeros(size(y));
    for conc=1:2 %only HbO and HbR
        
            At = [A];
            
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
            foo(:,:,conc)=pinvA*squeeze(y(:,conc,:));
            b(:,:,conc)=foo(nB*nCond2+1:end,:,conc);
            for iCond=1:nCond2
                tb(:,:,conc,lstCond(iCond))=foo([1:nB]+(iCond-1)*nB,:,conc);
                yavg(:,:,conc,lstCond(iCond))=tbasis*tb(:,:,conc,lstCond(iCond));
            end
            
            % reconstruct y and yresid (y is obtained just from the HRF)
            yresid(:,conc,:) = y(:,conc,:) - permute(At*foo(:,:,conc),[1 3 2]);
            ynew(:,conc,:) = permute(dA*foo(1:(nB*nCond2),:,conc),[1 3 2]) + yresid(:,conc,:);
            
            %get error
            pAinvAinvD = diag(pinvA*pinvA');
            yest(:,:,conc) = At * foo(:,:,conc);
            yvar(1,:,conc) = std(squeeze(y(:,conc,:))-yest(:,:,conc),[],1).^2; % check this against eq(53) in Ye2009
            for iCh = 1:size(yvar,2)
                bvar(:,iCh,conc) = yvar(1,iCh,conc) * pAinvAinvD;
                for iCond=1:nCond2
                    yavgstd(:,iCh,conc,lstCond(iCond)) = diag(tbasis*diag(bvar([1:nB]+(iCond-1)*nB,iCh,conc))*tbasis').^0.5;
                    ysum2(:,iCh,conc,lstCond(iCond)) = yavgstd(:,iCh,conc,lstCond(iCond)).^2 + nTrials(lstCond(iCond))*yavg(:,iCh,conc,lstCond(iCond)).^2;
                end
            end
            

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
    
    y = y(1:nDec:end,:); % decimate y to match A
    
    
    tb=zeros(nB,nCh,nCond);
    b=zeros(4+nAux,nCh);
    yavg=zeros(ntHRF,nCh,nCond);
    yavgstd=zeros(ntHRF,nCh,nCond);
    ysum2=zeros(ntHRF,nCh,nCond);
    foo=zeros(nB*nCond2+4+nAux,nCh); % 5 extra for 3rd order drift (4) 
    ynew = zeros(size(y));
    yresid = zeros(size(y));
        
            At = [A];
            
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
            foo(:,:)=pinvA*squeeze(y(:,:));
            b(:,:)=foo(nB*nCond2+1:end,:);
            for iCond=1:nCond2
                tb(:,:,lstCond(iCond))=foo([1:nB]+(iCond-1)*nB,:);
                yavg(:,:,lstCond(iCond))=tbasis*tb(:,:,lstCond(iCond));
            end
            
            % reconstruct y and yresid (y is obtained just from the HRF)
            yresid(:,:) = y(:,:) - At*foo(:,:);
            ynew(:,:) = dA*foo(1:(nB*nCond2),:) + yresid(:,:);
            
            
            %get error
            pAinvAinvD = diag(pinvA*pinvA');
            yest(:,:) = At * foo(:,:);
            yvar(1,:) = std(squeeze(y(:,:))-yest(:,:),[],1).^2; % check this against eq(53) in Ye2009
            for iCh = 1:size(yvar,2)
                bvar(:,iCh) = yvar(1,iCh) * pAinvAinvD;
                for iCond=1:nCond2
                    yavgstd(:,iCh,lstCond(iCond)) = diag(tbasis*diag(bvar([1:nB]+(iCond-1)*nB,iCh))*tbasis').^0.5;
                    ysum2(:,iCh,lstCond(iCond)) = yavgstd(:,iCh,lstCond(iCond)).^2 + nTrials(lstCond(iCond))*yavg(:,iCh,lstCond(iCond)).^2;
                end
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



% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% dt = t(2)-t(1);
% nPre = round(trange(1)/dt);
% nPost = round(trange(2)/dt);
% nTpts = size(y,1);
% tHRF = (1*nPre*dt:dt:nPost*dt)';
% ntHRF=length(tHRF);
% nT=length(t);
% 
% %prune good stim
% nCond = size(s,2);
% onset=zeros(nT,nCond);
% for iCond = 1:nCond
%     lstT=find(s(:,iCond)==1);
%     lstp=find((lstT+nPre)>=1 & (lstT+nPost)<=nTpts);
%     lst=lstT(lstp);
%     nTrials(iCond)=length(lst);
%     onset(lst+nPre,iCond)=1;
% end
% 
% %temporal basis function (gaussian with std of .5 sec and their
% %means are separated by .5 sec)
% %gstd=1; %std of 0.5 sec
% %gms=1; %mean separated by 0.5 sec
% 
% %basis function and timing
% nB=floor((trange(2)-trange(1))/gms)-1;
% tbasis=zeros(ntHRF,nB);
% for b=1:nB
%     tbasis(:,b)=exp(-(tHRF-(trange(1)+b*gms)).^2/(2*gstd.^2));
%     tbasis(:,b)=tbasis(:,b)./max(tbasis(:,b)); %normalize to 1
% end
% 
% %construct design matrix
% dA=zeros(nT,nB*nCond);
% iC = 0;
% for iCond=1:nCond
%     for b=1:nB
%         iC = iC + 1;
%         clmn=conv(onset(:,iCond),tbasis(:,b));
%         clmn=clmn(1:nT);
%         dA(:,iC)=clmn;
%     end
% end
% 
% %expand design matrix with 3rd polynomial
% x0=ones(nT,1);
% x1=(1:nT)';
% x2=x1.*x1;
% x3=x2.*x1;
% 
% %rescale polynomial to avoid bad conditionning
% x1=x1./x1(end);
% x2=x2./x2(end);
% x3=x3./x3(end);
% 
% %expand design matrix with Aaux
% nAux = size(Aaux,2);
% 
% %final design matrix
% A=[dA x0 x1 x2 x3 Aaux];
% 
% nCh = size(y,3);
% 
% % SOLVE
% tb=zeros(nB,nCh,2,nCond);
% b=zeros(4+nAux,nCh,2);
% yavg=zeros(ntHRF,nCh,3,nCond);
% yavgstd=zeros(ntHRF,nCh,3,nCond);
% ysum2=zeros(ntHRF,nCh,3,nCond);
% foo=zeros(nB*nCond+4+nAux,nCh,2); % 4 extra for 3rd order drift + nAux
% for conc=1:2 %only HbO and HbR
%     
%     %tcheck if the matrix is well conditionned
%     ATA=A'*A;
%     rco=rcond(full(ATA));
%     if rco<10^-14 && rco>10^-25
%         display(sprintf('Design matrix is poorly scaled...(RCond=%e)', rco))
%     elseif rco<10^-25
%         display(sprintf('Design matrix is VERY poorly scaled...(RCond=%e), cannot perform computation', rco))
%         yavg = permute(yavg,[1 3 2 4]);
%         yavgstd = permute(yavgstd,[1 3 2 4]);
%         ysum2 = permute(ysum2,[1 3 2 4]);
%         return
%     end
%     
%     %compute pseudo-inverse
%     pinvA=ATA\A';
%     
%     %deconvolve
%     foo(:,:,conc)=pinvA*squeeze(y(:,conc,:));
%     b(:,:,conc)=foo(nB*nCond+1:end,:,conc);
%     for iCond=1:nCond
%         tb(:,:,conc,iCond)=foo([1:nB]+(iCond-1)*nB,:,conc);
%         yavg(:,:,conc,iCond)=tbasis*tb(:,:,conc,iCond);
%     end
%     
%     %get error
%     pAinvAinvD = diag(pinvA*pinvA');
%     yest(:,:,conc) = A * foo(:,:,conc);
%     yvar(1,:,conc) = std(squeeze(y(:,conc,:))-yest(:,:,conc),[],1).^2; % check this against eq(53) in Ye2009
%     for iCh = 1:nCh
%         bvar(:,iCh,conc) = yvar(1,iCh,conc) * pAinvAinvD;
%         for iCond=1:nCond
%             yavgstd(:,iCh,conc,iCond) = diag(tbasis*diag(bvar([1:nB]+(iCond-1)*nB,iCh,conc))*tbasis').^0.5;
%             ysum2(:,iCh,conc,iCond) = yavgstd(:,iCh,conc,iCond).^2 + nTrials(iCond)*yavg(:,iCh,conc,iCond).^2;
%         end
%     end
%     
% end
% 
% yavg(:,:,3,:) = yavg(:,:,1,:) + yavg(:,:,2,:);
% yavg = permute(yavg,[1 3 2 4]);
% 
% yavgstd(:,:,3,:) = yavgstd(:,:,1,:) + yavgstd(:,:,2,:);
% yavgstd = permute(yavgstd,[1 3 2 4]);
% 
% ysum2(:,:,3,:) = ysum2(:,:,1,:) + ysum2(:,:,2,:);
% ysum2 = permute(ysum2,[1 3 2 4]);
% 
% 
% if nPre<0
%     for iConc = 1:size(yavg,2)
%         for iCh = 1:size(yavg,3)
%             for iCond = 1:size(yavg,4)
%                 yavg(:,iConc,iCh,iCond) = yavg(:,iConc,iCh,iCond) - ones(size(yavg,1),1)*mean(yavg(1:(-nPre),iConc,iCh,iCond),1);
%             end
%         end
%     end
% end
% 
% 
% return
% 

