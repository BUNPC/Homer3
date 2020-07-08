%$Release 4.0
% Copyright (c) Copyright 2004 - 2006 - The General Hospital Corporation and
% President and Fellows of Harvard University.
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% *       Redistributions of source code must retain the above copyright
% notice, this list of conditions and the following disclaimer.
% *       Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
% *       Neither the name of The General Hospital Corporation and Harvard
% University nor the names of its contributors may be used to endorse or
% promote products derived from this software without specific prior written
% permission.
%
% The Software has been designed for research purposes only and has not been
% reviewed or approved by the Food and Drug Administration or by any other
% agency.  YOU ACKNOWLEDGE AND AGREE THAT CLINICAL APPLICATIONS ARE NEITHER
% RECOMMENDED NOR ADVISED.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.


% --------------------------------------------------------------------
function DisplayAxesSDG(hAxes)
global maingui

tic;

% This function plots the prove geometry
% Command line call:
% plotAxes_SDG(guidata(gcbo),bool);
%
if nargin<1
    hAxes   = maingui.axesSDG.handles.axes;
end
iCh         = maingui.axesSDG.iCh;
iSrcDet     = maingui.axesSDG.iSrcDet;
color       = maingui.axesSDG.linecolor;

SD          = maingui.dataTree.currElem.GetSDG();
bbox        = maingui.dataTree.currElem.GetSdgBbox();

% Set axes handle properties and parameters 
if ~ishandles(hAxes)
    return;
end
axes(hAxes);
if ishandles(maingui.axesSDG.handles.ch)
    delete(maingui.axesSDG.handles.ch)
end
axis(hAxes, [bbox(1), bbox(2), bbox(3), bbox(4)]);
%set(hAxes, 'xticklabel','', 'yticklabel','', 'xgrid','off, ygrid','off')
set(hAxes, 'xticklabel','')
bttndownfcn = get(hAxes,'ButtonDownFcn');
gridsize = get(hAxes, {'xlim', 'ylim', 'zlim'});
edgecol = 'none';
if ismac() || islinux()
	fs = 18;
else
	fs = 11;
end

% Go through all the data blocks and plot the channels in each block   
nSrcs       = size(SD.SrcPos,1);
nDets       = size(SD.DetPos,1);

% get mlActAuto from procResult if it exists and replace ch.MeasListActMan 
% [iDataBlks, iCh] = maingui.dataTree.currElem.GetDataBlocksIdxs(iCh);
nDataBlks = maingui.dataTree.currElem.GetDataBlocksNum();
MeasList = [];
MeasListActMan = [];
MeasListActAuto = [];
MeasListVis = [];
for iBlk = 1:nDataBlks   
    ch              = maingui.dataTree.currElem.GetMeasList(iBlk);
    MeasList        = [MeasList; ch.MeasList];
    MeasListActMan  = [MeasListActMan; ch.MeasListActMan];
    MeasListActAuto = [MeasListActAuto; ch.MeasListActAuto];
    MeasListVis     = [MeasListVis; ch.MeasListVis];
end
ml    = MeasList(MeasList(:,1)>0,:);
lstML = find(ml(:,4)==1); %cw6info.displayLambda);
lwidth = 3;
lstIncl = find(MeasListActMan(1:length(lstML))==1);
lstExclMan = find(MeasListActMan(1:length(lstML))==0);
lstExclAuto = find(MeasListActAuto(1:length(lstML))==0);
hCh = zeros(length(lstML),1);

% Draw all channels
for ii = 1:length(lstML)
    hCh(ii) = line2(SD.SrcPos(ml(lstML(ii),1),:), SD.DetPos(ml(lstML(ii),2),:), [], gridsize);
    if     ismember(ii, lstIncl)
        % Draw included channel
        col = [1.00 1.00 1.00] * 0.85;
    elseif ismember(ii,lstExclMan)
        % Draw manually excluded channel
        col = [1.00 0.85 0.85] * 1.00;
    elseif ismember(ii,lstExclAuto)
        % Draw auto-excluded channel
        col = [1.00 1.00 0.85] * 1.00;
    end        
    set(hCh(ii), 'color',col, 'linewidth',lwidth, 'ButtonDownFcn',bttndownfcn);
end

% Draw the user-selected channels
if ~isempty(iSrcDet) && iSrcDet(1,1)~=0
    lst2 = zeros(1,length(iCh));
    lst3 = find(MeasList(:,4)==1);
    for ii=1:length(iCh)
        lst2(ii) = find(MeasList(lst3,1)==MeasList(iCh(ii),1) & MeasList(lst3,2)==MeasList(iCh(ii),2) );
    end
    iCh2 = lst2;
    
    for idx = 1:size(iSrcDet,1)
        hCh(idx+ii) = line2(SD.SrcPos(iSrcDet(idx,1),:), SD.DetPos(iSrcDet(idx,2),:), [], gridsize);
        set(hCh(idx+ii),'color',color(idx,:), 'ButtonDownFcn',sprintf('toggleLinesAxesSDG_ButtonDownFcn(gcbo,[%d],guidata(gcbo))',idx), 'linewidth',2);
        if ~isempty(iCh) && (~MeasListActMan(iCh2(idx)) & ~MeasListVis(iCh2(idx)))
            set(hCh(idx+ii),'linewidth',2, 'linestyle','-.');
        else
            if ~isempty(iCh) && ~MeasListActMan(iCh2(idx))
                set(hCh(idx+ii),'linewidth',2, 'linestyle','--');
            end
            if ~isempty(iCh) && ~MeasListVis(iCh2(idx))
                set(hCh(idx+ii),'linewidth',1, 'linestyle',':');
            end
        end
    end
end
maingui.axesSDG.handles.ch = hCh(hCh>0);


% ADD SOURCE AND DETECTOR LABELS
hSD = zeros(nSrcs+nDets,1);
if isempty(maingui.axesSDG.handles.SD)
    for idx1 = 1:nSrcs
        if ~isempty(find(MeasList(:,1)==idx1)) %#ok<*EFIND>
            hSD(idx1) = text( SD.SrcPos(idx1,1), SD.SrcPos(idx1,2), sprintf('%d', idx1), 'fontsize',fs, 'fontweight','bold', 'color','r' );
            set(hSD(idx1), 'ButtonDownFcn',get(hAxes,'ButtonDownFcn'), 'horizontalalignment','center', 'edgecolor',edgecol);
        end
    end
    for idx2 = 1:nDets
        if ~isempty(find(MeasList(:,2)==idx2))
            hSD(idx2+idx1) = text( SD.DetPos(idx2,1), SD.DetPos(idx2,2), sprintf('%d', idx2), 'fontsize',fs, 'fontweight','bold', 'color','b' );
            set(hSD(idx2+idx1), 'ButtonDownFcn',get(hAxes,'ButtonDownFcn'), 'horizontalalignment','center', 'edgecolor',edgecol);
        end
    end
    maingui.axesSDG.handles.SD = hSD;
else
    uistack(maingui.axesSDG.handles.SD,'top')
end

% Turn off zoom but only for SDG axes
h=zoom;
setAllowAxesZoom(h, hAxes, 0);

% fprintf('DisplayAxesSDG: Elapsed Time - %0.3f\n', toc);