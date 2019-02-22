function proctype = getProctype(guiControls)

proctype = 0;
bttnG = get(guiControls.handles.radiobuttonProcTypeGroup, 'value');
bttnS = get(guiControls.handles.radiobuttonProcTypeSubj, 'value');
bttnR = get(guiControls.handles.radiobuttonProcTypeRun, 'value');

bttn='';
if bttnG
    bttn = 'radiobuttonProcTypeGroup' ;
elseif bttnS
    bttn = 'radiobuttonProcTypeSubj';
elseif bttnR
    bttn = 'radiobuttonProcTypeRun';
end

if strcmp(bttn, 'radiobuttonProcTypeGroup')
    proctype = 1;
elseif strcmp(bttn, 'radiobuttonProcTypeSubj')
    proctype = 2;
elseif strcmp(bttn, 'radiobuttonProcTypeRun')
    proctype = 3;
end
