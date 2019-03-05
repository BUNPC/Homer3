function proclevel = getProclevel(handles)
global hmr

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
    proclevel = hmr.gid;
elseif strcmp(bttn, 'radiobuttonProcTypeSubj')
    proclevel = hmr.sid;
elseif strcmp(bttn, 'radiobuttonProcTypeRun')
    proclevel = hmr.rid;
end

