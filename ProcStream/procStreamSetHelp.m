function func = procStreamSetHelp(func)

for ii=1:length(func)
    if ~isproperty(func(ii), 'funcHelp')
        func(ii).funcHelp = InitHelp(0);        
    end
    if isempty(func(ii).funcHelp.callstr)
        func(ii).funcHelp = procStreamParseFuncHelp(func(ii));
    end
end

