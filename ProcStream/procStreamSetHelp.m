function func = procStreamSetHelp(func)

for ii=1:length(func)
    if ~isproperty(func(ii), 'help')
        func(ii).help = InitHelp(0);        
    end
    if isempty(func(ii).help.callstr)
        func(ii).help = procStreamParseFuncHelp(func(ii));
    end
end

