function currElem = LoadCurrElem(currElem, group, files, iSubj, iRun)

if exist('iSubj','var') & exist('iRun','var')
    iFile = MapGroup2File(files, iSubj, iRun);
    set(currElem.handles.listboxFiles,'value',iFile);
end

currElem.iFile = get(currElem.handles.listboxFiles,'value');
iSubj = files(currElem.iFile).map2group.iSubj;
iRun = files(currElem.iFile).map2group.iRun;

% iSubj==0 means the file chosen is a group directory - no 
% subject or run processing allowed for the corresponding 
% group tree element
if iSubj==0

    set(currElem.handles.radiobuttonProcTypeSubj,'enable','off');
    set(currElem.handles.radiobuttonProcTypeRun,'enable','off');
    set(currElem.handles.radiobuttonProcTypeGroup,'value',1);

% iRun==0 means the file chosen is a subject directory - no single 
% run processing allowed for the corresponding group tree element
elseif iSubj>0 && iRun==0

    set(currElem.handles.radiobuttonProcTypeSubj,'enable','on');
    set(currElem.handles.radiobuttonProcTypeRun,'enable','off');

    % Don't change the value of the button group unless it is  
    % currently set to an illegal value
    if currElem.procType==3
        set(currElem.handles.radiobuttonProcTypeSubj,'value',1);
    end

% iRun==0 means the file chosen is a subject directory - no single 
% run processing allowed for the corresponding group tree element
elseif iSubj>0 && iRun>0

    set(currElem.handles.radiobuttonProcTypeSubj,'enable','on');
    set(currElem.handles.radiobuttonProcTypeRun,'enable','on');

end

currElem = getProcType(currElem);

if currElem.procType==1
    currElem.procElem = group;
elseif currElem.procType==2
    currElem.procElem = LoadCurrSubj(group, iSubj);
elseif currElem.procType==3
    currElem.procElem = LoadCurrRun(group, iSubj, iRun);
end

currElem.iSubj = iSubj;
currElem.iRun = iRun;


