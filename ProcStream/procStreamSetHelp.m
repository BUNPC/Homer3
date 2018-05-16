function procFunc = procStreamSetHelp(procFunc)

for ii=1:length(procFunc)
    procFunc(ii).funcHelp = procStreamParseFuncHelp(procFunc(ii));
end

