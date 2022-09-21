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
function DisplayAxesSDG(handles)
global maingui
global UNIT_TEST

tic;

if ~exist('handles','var')
    handles = [];
end

% This function plots the probe geometry
% Command line call:
% plotAxes_SDG(guidata(gcbo),bool);
%
if isempty(handles)
    maingui.axesSDG = InitAxesSDG(handles);
end
hAxes        = maingui.axesSDG.handles.axes;
iCh          = maingui.axesSDG.iCh;
iSrcDet      = maingui.axesSDG.iSrcDet;
SDPairColors = maingui.axesSDG.SDPairColors;
iWl_gui      = GetWl(handles);

SD          = maingui.dataTree.currElem.GetSDG('2D');

if isfield(maingui.axesSDG, 'xlim')
    xbox        = maingui.axesSDG.xlim;
    ybox        = maingui.axesSDG.ylim;
    bbox        = [xbox(1), xbox(2), ybox(1), ybox(2)];
else
    bbox        = maingui.dataTree.currElem.GetSdgBbox();
end

% Set axes handle properties and parameters 
if ~ishandles(hAxes)
    return;
end
if length(bbox)<4
    return;
end

% Set gca to be SDG axes
axes(hAxes);

% Delete all channel lines drawn
if ishandles(maingui.axesSDG.handles.ch) && (maingui.axesSDG.handles.axes == hAxes)
    delete(maingui.axesSDG.handles.ch)
    delete(findobj(hAxes, 'Type', 'line'))  % Prevents previously drawn lines from piling up
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
nDataBlks = maingui.dataTree.currElem.GetDataBlocksNum();
MeasList = [];
MeasListActMan = [];
MeasListActAuto = [];
MeasListVis = [];
for iBlk = 1:nDataBlks
    ch              = maingui.dataTree.currElem.GetMeasList(iBlk);
    chVis           = maingui.dataTree.currElem.GetMeasListVis(iBlk);
    MeasList        = [MeasList; ch.MeasList];
    MeasListActMan  = [MeasListActMan; ch.MeasListActMan];
    MeasListActAuto = [MeasListActAuto; ch.MeasListActAuto];
    MeasListVis     = [MeasListVis; chVis];
end
ml    = MeasList(MeasList(:,1)>0,:);
lstSDPairs = find(ml(:,4)==iWl_gui); %cw6info.displayLambda);
lstInvisible = find(MeasListVis(:,3)==0);
hCh = zeros(length(lstSDPairs),1);


LINESTYLE_MAN_EXCL = ':';
LINESTYLE_AUTO_EXCL = '--';
LINESTYLE_MAN_AND_AUTO_EXCL = '-.';

% Draw all channels
for ii = 1:length(lstSDPairs)
    hCh(ii) = line2(SD.SrcPos(ml(lstSDPairs(ii),1),:), SD.DetPos(ml(lstSDPairs(ii),2),:), [], gridsize, hAxes);
    
    col = [1.00 1.00 1.00] * 0.85;
    linestyle = '-';
    linewidth = 3;
    
    % Draw auto-excluded channel
    k1 = find( (MeasListActMan(:,1) == ml(lstSDPairs(ii),1))  &  (MeasListActMan(:,2) == ml(lstSDPairs(ii),2))  &  (MeasListActMan(:,4) == ml(lstSDPairs(ii),4)) );
    k2 = find( (MeasListActAuto(:,1) == ml(lstSDPairs(ii),1))  &  (MeasListActAuto(:,2) == ml(lstSDPairs(ii),2))  &  (MeasListActAuto(:,4) == ml(lstSDPairs(ii),4)) );

    if (~isempty(k1) && MeasListActMan(k1,3) == 0) && (~isempty(k2) && MeasListActAuto(k2,3) == 0)
        col = [1.00 0.6 0.6];
        linestyle = LINESTYLE_MAN_AND_AUTO_EXCL;
    elseif ~isempty(k1) &&  MeasListActMan(k1,3) == 0
        col = [1.00 1.00 1.00] * 0.85;
        linestyle = LINESTYLE_MAN_EXCL;
    elseif ~isempty(k2) && MeasListActAuto(k2,3) == 0
        col = [1.00 0.6 0.6];
        linestyle = LINESTYLE_AUTO_EXCL;
    end

    if ismember(ii, lstInvisible)
        linewidth = 1; 
    end
    
    set(hCh(ii), 'color',col, 'linewidth',linewidth, 'ButtonDownFcn',bttndownfcn, 'linestyle',linestyle);
end


% Draw the user-selected channels
for idx = 1:size(iSrcDet,1)
    hCh(idx+ii) = line2(SD.SrcPos(iSrcDet(idx,1),:), SD.DetPos(iSrcDet(idx,2),:), [], gridsize, hAxes);
    
    % Attach toggle callback to the selected channels for function on
    % second click
    iSD = GetSelectedSDPairIndex( iSrcDet(idx,1), iSrcDet(idx,2) );
    set(hCh(idx+ii), 'color',SDPairColors(iSD,:), 'ButtonDownFcn',sprintf('toggleLinesAxesSDG_ButtonDownFcn(gcbo,[%d],guidata(gcbo))',idx), 'linewidth',2);
    
    linestyle = '-';
    linewidth = 3;
    if ~isempty(iCh)
        k1 = find( (MeasListActMan(:,1)==iSrcDet(idx,1))  &  (MeasListActMan(:,2)==iSrcDet(idx,2))  &  (MeasListActMan(:,4)==iWl_gui) );
        k2 = find( (MeasListActAuto(:,1)==iSrcDet(idx,1))  &  (MeasListActAuto(:,2)==iSrcDet(idx,2)) &  (MeasListActMan(:,4)==iWl_gui) );
        k3 = find( (MeasListVis(:,1) == iSrcDet(idx,1))  &  (MeasListVis(:,2) == iSrcDet(idx,2)));
        
        if (~isempty(k1) && MeasListActMan(k1,3) == 0) && (~isempty(k2) && MeasListActAuto(k2,3) == 0)
            linestyle = LINESTYLE_MAN_AND_AUTO_EXCL;
        elseif ~isempty(k1) &&  MeasListActMan(k1,3) == 0
            linestyle = LINESTYLE_MAN_EXCL;
        elseif ~isempty(k2) && MeasListActAuto(k2,3) == 0
            linestyle = LINESTYLE_AUTO_EXCL;
        end
                
        if ~isempty(k3) && MeasListVis(k3,3) == 0
            linewidth = 1;
        end
    end
    set(hCh(idx+ii),'linewidth', linewidth, 'linestyle',linestyle);    
end

if (maingui.axesSDG.handles.axes == hAxes)
    maingui.axesSDG.handles.ch = hCh;
end

% ADD SOURCE AND DETECTOR LABELS
hSD = zeros(nSrcs+nDets,1);
if isempty(maingui.axesSDG.handles.SD) || (maingui.axesSDG.handles.axes ~= hAxes)
    for idx1 = 1:nSrcs
        if ~isempty(find(MeasList(:,1)==idx1)) %#ok<*EFIND>
            hSD(idx1) = text( SD.SrcPos(idx1,1), SD.SrcPos(idx1,2), sprintf('%d', idx1), 'fontsize',fs, 'fontweight','bold', 'color','r' );
            set(hSD(idx1), 'ButtonDownFcn',get(hAxes,'ButtonDownFcn'), 'horizontalalignment','center', 'edgecolor',edgecol, 'Clipping', 'on');
        end
    end
    for idx2 = 1:nDets
        if ~isempty(find(MeasList(:,2)==idx2))
            hSD(idx2+idx1) = text( SD.DetPos(idx2,1), SD.DetPos(idx2,2), sprintf('%d', idx2), 'fontsize',fs, 'fontweight','bold', 'color','b' );
            set(hSD(idx2+idx1), 'ButtonDownFcn',get(hAxes,'ButtonDownFcn'), 'horizontalalignment','center', 'edgecolor',edgecol, 'Clipping', 'on');
        end
    end
    if (maingui.axesSDG.handles.axes == hAxes)
        maingui.axesSDG.handles.SD = hSD;
    end
else
    uistack(nonzeros(maingui.axesSDG.handles.SD),'top')
end

% Turn off zoom but only for SDG axes
h = zoom(hAxes);
if isempty(UNIT_TEST) || ~UNIT_TEST
    setAllowAxesZoom(h, hAxes, 0);
end

% fprintf('DisplayAxesSDG: Elapsed Time - %0.3f\n', toc);


