function DisplayDataRawOrOD(t, d, dStd, wl, ch, chLst, nTrials, condition, linecolor, linestyle)

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
if ~exist('chLst','var')
    chLst = 1;
end
if ~exist('nTrials','var')
    nTrials = [];
end
if ~exist('condition','var')
    condition = 1;
end
if ~exist('linecolor','var')
    linecolor = rand(length(chLst),3);
end
if ~exist('linestyle','var')
    linestyle = {'-',':','--'};
end

% Error check args
if isempty(t) || isempty(d) || isempty(wl) || isempty(ch) || isempty(chLst)
    return;
end
if ~isempty(dStd) && (isempty(nTrials) || isempty(condition))
    return;
end
linewidth = [2,1.2,2,2,2,2];

for iWl=1:length(wl)
    for ii=1:length(ch(chLst))
        dWlMl = squeeze(d( :, ch(chLst(ii)), wl(iWl)));
        h     = plot(t,dWlMl);
        
        set(h, 'color',  linecolor(chLst(ii),:));
        set(h, 'linestyle', linestyle{wl(iWl)});
        set(h, 'linewidth', linewidth(wl(iWl)));
        
        if ~isempty(dStd)
            dWlMlStd    = squeeze(dStd( :, ch(chLst(ii)), wl(iWl)));
            dWlMlStdErr = dWlMlStd./sqrt(nTrials(condition));
            idx         = 1:10:length(t);
            h2          = errorbar(t(idx), dWlMl(idx), dWlMlStdErr(idx),'.');
            set(h2,'color',linecolor(chLst(ii),:));
        end
    end
end
