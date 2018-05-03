% [dc,iNearestSS] = enAdaptiveFilteringSS(SD,t,dc,M,mu)
% 
% UI NAME:
% Adaptive_Filtering_ShortSep
%
%
%

function [dc,iNearestSS] = enAdaptiveFilteringSS(SD,t,dc,M,mu)

%iNearestSS = 0;
%return

%mu = 1e-4; %same as Quan
%M = 1; %Quan uses 100 

rhoSD_ssThresh = 1.5; % short separation threshold




dc(:,3,:) = [];

nT = length(t);
nCh = size(dc,3);

ml = SD.MeasList;


% find corresponding short separation channel for every channel
lst = find(ml(:,4)==1);
rhoSD = zeros(length(lst),1);
posM = zeros(length(lst),3);
for iML = 1:length(lst)
    rhoSD(iML) = sum((SD.SrcPos(ml(lst(iML),1),:) - SD.DetPos(ml(lst(iML),2),:)).^2).^0.5;
    posM(iML,:) = (SD.SrcPos(ml(lst(iML),1),:) + SD.DetPos(ml(lst(iML),2),:)) / 2;
end
lstSS = lst(find(rhoSD<=rhoSD_ssThresh));

for iML = 1:length(lst)
    rho = sum((ones(length(lstSS),1)*posM(iML,:) - posM(lstSS,:)).^2,2).^0.5;
    [foo,ii] = min(rho);
    iNearestSS(iML) = lstSS(ii);
end

if M==0
    return
end

% whiten the data
sc = std(dc,[],1);
for iCh = 1:nCh
    dc(:,:,iCh) = dc(:,:,iCh) ./ (ones(nT,1)*sc(:,:,iCh));
end

x = dc(:,:,iNearestSS);
x = permute(x,[2 3 1]);
stdX = std(x,[],3);
%stdX(1) = std(x(:,1));
%stdX(2) = std(x(:,2));

w = zeros(2,nCh,nT+1,M);
es = zeros(2,nCh,nT);  % superficial signal
for iH = 1:2
    for iCh = 1:nCh
        w(iH,iCh,1:M,1) = std(dc(:,iH,iCh)) / stdX(iH,iCh);
    end
end

% filter
dc = permute(dc,[2 3 1]);
e = zeros(2,nCh,nT);
for iT = M:nT
    e(:,:,iT) = dc(:,:,iT);
    for iM = 1:M
        es(:,:,iT) = es(:,:,iT) + w(:,:,iT,iM).*x(:,:,iT-iM+1);%  (x(:,1,iT-iM+1)*ones(1,nCh));
    end
    e(:,:,iT) = e(:,:,iT) - es(:,:,iT);
    for iM = 1:M
        w(:,:,iT+1,iM) = w(:,:,iT,iM) + 2*mu*e(:,:,iT).*x(:,:,iT-iM+1);%  (x(:,1,iT-iM+1)*ones(1,nCh));
    end
end
%dc = permute(dc,[3 1 2]);
%x = permute(x,[3 1 2]);
e = permute(e,[3 1 2]);
%es = permute(es,[3 1 2]);

for iCh = 1:nCh
%    dc(:,:,iCh) = dc(:,:,iCh) .* (ones(nT,1)*sc(:,:,iCh));
    e(:,:,iCh) = e(:,:,iCh) .* (ones(nT,1)*sc(:,:,iCh));
%    es(:,:,iCh) = es(:,:,iCh) .* (ones(nT,1)*sc(:,:,iCh));
end

dc = e;
dc(:,3,:) = dc(:,1,:) + dc(:,2,:);




