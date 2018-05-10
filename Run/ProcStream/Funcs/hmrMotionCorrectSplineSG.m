function dod = hmrMotionCorrectSplineSG(dod, d, t, SD, p, FrameSize_sec, turnon)
% Sahar Jahani, October 2017
% Added turn on/off option Meryem Nov 2017
if exist('turnon')
   if turnon==0
   return;
   end
end

[tIncCh, tInc] = hmrtInc_baselineshift_Ch(dod, t); % finding the baseline shift motions

fs = abs(1/(t(2)-t(1)));
%% extending signal for motion detection purpose (12 sec from each edge)
extend = round(12*fs); 

tIncCh1=repmat(tIncCh(1,:),extend,1);
tIncCh2=repmat(tIncCh(end,:),extend,1);
tIncCh=[tIncCh1;tIncCh;tIncCh2];

d1=repmat(dod(1,:),extend,1);
d2=repmat(dod(end,:),extend,1);
dod=[d1;dod;d2];

t2=(0:(1/fs):(length(dod)/fs))';
t2=t2(1:length(dod),1);

[dodLP,ylpf] = hmrBandpassFilt( dod, fs, 0, 2 ); 

%% Spline Interpolation
dod = hmrMotionCorrectSpline(dodLP, t2, SD, tIncCh, p);
dod=dod(extend+1:end-extend,:); % removing the extention

%% Savitzky_Golay filter
K = 3; % polynomial order
FrameSize_sec = round(FrameSize_sec * fs);
if mod(FrameSize_sec,2)==0
    FrameSize_sec = FrameSize_sec  + 1;
end
dod=sgolayfilt(dod,K,FrameSize_sec);

