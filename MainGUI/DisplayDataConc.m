function DisplayDataConc(hAxes, t, d, dStd, hbType, ch, chLst, nTrials, condition, linecolor, linestyle)

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
if ~exist('hbType','var')
    hbType = 1;
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
    linestyle = {'-','--',':'};
end
linewidth = [2,2,2.5];

% Error check args
if isempty(t) || isempty(d) || isempty(hbType) || isempty(ch) || isempty(chLst)
    return;
end
if ~isempty(dStd) && (isempty(nTrials) || isempty(condition))
    return;
end

for iHb=1:length(hbType)
    for ii=length(ch(chLst)):-1:1
        dHbMl = squeeze(d(:, hbType(iHb), ch(chLst(ii))));
        h     = plot(hAxes, t, dHbMl);
        
        % fprintf('Plotting channel: %d, color: [%0.1f, %0.1f, %0.1f]\n', chLst(ii), linecolor(chLst(ii),:));
        set(h, 'color', linecolor(chLst(ii),:));
        set(h, 'linewidth', linewidth(hbType(iHb)));
        set(h, 'linestyle', linestyle{hbType(iHb)});
        
        if ~isempty(dStd)
            dHbMlStd    = squeeze(dStd( :, hbType(iHb), ch(chLst(ii)), condition));
%             dHbMlStdErr = dHbMlStd./sqrt(nTrials(condition));
            idx         = [1:10:length(t)];
            h2          = errorbar(hAxes, t(idx), dHbMl(idx), dHbMlStd(idx),'.');
            set(h2,'color',linecolor(chLst(ii),:));
        end
    end
end

