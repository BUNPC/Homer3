function DisplayExcludedTime(handles, datatype, mode, col)
global maingui

if  datatype == maingui.buttonVals.OD_HRF || datatype == maingui.buttonVals.CONC_HRF
    return;
end

if ~exist('mode','var') || isempty(mode)
    mode = 'auto';
end
if strcmp(mode,'manual') || ~exist('col')
    col = setColor(mode);
end

% Patch in some versions of matlab messes up the renderer, that is it changes the 
% renderer property. Therefore we save current renderer before patch to
% restore it to what it was to pre-patch time. 
renderer = get(gcf, 'renderer');
axes(handles.axesData);
hold on

iCh       = maingui.axesSDG.iCh;
iDataBlks = maingui.dataTree.currElem.GetDataBlocksIdxs(iCh);
tPtsExclTot = [];
for iBlk = iDataBlks
    tIncAuto = maingui.dataTree.currElem.GetTincAuto(iBlk);
    t        = maingui.dataTree.currElem.GetTime(iBlk);
    
    if isempty(tIncAuto)
        continue;
    end
    
    % Find time points that've already been excluded from previous blocks
    % and set them to 1 in order not to redundantly exclude. 
    tPtsExcl = t(tIncAuto==0);
    j = find(ismember(tPtsExcl, tPtsExclTot));
    k = find(ismember(t, tPtsExcl(j)));
    tIncAuto(k) = 1;
    
    % Display exclusion patches
    p = TimeExcludeRanges(tIncAuto,t);
    yy = GetAxesYRangeForStimPlot(handles.axesData);
    for ii=1:size(p,1)
        h = patch([p(ii,1) p(ii,2) p(ii,2) p(ii,1) p(ii,1)], [yy(1) yy(1) yy(2) yy(2) yy(1)], col, ...
            'facealpha',0.3, 'edgecolor','none' );
    end
    tPtsExclTot = [tPtsExclTot(:)', tPtsExcl(:)'];
end

% Restore previous renderer
hold off
set(gcf, 'renderer', renderer);



% -------------------------------------------------------------------------
function col = setColor(mode)

% Set patches color based on figure renderer

if strcmp(get(gcf,'renderer'),'zbuffer')
    if strcmp(mode,'auto')
        col=[1.0 0.1 0.1];
    else
        col=[1.0 0.3 0.8];
    end
else
    if strcmp(mode,'auto')
        col=[1.0 0.0 0.0];
    else
        col=[1.0 0.0 1.0];
    end
end
