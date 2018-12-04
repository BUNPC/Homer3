function DisplayDataRawOrOD(t, d, dStd, wl, ch, chLst, nTrials, condition, linecolor, linestyle)

for iWl=1:length(wl)
    for ii=1:length(ch(chLst))
        dWlMl = squeeze(d( :, ch(chLst(ii)), wl(iWl)));
        h     = plot(t,dWlMl);
        
        set(h, 'color',  linecolor(chLst(ii),:));
        set(h, 'linestyle', linestyle{wl(iWl)});
        set(h, 'linewidth', 2);
        
        if ~isempty(dStd)
            dWlMlStd    = squeeze(dStd( :, ch(chLst(ii)), wl(iWl)));
            dWlMlStdErr = dWlMlStd./sqrt(nTrials(condition));
            idx         = [1:10:length(t)];
            h2          = errorbar(t(idx), dWlMl(idx), dWlMlStdErr(idx),'.');
            set(h2,'color',linecolor(chLst(ii),:));
        end
    end
end
