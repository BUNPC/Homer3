% h = plotProbe( y, t, SD, ml, ystd, axFactor, tStep, tAmp, tVis )
%
% Plot the data in the probe format. If no data is provided,
% this plots the probe geometry given in SD.
%
% y - is the data to plot. This 2D or 3D array is either 
% 
%     If it's 3D then the meaning of the dimensions are 
% 
%          <DATA TIME POINTS> x <HB TYPES x CHANNELS> 
%
%     or if it's 2D 
% 
%          <DATA TIME POINTS> x <CHANNELS OF ALL WAVELENGTHS>
%
%     If empty, then the probe is plotted with lines joining sources 
%     and detectors in the ml with solid line and
%     dotted line distringuishing active measurements as indicated in
%     mlActMan
%
% t - is the corresponding time vector
%
% SD - SD structure
%
% ystd - Standard deviation to be plotted as y +/- ystd. OPTIONAL
%
% axFactor - [x y] scale the width and height of the subplots. OPTIONAL
%
% tVis - The value of the visible property of the vertical time markers. if
%         'on' 1, they are shown, if 'off' or 0, they are not.
%
% tStep - Time intervals at which to draw vertical time markers, starting at
%         t0 (stim onset).  tStep has be within the range of 5 <= tStep <= t.
%         OPTIONAL
%
% tAmp  - Amplitude of the vertical time markers.
%         OPTIONAL
%
% To Do
% cmin and cmax
% toggle nearest neighbors
% assuming y is concentration data... need to check dimensions

function h = plotProbe( y, t, SD, ml, ~, axFactor, tStep, tAmp, tVis)

EXPLODE_THRESH = 0.02;
EXPLODE_VECTOR = [0.02, 0.08];

h = [];

% Get initial arg values
if ~exist('y','var')
    y = [];
end
if ~exist('ystd','var')
    ystd = [];
end
if ~exist('SD','var') 
    SD = [];
end
if ~exist('ml','var')
    ml = [];
end
if ~exist('tVis','var')
    tVis = 'on';
else
    if tVis == 1
        tVis = 'on';
    elseif tVis == 0
        tVis = 'off';
    end 
end
if ~exist('axFactor','var')
    axFactor = [1,1];
elseif isempty(axFactor)
    axFactor = [1,1];
elseif ndims(axFactor)~=2
    axFactor(2) = axFactor(1);
end
if ~isempty(t)
    if ~exist('tStep','var') || isempty(tStep) || tStep>t(end)
        tStep = t(end);
    elseif tStep<2 && tStep~=0
        tStep = 2;
    end
end
if ~exist('tAmp','var') || isempty(tAmp) || tAmp<0
    tAmp = 0;
end

% Conditions causing early exit
if isempty(y)
    hold off
    return;
end
if isempty(ml)
    hold off
    return;
end
if isempty(SD)
    hold off
    return;
end


% This section will give the option to display subsections of the probe
% based on nearest-neighbor etc distances.  If the probe only has one
% distance, this option is not given
Distances = ((SD.SrcPos(ml(:,1),1) - SD.DetPos(ml(:,2),1)).^2 +...
             (SD.SrcPos(ml(:,1),2) - SD.DetPos(ml(:,2),2)).^2 +...
             (SD.SrcPos(ml(:,1),3) - SD.DetPos(ml(:,2),3)).^2).^0.5;
nearneighborLst = ones(length(Distances),1);
lstNN = find(nearneighborLst==1);

%Use the probe SD positions to define the look of this plot
sPos = SD.SrcPos;
dPos = SD.DetPos;

sdMin = min([sPos;dPos]) - mean(Distances(lstNN));
sdMax = max([sPos;dPos]) + mean(Distances(lstNN));

sdWid = sdMax(1) - sdMin(1);
sdHgt = sdMax(2) - sdMin(2);

sd2axScl = max(sdWid,sdHgt);

sPos = sPos / sd2axScl;
dPos = dPos / sd2axScl;            %            xlim([min(t) max(t)])

nAcross = length(unique([sPos(:,1); dPos(:,1)]))+1;
nUp = length(unique([sPos(:,2); dPos(:,2)]))+1;

axWid = axFactor(1) * 1/nAcross;
axHgt = axFactor(2) * 1/nUp;

axXoff = mean([sPos(:,1);dPos(:,1)])-.5;
axYoff = mean([sPos(:,2);dPos(:,2)])-.5;

mlAct = ones(size(ml,1),1);

%This is the plotting routine
% Initialize channel idx for try/catch. Catch uses it
% to display which channel was being processed when
% error ocurred.
colorActive = [
    1.00 0.00 0.00;
    0.00 0.00 1.00;
    0.00 1.00 0.00;
    1.00 0.00 1.00;
    0.00 1.00 1.00;
    0.50 0.80 0.30
    ];

colorInactive = [
    0.80 0.00 0.20;
    0.00 0.20 0.80;
    0.20 0.80 0.00;
    1.00 0.00 1.00;
    0.00 1.00 1.00;
    0.50 0.80 0.30
    ];

% ha = subplot(1,1,1);
minT = min(t);
maxT = max(t);

nTSteps = round(t(end)/tStep);
tStep = tStep/(t(2)-t(1));

if ~isempty(y)
    iSrc = ml(1,1);
    iDet = ml(1,2);
    iMeasSDpair = find( (ml(:,1) == iSrc)  &  (ml(:,2) == iDet) );
    nDataTypes = length(iMeasSDpair);
    nSDpairs = size(ml,1)/nDataTypes;
    iSDpairs = find( ml(:,4) == 1 );
        
    minAmp = min(min(y));
    maxAmp = max(max(y));
    
    if length(tAmp)==2
        cmin = tAmp(1);
        cmax = tAmp(2);
    else
        cmin = minAmp;
        cmax = maxAmp;
    end
    
    h  = zeros(nSDpairs, nDataTypes);
    ls = repmat({''}, nSDpairs, 1);
    lw = zeros(nSDpairs, nDataTypes);
    lv = repmat({''}, nSDpairs, nDataTypes);
    lc = zeros(nSDpairs, nDataTypes, 3);
        
    try
	    for iSD = 1:length(iSDpairs)
	        
	        % Get all measurements with current source and detector pair
	        iSrc = ml(iSDpairs(iSD),1);
	        iDet = ml(iSDpairs(iSD),2);
	        iSDpairAllMeas = find( (ml(:,1) == iSrc)  &  (ml(:,2) == iDet) );
	        
	        % To eliminate displayed data drifting when scaling y up
	        % or down offset data to align min/max midpoint with zero.
	        [y, yOffset] = offsetData(y, iSDpairAllMeas);
	        
	        if ml(iSDpairAllMeas(1),5) == 1
	            color = colorActive;
	            linewidth = 2;
	            linestyle = '-';
	        else
	            color = colorInactive;
	            linewidth = 1;
	            linestyle = '--';
	        end
	        
	        
	        for iMeasType = 1:length(iSDpairAllMeas)
	                        
	            % Record line graphics properties based on the object type
	            [lc,lv,lw,ls] = setLineProperties(lc,lv,lw,ls,iMeasType,mlAct,color,nDataTypes,nTSteps);
	            
	            xa = ( sPos(ml(iSDpairAllMeas(iMeasType),1), 1) + dPos(ml(iSDpairAllMeas(iMeasType),2), 1) ) / 2 - axXoff;
	            ya = ( sPos(ml(iSDpairAllMeas(iMeasType),1), 2) + dPos(ml(iSDpairAllMeas(iMeasType),2), 2) ) / 2 - axYoff;
	            
	            xT = xa-axWid/4 + axWid*((t-minT)/(maxT-minT))/2;
	            AvgT = ya-axHgt/4 + axHgt*((y(:,iSDpairAllMeas(iMeasType))-cmin)/(cmax-cmin))/2;
	            
	            hold on
	            
	            h(iSD,iMeasType) = plot( xT, AvgT,'color',color(iMeasType,:), 'visible','on', 'linewidth',linewidth, 'linestyle',linestyle );
	            
	        end
	        
	        % Plot time markers starting with stim onset
	        if length(tAmp)==1
	            AvgTmax0 = max(max(AvgT));
	            AvgTmin0 = min(min(AvgT));
	            if tAmp==0
	                % tAmp is a relative amplitude
	                AvgTmax = AvgTmax0;
	                AvgTmin = AvgTmin0;
	            else
	                % tAmp is a fixed amplitude
	                AvgTmax = ya-axHgt/4 + axHgt*((tAmp-cmin)/(cmax-cmin))/2;
	                AvgTmin = ya-axHgt/4 + axHgt*((0-cmin)/(cmax-cmin))/2;
	                AvgTmax = AvgTmax+AvgTmin0-AvgTmin;
	                AvgTmin = AvgTmin0;
	            end
	            if abs(AvgTmin-AvgTmax)<1.0e-10
	                AvgTmin = AvgTmin-(AvgTmin*.01);
	                AvgTmax = AvgTmax+(AvgTmax*.01);
	            end
	        elseif length(tAmp)==2
	            % tAmp is a fixed range
	            AvgTmax = ya-axHgt/4 + axHgt*(((cmax-offset(idx))-cmin)/(cmax-cmin))/2;
	            AvgTmin = ya-axHgt/4 + axHgt*(((cmin-offset(idx))-cmin)/(cmax-cmin))/2;
	        end
	        kk = nDataTypes+1;
	        yMark = [AvgTmin,AvgTmax]-yOffset;
	        xT0 = xT(find(t==0));
	        xTStep = tStep*(xT(2)-xT(1));
	        if strcmp(lv{iSD(1),kk}, 'off')
	            tvis_ch = 'off';
	        else
	            tvis_ch = tVis;
	        end
	        for xTi = xT0:xTStep:xT(end)
	            xTi = [xTi, xTi];
	            hTmarks = plot(xTi, yMark, 'color','k', 'visible',tvis_ch);
	            h(iSD,kk) = hTmarks;
	            lw(iSD,kk) = 1.0;
	            kk = kk+1;
	        end
        end
        
    catch
        
        menu(sprintf('plotProbe exited with ERROR while plotting data for channel # %d',iSD),'OK');
        h=[];
        
    end
    
end


% Plot the optodes on the axes
if ismac() || islinux()
    fs = 14;
else
    fs = 11;
end
for idx2 = 1:size(sPos,1)
    xa = sPos(idx2,1) - axXoff;
    ya = sPos(idx2,2) - axYoff;    
    ht = text(xa,ya,sprintf('S%d',idx2));
    set(ht,'fontweight','bold','fontsize',fs)
    set(ht,'color',[1 0 0])
end
for idx2 = 1:size(dPos,1)
    xa = dPos(idx2,1) - axXoff;
    ya = dPos(idx2,2) - axYoff;
    ht = text(xa,ya,sprintf('D%d',idx2));
    set(ht,'fontweight','bold','fontsize',fs)
    set(ht,'color',[0 0 1])
end

hold off




% ----------------------------------------------------------------------------------------
function [lc,lv,lw,ls] = setLineProperties(lc,lv,lw,ls,idx,mlAct,color,nDataTypes,nTSteps)

if mlAct(idx)==0  % Make manually and automaticaly pruned or disabled channels dotted
    ls{idx} = ':';
    for ii=1:nDataTypes
        lw(idx,ii) = 1;
        lc(idx,ii,:) = color(ii,:);
        lv{idx,ii} = 'on';
    end
    for ii=nDataTypes+1:nDataTypes+nTSteps
        lc(idx,ii,:) = [0 0 0];
        lv{idx,ii} = 'on';
    end
elseif mlAct(idx)==1
    ls{idx} = '-';
    for ii=1:nDataTypes
        lw(idx,ii) = 1;
        lc(idx,ii,:) = color(ii,:);
        lv{idx,ii} = 'on';
    end
    for ii=nDataTypes+1:nDataTypes+nTSteps
        lc(idx,ii,:) = [0 0 0];
        lv{idx,ii} = 'on';
    end
elseif mlAct(idx)==-1  % Hide hidden channels
    ls{idx} = '-';
    for ii=1:nDataTypes
        lw(idx,ii) = 1.0;
        lc(idx,ii,:) = color(ii+nDataTypes,:);
        lv{idx,ii} = 'off';
    end
    for ii=nDataTypes+1:nDataTypes+nTSteps
        lc(idx,ii,:) = [0 0 0];
        lv{idx,ii} = 'off';
    end
end



% ------------------------------------------------------
function [y,ampMp] = offsetData(y, k)
minAmp = min(min(y(:,k)));
maxAmp = max(max(y(:,k)));

% Find amplitude mid-point and shift data midpoint to zero
ampDiff = maxAmp - minAmp;
ampMp   = minAmp + ampDiff/2;
y(:,k) = y(:,k) - ampMp;


