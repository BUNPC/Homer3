function funcDescr = procStreamGenHelpFunc(funcName)

funcDescr{1} = {''};
helpstr = help(funcName);
if isempty(helpstr)
    return;
end
funcDescr = textscan(helpstr, '%s', 'delimiter', sprintf('\r'));

for iLine=1:size(funcDescr{1},1)
    k=findstr(funcDescr{1}{iLine},'''');
    
    % if there are single quotes in the funcDescr then add one more single
    % quote so that when it is written out in literal form it will be in
    % matlab compatible string format.
    funcDescrLineNew = '';
    j=1;
    for i=1:length(k)
        funcDescrLineNew = [funcDescrLineNew funcDescr{1}{iLine}(j:k(i)-1) ''''''];
        j=k(i)+1;
    end
    if ~isempty(funcDescrLineNew)
        funcDescr{1}{iLine} = funcDescrLineNew;
    end
end
