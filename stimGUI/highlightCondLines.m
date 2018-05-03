function highlightCondLines(Cn,mode)
global stim

condColor = stim.CondColTbl(Cn,1:3);
for ii=1:length(stim.Lines)
    if(all(condColor == stim.Lines(ii).color) & mode)
        set(stim.Lines(ii).handle,'linewidth',stim.linewidthHighl);
    else
        set(stim.Lines(ii).handle,'linewidth',stim.linewidthReg);
    end
end
