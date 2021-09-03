function DisplayDataRawOrOD(hAxes, t, d, dStd, wl, ch, nTrials, condition, linecolor, linestyle)

% Parse args
if ~exist('t','var')
    t = [];
end
if ~exist('d','var')
    d = [];
end
if ~exist('dStd','var')
    dStd = [];
end
if ~exist('wl','var')
    wl = 1;
end
if ~exist('ch','var')
    ch = 1;
end
if ~exist('nTrials','var')
    nTrials = [];
end
if ~exist('condition','var')
    condition = 1;
end
if ~exist('linecolor','var')
    linecolor = rand(length(ch),3);
end
if ~exist('linestyle','var')
    linestyle = {'-',':','--'};
end

% Error check args
if isempty(t) || isempty(d) || isempty(wl) || isempty(ch)
    return;
end
if ~isempty(dStd) && (isempty(nTrials) || isempty(condition))
    return;
end
linewidth = [2,2,2,2,2,2];  % Note this is a hard-coded max of 6 wl

for iWl = 1:size(wl, 2)
    chLstWl = ch(wl(:, iWl));  % Get only channel list for this wl
    for i = 1:length(chLstWl)
        dWlMl = d(:, chLstWl(i));
        h     = plot(hAxes, t, dWlMl);
        
        set(h, 'color',  linecolor(i, :));
        set(h, 'linestyle', linestyle{iWl});
        set(h, 'linewidth', linewidth(iWl));
        
        if ~isempty(dStd)
            dWlMlStd    = dStd(:, chLstWl(i));
            dWlMlStdErr = dWlMlStd./sqrt(nTrials(condition));
            idx         = 1:10:length(t);
            h2          = errorbar(hAxes, t(idx), dWlMl(idx), dWlMlStdErr(idx),'.');
            set(h2,'color',linecolor(i, :));
        end
    end
end
