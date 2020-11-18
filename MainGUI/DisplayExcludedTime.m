function DisplayExcludedTime(handles, mode, hAxes)
global maingui

% Check to make sure data type is timecourse data
if GetDatatype(handles) == maingui.buttonVals.OD_HRF
    return;
end
if GetDatatype(handles) == maingui.buttonVals.CONC_HRF
    return;
end


% Patch in some versions of matlab messes up the renderer, that is it changes the 
% renderer property. Therefore we save current renderer before patch to
% restore it to what it was to pre-patch time. 
renderer = get(gcf, 'renderer');
if nargin<5
    hAxes = handles.axesData;
end 
axes(hAxes);
hold on

iCh       = maingui.axesSDG.iCh;
iDataBlks = maingui.dataTree.currElem.GetDataBlocksIdxs(iCh);
tPtsExclTot = [];
for iBlk = iDataBlks
    if strcmp(mode,'manual')
        tInc = maingui.dataTree.currElem.GetTincMan(iBlk);
    elseif strcmp(mode,'auto')
        tInc = maingui.dataTree.currElem.GetTincAuto(iBlk);
    elseif strcmp(mode,'autoch')
        tInc = maingui.dataTree.currElem.GetTincAutoCh(iBlk);        
    else
        continue
    end
    if isempty(tInc)
        continue;
    end
        
    for ii=1:length(iCh)
        if iCh(ii)>size(tInc,2)
            kk = 1;
        else
            kk = iCh(ii);
        end
        if ii>size(tInc,2)
            break
        end
        col = setColor(mode, ii);
        t = maingui.dataTree.currElem.GetTime(iBlk);
        [h, tPtsExclTot] = drawPatches(t, tInc(:, kk), tPtsExclTot, col, handles);        
        if strcmp(mode,'manual')
            for jj=1:length(h)
                set(h(jj), 'ButtonDownFcn', sprintf('PatchCallback(%d)',jj));
            end
        end
    end
end

% Restore previous renderer
hold off
set(gcf, 'renderer', renderer);



% -------------------------------------------------------------------------
function  [h, tPtsExclTot] = drawPatches(t, tInc, tPtsExclTot, col, handles)
h = [];
if ~isempty(tInc)
    % Find time points that've already been excluded from previous blocks
    % and set them to 1 in order not to redundantly exclude.
    tPtsExcl = t(tInc==0);
    j = find(ismember(tPtsExcl, tPtsExclTot));
    k = find(ismember(t, tPtsExcl(j)));
    tInc(k) = 1;
    
    % Display exclusion patches
    p = TimeExcludeRanges(tInc,t);
    yy = GetAxesYRangeForStimPlot(handles.axesData);
    for ii=1:size(p,1)
        h(ii) = patch([p(ii,1) p(ii,2) p(ii,2) p(ii,1) p(ii,1)], [yy(1) yy(1) yy(2) yy(2) yy(1)], col, ...
                      'facealpha',0.3, 'edgecolor','none');
    end
    tPtsExclTot = [tPtsExclTot(:)', tPtsExcl(:)'];
end



% -------------------------------------------------------------------------
function col = setColor(mode, iCh)
global maingui

% Set patches color based on figure renderer

if strcmp(get(gcf,'renderer'),'zbuffer')
    if strcmp(mode,'auto')
        col=[1.0 0.1 0.1];
    elseif strcmp(mode,'autoch')
        col=maingui.axesSDG.linecolor(iCh,:);
        for ii=1:length(col)
            if col(ii)<.5
                col(ii) = col(ii)+.1;
            else
                col(ii) = col(ii)-.1;
            end
        end
    else
        col=[1.0 0.3 0.8];
    end
else
    if strcmp(mode,'auto')
        col=[1.0 0.0 0.0];
    elseif strcmp(mode,'autoch')
        col=maingui.axesSDG.linecolor(iCh,:);
    else
        col=[1.0 0.0 1.0];
    end
end

