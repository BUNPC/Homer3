% function [yresid, yhrf, tHRF, nTrials] = hmrRegressors(yo, yreg, t, trange, nStim )
%
% UI NAME:
% Regressors
%
% Calculate the impulse response to different regressors
%
% INPUT
% yo - this is the concentration data (#time points x [HbO/HbR/HbT] x
%                                      #channels)
% yreg - these are the regressors (#time points x #regressors)
%        the first nStim columns are assumed to be stimulus marks for each 
%        of nStim independent stimulus conditions
% t - the time vector (#time points x 1)
% trange - the time range for the impulse response function [tpre tpost]
% nStim - number of different stimulus conditions presented in yreg
%         This is optional. If not included then nStim = size(yreg,2)
%
% OUTPUT
% yresid - residual of the regressor fit to the data (#time points x
%                                                [HbO/Hbr/HbT] x #channels)
% yhrf - impulse response to the stimuli (#time points x [HbO/Hbr/HbT] x
%                                         #channels x #nStim) 
% tHRF - This is the time vector for the estimted HRF
% nTrials - number of trials for each stim condition in yreg
%

function varargout = hmrRegressors(yo, yreg, t, trange, nStim )

if ndims(yo)~=3
    menu( 'hmrRegressors() currently only works on Concentration data.', 'Okay');
    y = [];
    return;
end

if ~exist('nStim')
    nStim = [];
end
if isempty(nStim)% || nStim ==0
    nStim = size(yreg,2);
end
if ~exist('lstConcReg') % not passing this now, so just assume it is 0
    lstConcReg = [];
end
% pass lstRegConc = 0, 1, or 2 for each regressor for both Conc, HbO only,
%            HbR only. Not that this will fail if a 1 is not balanced with
%            2 of the same tRange
if isempty(lstConcReg) || length(lstConcReg)~=size(yreg,2)
    lstConcReg = zeros(size(yreg,2),1);
end

trange = (trange(:) * ones(1,nStim))';

dt = t(2)-t(1);
nPremax = round( min(trange(:,1)) / dt );
nPostmax = round( max(trange(:,2)) / dt );

thrf = [nPremax:nPostmax]'*dt;
nTrials = sum(yreg(:,1:nStim));

iConc = 1;
lstIRF = 0;
nPts = size(yo,1);
flagConcReg = [];
for iReg = 1:size(yreg,2)
    nPre = round(trange(iReg,1)/dt);
    nPost = round(trange(iReg,2)/dt);
    lstIRF(end+1) = lstIRF(end) + (nPost-nPre) + 1;
    flagConcReg((lstIRF(end-1)+1):lstIRF(end)) = lstConcReg(iReg);
end
A = zeros(size(yreg,1),lstIRF(end));
nCol = 0;
for iReg = 1:size(yreg,2)
    nPre = round(trange(iReg,1)/dt);
    nPost = round(trange(iReg,2)/dt);
    for iT = nPre:nPost    
        nCol = nCol + 1;
        A(:,nCol) = [zeros(max(iT,0),1); yreg(max(1-iT,1):min((nPts-iT),nPts),iReg); zeros(max(-iT,0),1)];
%        A=[ A [zeros(max(iT,0),1); yreg(max(1-iT,1):min((nPts-iT),nPts),iReg); zeros(max(-iT,0),1)] ];
    end    
end

lst = find(flagConcReg==0 | flagConcReg==1);
y = zeros(size(A(:,lst),2),size(yo,3),3);
yresid = zeros(size(yo,1),size(yo,3),size(yo,2));
for iConc=1:2

    lst = find(flagConcReg==0 | flagConcReg==iConc);
    Atmp = A(:,lst);
    
    % check if the matrix is well conditionned
    ATA=Atmp'*Atmp;
    rco=rcond(full(ATA));
    if rco<10^-14 && rco>10^-25
        display(sprintf('Design matrix is poorly scaled...(RCond= %f', num2str(rco)))
    elseif rco<10^-25
        display(sprintf('Design matrix is VERY poorly scaled...(RCond= %f, cannot perform computation', num2str(rco)))
        return
    end
    
    %compute pseudo-inverse
    pinvA=ATA\Atmp';
    
    %deconvolve
    y(:,:,iConc)=pinvA*squeeze(yo(:,iConc,:));
    yresid(:,:,iConc) = squeeze(yo(:,iConc,:)) - Atmp(:,(lstIRF(nStim+1)+1):end) * y((lstIRF(nStim+1)+1):end,:,iConc);
    
end
y(:,:,3) = y(:,:,1) + y(:,:,2);
y = permute(y,[1 3 2]);

yresid(:,:,3) = yresid(:,:,1) + yresid(:,:,2);
yresid = permute(yresid,[1 3 2]);

varargout(1) = {yresid};
foo = [];
nPre = round(trange(1,1)/dt);
for ii=2:(nStim+1)
    foo(:,:,:,ii-1) = y((lstIRF(ii-1)+1):lstIRF(ii),:,:);
end
if ~isempty(foo) && nPre<0
    for iConc = 1:size(foo,2)
        for iCh = 1:size(foo,3)
            for iStim = 1:size(foo,4)
                foo(:,iConc,iCh,iStim) = foo(:,iConc,iCh,iStim) - ones(size(foo,1),1)*mean(foo(1:(-nPre),iConc,iCh,iStim),1);
            end
        end
    end
end
varargout(2) = {foo};

varargout(3) = {thrf};
varargout(4) = {nTrials};

%foo = [];
%for ii=(nStim+2):(length(find(lstConcReg==0))+1)    % This is a cludge because I am not handling when lstConcReg=1 or 2
%    foo = y((lstIRF(ii-1)+1):lstIRF(ii),:,:);
%    varargout(ii) = {foo};
%end



