% [x, yStim,yModel,y,C,Q] = hmrKalman( y, s, t, xo, Co, Qo, hrfType, hrfParam, oscFreq )
%
% UI NAME:
% Kalman_Filter_OscSysPhys
%
%
function [x, yStim,yModel,y,C,Q] = hmrKalman( y, s, t, xo, Co, Qo, hrfType, hrfParam, oscFreq )

% Verify that x, C, and Q have expected length
nStatesExp = 1 + length(oscFreq);
foos = '';
if length(xo)~=nStatesExp
    foos = sprintf( '%sERROR in x\n', foos ); 
end
if length(Co)~=nStatesExp
    foos = sprintf( '%sERROR in C\n', foos ); 
end
if length(Qo)~=nStatesExp
    foos = sprintf( '%sERROR in Q\n', foos ); 
end
if length(foos)>0
    disp(foos)
    x = [];
    yModel = [];
    yStim = [];
    return;
end

% make sure this is #channels x #Tpts
if size(y,1)>size(y,2)
    y = y';    
    flagTranspose = 1;
else
    flagTranspose = 0;
end


% Set state vector based on Cos and Sin
% and number of data channels
nCh = size(y,1);
if length(xo)>=2
    x(1) = xo(1);
    for ii=2:length(xo)
        x((ii-1)*2) = xo(ii);
        x((ii-1)*2+1) = xo(ii);
    end
else
    x = xo;
end
x = x(:);
nStatesPerChannel = length(x);
sLst = 1;
for ii=2:nCh
    x(:,ii) = x(:,1);
    sLst(end+1) = sLst(end)+nStatesPerChannel;
end
x = x(:);

% initialize parameters
nStates = length(x);
yModel = zeros(nCh,length(y));

K = eye(nStates);     % state transition matrix
R = eye(nCh)*1e-9;  % observable covariance
C = zeros(nStates,nStates);  % state covariance
C(1,1) = Co(1);
kk = 0;
for ii=2:length(Co)
    kk = kk + 1;
    C(2*kk,2*kk) = Co(ii);
    C(2*kk+1,2*kk+1) = Co(ii);
end
foo = C(1:nStatesPerChannel,1:nStatesPerChannel);
for ii=1:nCh
    C(nStatesPerChannel*(ii-1)+[1:nStatesPerChannel],nStatesPerChannel*(ii-1)+[1:nStatesPerChannel]) = foo;
end
Q = zeros(nStates,nStates);  % state update noise covariance 
Q(1,1) = Qo(1);
kk = 0;
for ii=2:length(Qo)
    kk = kk + 1;
    Q(2*kk,2*kk) = Qo(ii);
    Q(2*kk+1,2*kk+1) = Qo(ii);
end
foo = Q(1:nStatesPerChannel,1:nStatesPerChannel);
for ii=1:nCh
    Q(nStatesPerChannel*(ii-1)+[1:nStatesPerChannel],nStatesPerChannel*(ii-1)+[1:nStatesPerChannel]) = foo;
end

nt = length(t);
dt = t(2)-t(1);

% Create Model
if strcmpi(hrfType,'box')
    wid1 = round(hrfParam(1)/dt);
    wid2 = round(hrfParam(2)/dt);
    hrf = [zeros(wid1,1); ones(wid2,1)];
end

Rhrf = conv( s, hrf );
Rosc = [];
for ii=1:length(oscFreq)
    Rosc(:,2*(ii-1)+1) = cos(2*3.14159*oscFreq(ii)*t);
    Rosc(:,2*(ii-1)+2) = sin(2*3.14159*oscFreq(ii)*t);
end

% Run Kalman Filter
for iT = 1:nt
    Co = C;
    xo = x;
    
    if ~isempty(Rosc)
        J = [Rhrf(iT) Rosc(iT,:)];
        for ii=2:size(y,1)
            J(ii,(ii-1)*nStatesPerChannel+[1:nStatesPerChannel]) = J(1,:);
        end
    else
        J = Rhrf(iT);
    end
    
    x = K * xo;  % state prediction
    C = K * Co * K' + Q; % variance prediction
    G = C * J' * inv( J*C*J' + R );
    x = x + G * (y(:,iT) - J*x);
    C = (eye(nStates)-G*J)*C;
    
    yModel(:,iT) = J*x;
    yStim(:,iT) = J(:,sLst)*x(sLst);
end

% flip back to #Tpts x #channels
if flagTranspose
    yModel = yModel';
    yStim = yStim';
    y = y';
end


