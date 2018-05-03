function DisplayDataConc(t, d, dStd, hbType, ch, chLst, nTrials, condition, linecolor, linestyle)

linewidth = [2,2,4];

for iHb=1:length(hbType)
    for ii=length(ch(chLst)):-1:1
        dHbMl = squeeze(d(:, hbType(iHb), ch(chLst(ii))));
        h     = plot(t, dHbMl);
        
        set(h, 'color', linecolor(chLst(ii),:));
        set(h, 'linewidth', linewidth(hbType(iHb)));
        set(h, 'linestyle', linestyle{hbType(iHb)});
        
        if ~isempty(dStd)
            dHbMlStd    = squeeze(dStd( :, hbType(iHb), ch(chLst(ii)) ));
            dHbMlStdErr = dHbMlStd./sqrt(nTrials(condition));
            idx         = [1:10:length(t)];
            h2          = errorbar(t(idx), dHbMl(idx), dHbMlStdErr(idx),'.');
            set(h2,'color',linecolor(chLst(ii),:));
        end
    end
end
