% [x, yModel,y,C,R] = hmrKalmanOscPhys( y, ml, s, t, xo, Co, Qo, R, ...
%                                       hrfType, hrfParam, oscFreq, commonMode );
%
% UI NAME:
% KalmanFilter_OscSysPhys
%
%
% This function performs the Kalman Filter using the oscillatory systemic
% physiology model combined with a temporal basis for the stimulus evoked response.
%
%
% INPUTS:
% y - the data to model (#time points x #channels)
%     or (#time points x Hemoglobin x #channels)
% ml - the measurement list corresponding to the channels in y
%     this is needed if y is comprised of data with multiple wavelengths
%     when using a commonMode state so that the different wavelengths
%     can be treated separately. If y is concentration data, then it is
%     assumed that the first half of the data is one concentration and the 
%     second half is the other concentration
% s - stimulation vector (# time points x #conditions)
%     =1 at stim onset otherwise =0
% t - time vector
% xo - initial guess for states (#states per channel x 1).
%      the first state per channel corresponds to the stimulus evoked
%      response. The next states correspond to the 
%      coefficients for each frequency specified by oscFreq. The total 
%      number of states per channel is 1 + length(oscFreq) + #CommonModes.
%      Note that the number of states returned per channel will be
%      1 + 2*length(oscFreq) + #CommonModes because we use a Cosine and 
%      Sine for each frequency. You can also supply the output x as
%      input which has dimensions (1 + 2*length(oscFreq) + #CommonModes) x
%      #Channels
% Co - state covariance initial estimate (#states per channel x 1)
% Qo - state update noise covariance (#states per channel x 1)
% R - measurement covariance (#channels x #channels) or [] in which case
%     it is estimated from y.
% hrfType - The type of temporal basis function to use for the stimulus
%           evoked response. This can be:
%            'box' - simple box car.
% hrfParam - Parameters for the basis function, depending on hrfType
%            'box' requires [wid1 wid2] - wid1 is the delay from stim onset
%                  wid2 is the width of the box car.
% oscFreq - Oscillatory frequencies to model (Hz). It is a good idea to always
%           include 0 Hz.
% commonMode - This will use the mean of the data across channels as a
%     regressor. If commonMode=1, then the regressor is 1. If commonMode=2,
%     then it uses the mean of the data across channels as the regressor.
%     This latter mode produces a state ~ 1 and allows a smaller Q. Both
%     modes will treat different wavelengths and difference hemoglobin
%     species with a different commonMode state.
%
%
% OUTPUTS:
% x - the final estimate of the states
% yModel - the model fit of the data (#time points x #channels x 2).
%          the modeled response to stimulus is returned as well as the
%          complete model.
% y - the data that was fit by the model.
% C - The final estimate of the state covariance
% R - The measurement covariance estimated form y-yModel
%
% TO DO
% DONE UPDATE DESCRIPTION allow Qo to be (#states per channel x #channels)
% complete check for existence of parameters
% update description for u inputs and outputs
% verify correspondence of uCommon, vCommon, and t
% move s next to hrfType
%
% FEATURES TO DO
% add Gamma function HRF
% think about extended KF for Gamma function states onset and width


function [x,yModel,xAll,y,C,R,r2,pval] = hmrKalmanOscPhys( y, ml, s, t, xo, Co, Qo, R, hrfType, hrfParam, oscFreq, u, uCommonMode, vCommonMode );

% make sure y is #channels x #Tpts
if ndims(y)==3
    nChConc = size(y,3);
    nHb = size(y,2);
    lstML1 = [1:size(y,3)];
    lstML2 = size(y,3)+[1:size(y,3)];
    y = reshape(permute(y,[1 3 2]),[size(y,1) size(y,2)*size(y,3)]);
    flagIsConc=1;
elseif size(ml,1)==size(y,2)
    lstML1 = find(ml(:,4)==1);
    lstML2 = find(ml(:,4)==2);
    flagIsConc = 0;
else
    lstML1 = [1:size(y,2)];
    lstML2 = [];
end
if size(y,1)>size(y,2)
    y = y';    
    flagTranspose = 1;
else
    flagTranspose = 0;
end
nCh = size(y,1);
nCond = size(s,2);
nInputs = size(u,2);
nt = length(t);


% check for existence of parameters
if ~exist('oscFreq')
    oscFreq = [];
end

if ~exist('uCommonMode')
    nCommonMode = 0;
elseif isempty(uCommonMode)
    nCommonMode = 0;
elseif size(uCommonMode,1)==nt
    nCommonMode = size(uCommonMode,2);
else
    nCommonMode = 0;
end

% verify hrfParam has expected size
foos = '';
if strcmpi(hrfType,'box')
    if size(hrfParam,1)~=nCond | size(hrfParam,2)~=2
        foos = sprintf( '%sERROR in hrfParam. For hrfType ''%s'' size must be nConds x 2',foos,hrfType);
    end
    nStatesPerCond = 1;

elseif strcmpi(hrfType,'fir')
    if length(hrfParam)<2 | ~isempty(find(hrfParam<0))
        foos = sprintf( '%sERROR in hrfParam. For hrfType ''%s'' length(hrfParam)>=2\n    and elements of hrfParam must be >=0',foos,hrfType);
    end
    nStatesPerCond = length(hrfParam)-1;
    
elseif strcmpi(hrfType,'mgamma')
    if size(hrfParam,1)~=nCond | size(hrfParam,2)~=3
        foos = sprintf( '%sERROR in hrfParam. For hrfType ''%s'' size must be nConds x 3',foos,hrfType);
    end
    nStatesPerCond = 1;

elseif strcmpi(hrfType,'none')
    nStatesPerCond = 0;
    
else
    foos = sprintf( '%sERROR in hrfParam. hrfType ''%s'' is not defined',foos,hrfType);

end

% calculate R from y if empty
if isempty(R)
    R = cov(y');
end

% Verify that x, C, Q, and R have expected length
nCondStates = nCond*nStatesPerCond;
nOscFreq = length(oscFreq);
nStatesSnO = nCondStates + nOscFreq + nInputs;
nStatesExp = nCondStates + nOscFreq + nInputs + nCommonMode;
nStates = (nCondStates + 2*nOscFreq + nInputs)*nCh + nCommonMode;
nStatesPerChannel = nCondStates + 2*nOscFreq + nInputs + nCommonMode;
nStatesPerChannelWOCM = nCondStates + 2*nOscFreq + nInputs;
if ~(size(xo,1)==nStatesExp & size(xo,2)==1) & ~(size(xo,1)==nStatesPerChannel & size(xo,2)==nCh)
    foos = sprintf( '%sERROR in x. x must be #states per channel x #channels  -OR-  #states per channel x 1\n', foos ); 
end
if length(Co)~=nStatesExp & (size(Co,1)~=nStates & size(Co,2)~=nStates)
    foos = sprintf( '%sERROR in C. C must be #states per channel x 1  -OR-  #states x #states\n', foos ); 
end
if length(Qo)~=nStatesExp & (size(Qo,1)~=nStates & size(Qo,2)~=nStates)
    foos = sprintf( '%sERROR in Q. Q must be #states per channel x 1  -OR-  #states x #states\n', foos ); 
end
if size(R,1)~=nCh | size(R,2)~=nCh
    foos = sprintf( '%sERROR in R. R must be #ch x #ch  -OR-  []\n',foos );
end

% verify y,t,u all have expected size
if size(y,2)~=length(t)
    foos = sprintf('%sERROR: y and t do not have the same length',foos);
end
if size(u,1)~=length(t) & ~isempty(u)
    foos = sprintf('%sERROR: u and t do not have the same length',foos);
end
if length(foos)>0
    disp(foos)
    x = xo;
    xAll = [];
    yModel = [];
    C = Co;
    r2 = [];
    pval = [];
    return;
end

% Set state vector based on Cos and Sin
% and number of data channels and common mode
[nx1,nx2] = size(xo);
if ~(nx1==nStatesPerChannel & nx2==nCh)
    if nx1>nCondStates
        for jj=1:nCh
            if nx2==nCh
                x(1:nCondStates,jj) = xo(1:nCondStates,jj);
            else
                x(1:nCondStates,jj) = xo(1:nCondStates);
            end
            for ii=1:nOscFreq
                if nx2==nCh
                    x((ii-1)*2+nCondStates+1,jj) = xo(ii+nCondStates,jj);
                    x((ii-1)*2+nCondStates+2,jj) = xo(ii+nCondStates,jj);
                else
                    x((ii-1)*2+nCondStates+1,jj) = xo(ii+nCondStates);
                    x((ii-1)*2+nCondStates+2,jj) = xo(ii+nCondStates);
                end
            end
            for ii=1:nInputs
                if nx2==nCh
                    x(nCondStates+2*nOscFreq+ii,jj) = xo(nCondStates+nOscFreq+ii,jj);
                else
                    x(nCondStates+2*nOscFreq+ii,jj) = xo(nCondStates+nOscFreq+ii);
                end
            end
        end
    else
        for jj=1:nCh
            x(:,jj) = xo;
        end
    end
    nStatesPerChannelWOCM = size(x,1);
    x = x(:);

    for ii=1:nCommonMode
        x(end+1) = xo(nStatesSnO+ii);
    end
else
    x = xo(1:nStatesPerChannelWOCM,:);
    x = x(:);
    
    for ii=1:nCommonMode
        x(end+1) = xo(nStatesPerChannelWOCM+ii,1);
    end
end
for iCond = 1:nCond
    sLst{iCond} = (iCond-1)*nStatesPerCond + [1:nStatesPerCond];
    for ii=2:nCh
        sLst{iCond}(end+[1:nStatesPerCond]) = nStatesPerChannelWOCM*(ii-1) + ...
            (iCond-1)*nStatesPerCond + [1:nStatesPerCond];
    end
end
for iInput = 1:nInputs
    iLst{iInput} = nCondStates+2*nOscFreq+iInput;
    for ii=2:nCh
        iLst{iInput}(end+1) = iLst{iInput}(end) + nStatesPerChannelWOCM;
    end
end

% initialize parameters
nStates = length(x);
nStatesSnO2 = nStates-nCommonMode;
yModel = zeros(nCh,length(y),nCond+nInputs+1);

dt = t(2)-t(1);

xAll = zeros(nStates,nt);

K = eye(nStates);     % state transition matrix
%R = eye(nCh)*1e-9;  % observable covariance

if size(Co,1)==nStates & size(Co,2)==nStates
    C = Co;
else
    C = zeros(nStates,nStates);  % state covariance
    for iCond=1:nCondStates
        C(iCond,iCond) = Co(iCond);
    end
    kk = 0;
    for ii=nCondStates+[1:nOscFreq]
        kk = kk + 1;
        C(2*(kk-1)+nCondStates+1,2*(kk-1)+nCondStates+1) = Co(ii);
        if oscFreq(ii-nCondStates)~=0
            C(2*(kk-1)+nCondStates+2,2*(kk-1)+nCondStates+2) = Co(ii);
        end
    end
    for ii=1:nInputs
        C(nCondStates+2*nOscFreq+ii,nCondStates+2*nOscFreq+ii) = Co(nCondStates+nOscFreq+ii);
    end
    foo = C(1:nStatesPerChannelWOCM,1:nStatesPerChannelWOCM);
    for ii=1:nCh
        C(nStatesPerChannelWOCM*(ii-1)+[1:nStatesPerChannelWOCM],nStatesPerChannelWOCM*(ii-1)+[1:nStatesPerChannelWOCM]) = foo;
    end
    for ii=1:nCommonMode
        C(nStatesSnO2+ii,nStatesSnO2+ii) = Co(nStatesSnO+ii);
    end
end

if size(Qo,1)==nStates & size(Qo,2)==nStates
    Q = Qo;
else
    Q = zeros(nStates,nStates);  % state update noise covariance
    for iCond = 1:nCondStates
        Q(iCond,iCond) = Qo(iCond);
    end
    kk = 0;
    for ii=nCondStates+[1:nOscFreq]
        kk = kk + 1;
        Q(2*(kk-1)+nCondStates+1,2*(kk-1)+nCondStates+1) = Qo(ii);
        if oscFreq(ii-nCondStates)~=0
            Q(2*(kk-1)+nCondStates+2,2*(kk-1)+nCondStates+2) = Qo(ii);
        end
    end
    for ii=1:nInputs
        Q(nCondStates+2*nOscFreq+ii,nCondStates+2*nOscFreq+ii) = Qo(nCondStates+nOscFreq+ii);
    end
    foo = Q(1:nStatesPerChannelWOCM,1:nStatesPerChannelWOCM);
    for ii=1:nCh
        Q(nStatesPerChannelWOCM*(ii-1)+[1:nStatesPerChannelWOCM],nStatesPerChannelWOCM*(ii-1)+[1:nStatesPerChannelWOCM]) = foo;
    end
    for ii=1:nCommonMode
        Q(nStatesSnO2+ii,nStatesSnO2+ii) = Qo(nStatesSnO+ii);
    end
end


%%%%%%%%%%%%%%
% Create Model
%%%%%%%%%%%%%%
if strcmpi(hrfType,'box')
    hrf = zeros(max(sum(round(hrfParam/dt),2)),nCond);
    for ii=1:nCond
        wid1 = round(hrfParam(ii,1)/dt);
        wid2 = round(hrfParam(ii,2)/dt);
        hrf(1:(wid1+wid2),ii) = [zeros(wid1,1); ones(wid2,1)];
    end
    
elseif strcmpi(hrfType,'fir')
    kk = 0;
    for ii=1:nCond
        for jj=1:nStatesPerCond
            kk = kk + 1;
            wid1 = round(hrfParam(jj)/dt);
            wid2 = round(hrfParam(jj+1)/dt) - wid1;
            hrf(1:(wid1+wid2),kk) = [zeros(wid1,1); ones(wid2,1)];
        end
    end
    
elseif strcmpi(hrfType,'mgamma')
    hrf = zeros(max(round(hrfParam(:,3)/dt)),nCond);
    for ii=1:nCond
        thrf = [0:dt:hrfParam(ii,3)];
        tau = hrfParam(ii,1);
        sigma = hrfParam(ii,2);
        hrf(1:length(thrf),ii) = (thrf-tau).^2 .* exp( -(thrf-tau).^2/sigma^2 ) / sigma^2;
    end
    
end

kk = 0;
Rhrf = [];
for ii=1:nCond
    for jj=1:nStatesPerCond
        kk = kk + 1;
        Rhrf(:,kk) = conv( s(:,ii), hrf(:,kk) );
    end
end
clear hrf

Rosc = [];
for ii=1:nOscFreq
    Rosc(:,2*(ii-1)+1) = cos(2*3.14159*oscFreq(ii)*t);
    Rosc(:,2*(ii-1)+2) = sin(2*3.14159*oscFreq(ii)*t);
end
[nOsc1,nOsc2] = size(Rosc);
for ii=1:nInputs
    Rosc(:,nOsc2+ii) = u(:,ii);
end

idxCommonMode = nStatesPerChannelWOCM*nCh;



%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%
% Run Kalman Filter
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%
hwait = waitbar(0,'Kalman filter...');
for iT = 1:nt
    waitbar(iT/nt,hwait);
    Co = C;
    xo = x;
    
    if ~isempty(Rosc)
        if nCh==1
            if ~isempty(Rhrf)
                J = [Rhrf(iT,:) Rosc(iT,:)];
            else
                J = [Rosc(iT,:)];
            end
        else
            if ~isempty(Rhrf)
                J(1,1:nStatesPerChannelWOCM) = [Rhrf(iT,:) Rosc(iT,:)];
            else
                J(1,1:nStatesPerChannelWOCM) = [Rosc(iT,:)];
            end
            for ii=2:nCh
                J(ii,(ii-1)*nStatesPerChannelWOCM+[1:nStatesPerChannelWOCM]) = J(1,1:nStatesPerChannelWOCM);
            end
        end
    else
        if nCh==1
            J = [Rhrf(iT,:)];
        else
            J(1,1:nStatesPerChannelWOCM) = [Rhrf(iT,:)];
            for ii=2:nCh
                J(ii,(ii-1)*nStatesPerChannelWOCM+[1:nStatesPerChannelWOCM]) = J(1,1:nStatesPerChannelWOCM);
            end
        end
    end
    if nCommonMode>0
        for iCM = 1:nCommonMode
            J(:,idxCommonMode+iCM) = vCommonMode(:,iCM)*uCommonMode(iT,iCM)';
        end
    end    
%     if commonMode==1
%         J(lstML1,idxCommonMode) = 1;
%         if commonModeFlag==2
%             J(lstML2,idxCommonMode+1) = 1;
%         end
%     elseif commonMode==2
%         J(lstML1,idxCommonMode) = mean(y(lstML1,iT));
%         if commonModeFlag==2
%             J(lstML2,idxCommonMode+1) = mean(y(lstML2,iT));
%         end
%     end
    
    x = K * xo;  % state prediction
    C = K * Co * K' + Q; % variance prediction
    G = C * J' * inv( J*C*J' + R ); % Kalman gain
    x = x + G * (y(:,iT) - J*x); % state update
    C = (eye(nStates)-G*J)*C; % variance update
    
    xAll(:,iT) = x;
    yModel(:,iT,1) = J*x;
    for iCond = 1:nCond
        yModel(:,iT,iCond+1) = J(:,sLst{iCond})*x(sLst{iCond});
    end
    for iInput = 1:nInputs
        yModel(:,iT,nCond+iInput+1) = J(:,iLst{iInput})*x(iLst{iInput});
    end
end
close(hwait);





%%%%%%%%%%%%%
% calculate R 
R = cov(y' - yModel(:,:,1)');


% flip back to #Tpts x #channels
if flagTranspose
    yModel = permute(yModel,[2 1 3]);
    y = y';
end
if flagIsConc
    y = permute( reshape(y,[size(y,1) nChConc nHb]), [1 3 2]); 
    yModel = permute( reshape(yModel,[size(y,1) nChConc nHb nCond+nInputs+1]), [1 3 2 4]); 
end
if nCommonMode==0
    x = reshape(x,[nStatesPerChannelWOCM,nCh]);
else
    xCom = x(end-(nCommonMode-1):end);
    x = reshape(x(1:end-nCommonMode),[nStatesPerChannelWOCM,nCh]);
    for ii=1:nCommonMode
        x(end+1,:) = xCom(ii);
    end
end
xAll = xAll';


%%%%%%%%%%%%%
% goodness of fit
if ~flagIsConc
    yModelTmp = yModel(:,:,1);
    [r,p] = corrcoef(y(:),yModelTmp(:));
    r2 = r(1,2)^2;
    pval = p(1,2);
else
    yModelTmp = yModel(:,1,:,1);
    yTmp = y(:,1,:);
    [r,p] = corrcoef(yTmp(:),yModelTmp(:));
    r2(1) = r(1,2)^2;
    pval(1) = p(1,2);
    
    if nHb>1
        yModelTmp = yModel(:,2,:,1);
        yTmp = y(:,2,:);
        [r,p] = corrcoef(yTmp(:),yModelTmp(:));
        r2(2) = r(1,2)^2;
        pval(2) = p(1,2);
    end
end    


