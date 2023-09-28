function DisplayExcludedTime(handles, hAxes, ml, iCh, chVis, linecolors)
global maingui

if get(handles.checkboxShowExcludedTimeManual, 'value')
    mode = 'manual';
elseif get(handles.checkboxShowExcludedTimeAuto, 'value')
    mode = 'auto';
elseif get(handles.checkboxShowExcludedTimeAutoByChannel, 'value')
    mode = 'autoch';
else
    mode = 'off';
end

if strcmp(mode, 'off')
    return;
end

% Check to make sure data type is timecourse data
if GetDatatype(handles) == maingui.buttonVals.OD_HRF
    return;
end
if GetDatatype(handles) == maingui.buttonVals.CONC_HRF
    return;
end
if GetDatatype(handles) == maingui.buttonVals.RAW || GetDatatype(handles) == maingui.buttonVals.OD 
    iDataType = get(handles.listboxPlotWavelength,'value');
else
    iDataType = get(handles.listboxPlotConc,'value');
end
if GetDatatype(handles) == maingui.buttonVals.CONC_HRF
    return;
end

% Patch in some versions of matlab messes up the renderer, that is it changes the 
% renderer property. Therefore we save current renderer before patch to
% restore it to what it was to pre-patch time. 
renderer = get(get(hAxes, 'parent'), 'renderer');
axes(hAxes);
hold(hAxes,'on');

% GetDataBlocksIdxs() needs to be fixed if we ever use multiple data blocks. For now 
% set iDataBlks simply to 1. JD, 09/09/2022
% iDataBlks = maingui.dataTree.currElem.GetDataBlocksIdxs(iCh);
iDataBlks = 1;

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
    
    for ii = 1:length(iCh)
        k = find(chVis(:,1) == ml(iCh(ii),1) & chVis(:,2) == ml(iCh(ii),2));
        if ~isempty(k)
            if chVis(k,3) == false
                continue
            end
        end
        
        t = maingui.dataTree.currElem.GetTime(iBlk);
        if isvector(tInc)
            kk = 1;
            col = [1.00, 0.00, 0.00];
        else
            kk = find(tInc(end-3,:) == ml(iCh(ii),1) & tInc(end-2,:) == ml(iCh(ii),2) & tInc(end,:) == iDataType);
            col = linecolors(ii,:);
        end
        if kk>size(tInc,2)
            break
        end
        
        [h, tPtsExclTot] = drawPatches(t, tInc(1:length(t), kk), tPtsExclTot, col, handles);        
        if strcmp(mode,'manual')
            for jj = 1:length(h)
                set(h(jj), 'ButtonDownFcn', sprintf('PatchCallback(%d)',jj));
            end
        end
    end

end

% Restore previous renderer
hold(hAxes,'off');
set(get(hAxes,'parent'), 'renderer', renderer);



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
    for ii = 1:size(p,1)
        h(ii) = patch(handles.axesData, [p(ii,1) p(ii,2) p(ii,2) p(ii,1) p(ii,1)], [yy(1) yy(1) yy(2) yy(2) yy(1)], col, ...
                      'facealpha',0.4, 'edgecolor','none');
    end
    set(handles.axesData, 'ylim',[yy(1), yy(2)]);
    tPtsExclTot = [tPtsExclTot(:)', tPtsExcl(:)'];
end



% -------------------------------------------------------------------------
function col = setColor(hAxes, mode, iCh)
global maingui

% Set patches color based on figure renderer

if strcmp(get(get(hAxes, 'parent'),'renderer'),'zbuffer')
    if strcmp(mode,'auto')
        col = [1.0 0.1 0.1];
    elseif strcmp(mode,'autoch')
        col = maingui.axesSDG.SDPairColors(iCh,:);
        for ii = 1:length(col)
            if col(ii)<.5
                col(ii) = col(ii)+.1;
            else
                col(ii) = col(ii)-.1;
            end
        end
    else
        col = [1.0 0.3 0.8];
    end
else
    if strcmp(mode,'auto')
        col = [1.0 0.0 0.0];
    elseif strcmp(mode,'autoch')
        col = maingui.axesSDG.SDPairColors(iCh,:);
    else
        col = [1.0 0.0 1.0];
    end
end

