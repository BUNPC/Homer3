function proclevel = GetProclevel(handles)
global maingui

proclevel = 0;
bttnG = get(handles.radiobuttonProcTypeGroup, 'value');
bttnS = get(handles.radiobuttonProcTypeSubj, 'value');
bttnR = get(handles.radiobuttonProcTypeRun, 'value');

bttn='';
if bttnG
    bttn = 'radiobuttonProcTypeGroup' ;
elseif bttnS
    bttn = 'radiobuttonProcTypeSubj';
elseif bttnR
    bttn = 'radiobuttonProcTypeRun';
end

if strcmp(bttn, 'radiobuttonProcTypeGroup')
    proclevel = maingui.gid;
elseif strcmp(bttn, 'radiobuttonProcTypeSubj')
    proclevel = maingui.sid;
elseif strcmp(bttn, 'radiobuttonProcTypeRun')
    proclevel = maingui.rid;
end

