function DisplayCondLegend(hLg, idxLg)
global hmr

if ishandles(hLg)
    legend(hLg, hmr.group.CondNames(idxLg));
end
