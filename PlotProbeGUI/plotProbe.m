% h = plotProbe( y, t, SD, ml, ystd, axFactor, tStep, tAmp )
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
%     and detectors in the ch.MeasList with solid line and
%     dotted line distringuishing active measurements as indicated in
%     ch.MeasListActMan
%
% t - is the corresponding time vector
%
% SD - SD structure
%
% ystd - Standard deviation to be plotted as y +/- ystd. OPTIONAL
%
% axFactor - [x y] scale the width and height of the subplots. OPTIONAL
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

function h = plotProbe( y, t, SD, ch, ystd, axFactor, tStep, tAmp )

h=[];

% Get initial arg values
if ~exist('y','var')
    y = [];
end
if ~exist('ystd','var')
    ystd = [];
end
if ~exist('ystd','var')
    ystd = [];
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
    elseif tStep<5 && tStep~=0
        tStep = 5;
    end
end
if ~exist('tAmp','var') || isempty(tAmp) || tAmp<0
    tAmp = 0;
end

% Conditions causing early exit
if ~exist('SD','var') || isempty(SD)
    return;
end
if ~exist('ch','var') || isempty(ch)
    return;
end

% This section will give the option to display subsections of the probe
% based on nearest-neighbor etc distances.  If the probe only has one
% distance, this option is not given
Distances=((SD.SrcPos(ch.MeasList(:,1),1) - SD.DetPos(ch.MeasList(:,2),1)).^2 +...
           (SD.SrcPos(ch.MeasList(:,1),2) - SD.DetPos(ch.MeasList(:,2),2)).^2 +...
           (SD.SrcPos(ch.MeasList(:,1),3) - SD.DetPos(ch.MeasList(:,2),3)).^2).^0.5;
nearneighborLst=ones(length(Distances),1);
lstNN=find(nearneighborLst==1);

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


nAcross=length(unique([sPos(:,1); dPos(:,1)]))+1;
nUp=length(unique([sPos(:,2); dPos(:,2)]))+1;

axWid = axFactor(1) * 1/nAcross;
axHgt = axFactor(2) * 1/nUp;

axXoff=mean([sPos(:,1);dPos(:,1)])-.5;
axYoff=mean([sPos(:,2);dPos(:,2)])-.5;


%This is the plotting routine
try
    % Initialize channel idx for try/catch. Catch uses it 
    % to display which channel was being processed when 
    % error ocurred.
    idx = 0;

    ml    = ch.MeasList;
    lst   = find(ch.MeasList(:,4)==1);
    mlAct = ch.MeasListActMan(lst);

    if ndims(y)==3
        color=[
               1.00 0.00 0.00;
               0.00 0.00 1.00;
               0.00 1.00 0.00;
               1.00 0.00 1.00;
               0.00 1.00 1.00;
               0.50 0.80 0.30
              ];
    else
        if SD.Lambda(1)<SD.Lambda(2)
            color=[
                    0.00 0.00 1.00;
                    1.00 0.00 0.00;
                    0.00 1.00 1.00;
                    1.00 0.00 1.00;
                    0.50 0.80 0.30
                  ];
        else
            color=[
                    1.00 0.00 0.00;
                    0.00 0.00 1.00;
                    1.00 0.00 1.00;
                    0.00 1.00 1.00;
                    0.50 0.80 0.30
                  ];
        end
    end
        
    % ha = subplot(1,1,1);
    minT = min(t);
    maxT = max(t);
    
    if ~isempty(y)
        lstW1 = find(ml(:,4)==1);
        lstW2 = find(ml(:,4)==2);
        nCh = length(mlAct);
        nDataTypes = ndims(y);

        % To eliminate displayed data drifting when scaling y up 
        % or down offset data to align min/max midpoint with zero.
        [Avg, offset] = offsetData(y,nCh,nDataTypes);
        
        if ndims(Avg)==3
            minAmp=min(min(min(Avg)));
            maxAmp=max(max(max(Avg)));
        else
            minAmp=min(min(Avg));
            maxAmp=max(max(Avg));
        end

        if length(tAmp)==2
            cmin = tAmp(1);
            cmax = tAmp(2);
        else
            cmin = minAmp;
            cmax = maxAmp;
        end

        nTSteps = round(t(end)/tStep);
        tStep = tStep/(t(2)-t(1));
        h=zeros(nCh,nDataTypes+nTSteps);
        ls=repmat({''},nCh,1);
        lw=zeros(nCh,nDataTypes+nTSteps);
        lv=repmat({''},nCh,nDataTypes+nTSteps);
        lc=zeros(nCh,nDataTypes+nTSteps,3);

        for idx=1:length(lstW1)
            
            xa = (sPos(ml(lstW1(idx),1),1) + dPos(ml(lstW1(idx),2),1))/2 - axXoff;
            ya = (sPos(ml(lstW1(idx),1),2) + dPos(ml(lstW1(idx),2),2))/2 - axYoff;
            hold on
            
            xT = xa-axWid/4 + axWid*((t-minT)/(maxT-minT))/2;
            if ndims(Avg)==3
                AvgT = ya-axHgt/4 + axHgt*((Avg(:,:,idx)-cmin)/(cmax-cmin))/2;
            else
                AvgT(:,1) = ya-axHgt/4 + axHgt*((Avg(:,lstW1(idx))-cmin)/(cmax-cmin))/2;
                AvgT(:,2) = ya-axHgt/4 + axHgt*((Avg(:,lstW2(idx))-cmin)/(cmax-cmin))/2;
            end

            
            % Plot data curves
            h(idx,1)=plot( xT, AvgT(:,1),'color',color(1,:));
            if size(AvgT,2)>1
                h(idx,2)=plot( xT, AvgT(:,2),'color',color(2,:));
            end
            if size(AvgT,2)>2
                h(idx,3)=plot( xT, AvgT(:,3),'color',color(3,:));
            end


            % Plot time markers starting with stim onset
            if length(tAmp)==1
                AvgTmax0=max(max(AvgT));
                AvgTmin0=min(min(AvgT));
                if tAmp==0
                    % tAmp is a relative amplitude
                    AvgTmax=AvgTmax0;
                    AvgTmin=AvgTmin0;
                else
                    % tAmp is a fixed amplitude
                    AvgTmax=ya-axHgt/4 + axHgt*((tAmp-cmin)/(cmax-cmin))/2;
                    AvgTmin=ya-axHgt/4 + axHgt*((0-cmin)/(cmax-cmin))/2;
                    AvgTmax=AvgTmax+AvgTmin0-AvgTmin;
                    AvgTmin=AvgTmin0;
                end
                if abs(AvgTmin-AvgTmax)<1.0e-10
                    AvgTmin=AvgTmin-(AvgTmin*.01);
                    AvgTmax=AvgTmax+(AvgTmax*.01);
                end
            elseif length(tAmp)==2
                % tAmp is a fixed range
                AvgTmax = ya-axHgt/4 + axHgt*(((cmax-offset(idx))-cmin)/(cmax-cmin))/2;
                AvgTmin = ya-axHgt/4 + axHgt*(((cmin-offset(idx))-cmin)/(cmax-cmin))/2;
            end
            ii = nDataTypes+1;
            yStim = [AvgTmin,AvgTmax];
            xT0 = xT(find(t==0));
            xTStep = tStep*(xT(2)-xT(1));
            for xTi=xT0:xTStep:xT(end)
                xTi = [xTi xTi];
                h(idx,ii) = plot( xTi, yStim,'color','k' );
                lw(idx,ii) = 1.0;
                ii=ii+1;
                if ii-ndims(Avg)>nTSteps
                    break;
                end
            end

            % Plot standard deviation if provided
            if ~isempty(ystd)
                if ndims(Avg)==3
                    AvgT = ya-axHgt/4 + axHgt*((Avg(:,:,idx)-ystd(:,:,idx)-cmin)/(cmax-cmin))/2;
                else
                    AvgT(:,1) = ya-axHgt/4 + axHgt*((Avg(:,lstW1(idx))-ystd(:,lstW1(idx))-cmin)/(cmax-cmin))/2;
                    AvgT(:,2) = ya-axHgt/4 + axHgt*((Avg(:,lstW1(idx))-ystd(:,lstW2(idx))-cmin)/(cmax-cmin))/2;
                end
                h(idx,1)=plot( xT, AvgT(:,1), 'linewidth',0.5,'color',color(1,:),'linestyle',':');
                if size(AvgT,2)>1
                    h(idx,2)=plot( xT, AvgT(:,2), 'linewidth',0.5,'color',color(2,:),'linestyle',':');
                end
                if size(AvgT,2)>2
                    h(idx,3)=plot( xT, AvgT(:,3), 'linewidth',0.5,'color',color(3,:),'linestyle',':');
                end
                
                if ndims(Avg)==3
                    AvgT = ya-axHgt/4 + axHgt*((Avg(:,:,idx)+ystd(:,:,idx)-cmin)/(cmax-cmin))/2;
                else
                    AvgT(:,1) = ya-axHgt/4 + axHgt*((Avg(:,lstW1(idx))+ystd(:,lstW1(idx))-cmin)/(cmax-cmin))/2;
                    AvgT(:,2) = ya-axHgt/4 + axHgt*((Avg(:,lstW1(idx))+ystd(:,lstW2(idx))-cmin)/(cmax-cmin))/2;
                end
                h(idx,1)=plot( xT, AvgT(:,1), 'linewidth',0.5,'color',color(1,:),'linestyle',':');
                if size(AvgT,2)>1
                    h(idx,2)=plot( xT, AvgT(:,2), 'linewidth',0.5,'color',color(2,:),'linestyle',':');
                end
                if size(AvgT,2)>2
                    h(idx,3)=plot( xT, AvgT(:,3), 'linewidth',0.5,'color',color(3,:),'linestyle',':');
                end
            end
                

            % Record line graphics properties based on the object type
            [lc,lv,lw,ls] = setLineProperties(lc,lv,lw,ls,idx,mlAct,color,nDataTypes,nTSteps);
            
        end

        % After plotting all the data, modify lines colors, styles, and width
        for idx=1:length(lstW1)
            for j=1:size(h,2)
                set(h(idx,j),'color',lc(idx,j,:),'linestyle',ls{idx},'linewidth',lw(idx,j),'visible',lv{idx,j});
            end
        end
    end
    
    
    % Plot the optodes on the axes
    if ~isProbeDrawn(SD)
        if ismac() || islinux()
            fs = 14;
        else
            fs = 11;
        end        
        for idx2=1:size(sPos,1)
            xa = sPos(idx2,1) - axXoff;
            ya = sPos(idx2,2) - axYoff;
            
            ht=text(xa,ya,sprintf('S%d',idx2));
            set(ht,'fontweight','bold','fontsize',fs)
            set(ht,'color',[1 0 0])
            
        end
        for idx2=1:size(dPos,1)
            xa = dPos(idx2,1) - axXoff;
            ya = dPos(idx2,2) - axYoff;
            
            ht=text(xa,ya,sprintf('D%d',idx2));
            set(ht,'fontweight','bold','fontsize',fs)
            set(ht,'color',[0 0 1])            
        end
    end
    
catch
    
    menu(sprintf('plotProbe exited with ERROR while plotting data for channel # %d',idx),'OK');
    h=[];
    
end
hold off




% ----------------------------------------------------------------------------------------
function [lc,lv,lw,ls] = setLineProperties(lc,lv,lw,ls,idx,mlAct,color,nDataTypes,nTSteps)

if mlAct(idx)==0
    ls{idx} = ':';
    for ii=1:nDataTypes
        lw(idx,ii) = 2.0;
        lc(idx,ii,:) = color(ii,:);
        lv{idx,ii} = 'off';
    end
    for ii=nDataTypes+1:nDataTypes+nTSteps
        lc(idx,ii,:) = [0 0 0];
        lv{idx,ii} = 'off';
    end
elseif mlAct(idx)==1
    ls{idx} = '-';
    for ii=1:nDataTypes
        lw(idx,ii) = 2.0;
        lc(idx,ii,:) = color(ii,:);
        lv{idx,ii} = 'on';
    end
    for ii=nDataTypes+1:nDataTypes+nTSteps
        lc(idx,ii,:) = [0 0 0];
        lv{idx,ii} = 'on';
    end
elseif mlAct(idx)==2
    ls{idx} = '-';
    for ii=1:nDataTypes
        lw(idx,ii) = 1.0;
        lc(idx,ii,:) = color(ii+nDataTypes,:);
        lv{idx,ii} = 'on';
    end
    for ii=nDataTypes+1:nDataTypes+nTSteps
        lc(idx,ii,:) = [0 0 0];
        lv{idx,ii} = 'on';
    end
end




% ------------------------------------------------------
function [y,ampMp] = offsetData(y,nCh,nDataTypes)

if nDataTypes==3
    minAmp=squeeze(min(min(y)));
    maxAmp=squeeze(max(max(y)));
elseif nDataTypes==2
    for idx=1:nCh
        minAmp(idx)=min(min(y(:,[idx idx+nCh])));
        maxAmp(idx)=max(max(y(:,[idx idx+nCh])));
    end
end

% Find amplitude mid-point 
ampDiff = maxAmp - minAmp;
ampMp   = minAmp + ampDiff/2;
for idx=1:nCh
    % Shift data midpoint to zero
    if nDataTypes==3
        y(:,:,idx) = y(:,:,idx) - ampMp(idx);
    else
        y(:,[idx idx+nCh]) = y(:,[idx idx+nCh]) - ampMp(idx);
    end
end




% ------------------------------------------------------
function b = isProbeDrawn(SD)
b = false;
nOpt = size(SD.SrcPos,1)+size(SD.DetPos,1);
hc = get(gca, 'children');
nOptDrawn = 0;
for ii=1:length(hc)
    if strcmpi(hc(ii).Type, 'Text')
        if hc(ii).String(1)=='S' || hc(ii).String(1)=='D'
            nOptDrawn = nOptDrawn+1;
        end
    end
end
if nOptDrawn==nOpt
    b = true;
end

