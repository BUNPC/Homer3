function DisplayCondLegend(hLg, idxLg)
global hmr

[idxLg, k] = sort(idxLg);
if ishandles(hLg)
    legend(hLg(k), hmr.group.CondNames(idxLg));
end
