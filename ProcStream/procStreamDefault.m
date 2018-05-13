function [procFunc, procParam] = procStreamDefault(type)

procParam = struct([]);
procFunc = repmat(InitProcFunc(),0,1);
switch(type)
    case 'group'
        [~, filecontents_str] = procStreamDefaultFileGroup();
    case 'subj'
        [~, filecontents_str] = procStreamDefaultFileSubj();        
    case 'run'
        [~, filecontents_str] = procStreamDefaultFileRun();        
end

S = textscan(filecontents_str,'%s');
[procFunc, procParam] = parseSection(S{1});

