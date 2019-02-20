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
function DisplayAxesSDG()
global hmr
dataTree = hmr.dataTree;
guiControls = hmr.guiControls;
axesSDG = guiControls.axesSDG;
procElem = dataTree.currElem;

% This function plots the prove geometry
% Command line call:
% plotAxes_SDG(guidata(gcbo),bool);
%

hAxesSDG    = axesSDG.handles.axes;
iCh         = axesSDG.iCh;
iSrcDet     = axesSDG.iSrcDet;
color       = axesSDG.linecolor;
SD          = procElem.GetSDG();
ch          = procElem.GetMeasList();
bbox        = procElem.GetSdgBbox();
procResult  = procElem.procStream.output;

nSrcs       = size(SD.SrcPos,1);
nDets       = size(SD.DetPos,1);


if ~ishandles(hAxesSDG)
    return;
end

axes(hAxesSDG);
cla
axis(hAxesSDG, [bbox(1), bbox(2), bbox(3), bbox(4)]);

set(gca, 'xticklabel','')
set(gca, 'yticklabel','')
set(gca, 'ygrid','off')

edgecol = 'none';
if ismac() || islinux()
	fs = 12;
else
	fs = 10;
end

% get procResult and replace MeasListAct if it exists

lst   = find(ch.MeasList(:,1)>0);
ml    = ch.MeasList(lst,:);
lstML = find(ml(:,4)==1); %cw6info.displayLambda);

lst2 = find(ch.MeasListAct(1:length(lstML))==0);
for ii=1:length(lst2)
    h = line2(SD.SrcPos(ml(lstML(lst2(ii)),1),:), SD.DetPos(ml(lstML(lst2(ii)),2),:));
    set(h, 'color',[1 .85 .85]*1);
    set(h, 'linewidth',6);
    set(h, 'ButtonDownFcn',get(hAxesSDG,'ButtonDownFcn'));
end

lst2 = find(ch.MeasListAct(1:length(lstML))==1);
for ii=1:length(lst2)
    h = line2(SD.SrcPos(ml(lstML(lst2(ii)),1),:), SD.DetPos(ml(lstML(lst2(ii)),2),:));
    set(h, 'color',[1 1 1]*.85);
    set(h, 'linewidth',4);
    set(h, 'ButtonDownFcn',get(hAxesSDG,'ButtonDownFcn'));
end

if isproperty(procResult,'SD')
    if isproperty(procResult.SD,'MeasListActAuto')
        lst2 = find(procResult.SD.MeasListActAuto(1:length(lstML))==0);
        for ii=1:length(lst2)
            h = line2(SD.SrcPos(ml(lstML(lst2(ii)),1),:), SD.DetPos(ml(lstML(lst2(ii)),2),:));
            set(h, 'color',[1 1 .85]*1);
            set(h, 'linewidth',6);
            set(h, 'ButtonDownFcn',get(hAxesSDG,'ButtonDownFcn'));
        end
    end
end


% DRAW PLOT LINES
% THESE LINES HAVE TO BE THE LAST
% ITEMS ADDED TO THE AXES
% FOR CHANNEL TOGGLING TO WORK WITH
% cw6_sdgToggleLines()
if ~isempty(iSrcDet) && iSrcDet(1,1)~=0
    lst2 = [];
    lst3 = find(ch.MeasList(:,4)==1);
    for ii=1:length(iCh);
        lst2(ii) = find(ch.MeasList(lst3,1)==ch.MeasList(iCh(ii),1) & ...
                        ch.MeasList(lst3,2)==ch.MeasList(iCh(ii),2) );
    end
    iCh2 = lst2;
    
    for idx=size(iSrcDet,1):-1:1
        h = line2(SD.SrcPos(iSrcDet(idx,1),:), SD.DetPos(iSrcDet(idx,2),:));
        set(h,'color',color(idx,:));
        set(h,'ButtonDownFcn',sprintf('toggleLinesAxesSDG_ButtonDownFcn(gcbo,[%d],guidata(gcbo))',idx));
        set(h,'linewidth',2);
        if ~isempty(iCh) && ...
           (~ch.MeasListAct(iCh2(idx)) & ~ch.MeasListVis(iCh2(idx)))
            set(h,'linewidth',2);
            set(h,'linestyle','-.');
        else               
            if ~isempty(iCh) && ~ch.MeasListAct(iCh2(idx))
                set(h,'linewidth',2);
                set(h,'linestyle','--');
            end
            if ~isempty(iCh) && ~ch.MeasListVis(iCh2(idx))
                set(h,'linewidth',1);
                set(h,'linestyle',':');
            end
        end
    end
end

% ADD SOURCE AND DETECTOR LABELS
for idx=1:nSrcs
    if ~isempty(find(ch.MeasList(:,1)==idx))
        h = text( SD.SrcPos(idx,1), SD.SrcPos(idx,2), sprintf('%d', idx), 'fontsize',fs, 'fontweight','bold', 'color','r' );
        set(h, 'ButtonDownFcn',get(hAxesSDG,'ButtonDownFcn'), 'horizontalalignment','center', 'edgecolor',edgecol);
    end
end
for idx=1:nDets
    if ~isempty(find(ch.MeasList(:,2)==idx))
        h = text( SD.DetPos(idx,1), SD.DetPos(idx,2), sprintf('%d', idx), 'fontsize',fs, 'fontweight','bold', 'color','b' );
        set(h, 'ButtonDownFcn',get(hAxesSDG,'ButtonDownFcn'), 'horizontalalignment','center', 'edgecolor',edgecol);
    end
end

h=zoom;
setAllowAxesZoom(h, hAxesSDG, 0);


