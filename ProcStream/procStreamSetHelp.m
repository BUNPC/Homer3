function procFunc = procStreamSetHelp(procFunc)

for ii=1:length(procFunc)
    if ~isproperty(procFunc(ii), 'funcHelp')
        procFunc(ii).funcHelp = InitHelp(0);        
    end
    if isempty(procFunc(ii).funcHelp.callstr)
        procFunc(ii).funcHelp = procStreamParseFuncHelp(procFunc(ii));
    end
end

