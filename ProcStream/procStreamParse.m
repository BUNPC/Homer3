function [procInput, err, errstr] = procStreamParse(fid_or_str, procElem)

%
% Processing stream config file parser. This function handles
% group, subj and run processing stream parameters
%

procInput = ProcInputClass();
err=0;
errstr='';

if ~exist('procElem','var')
    procElem = [];
end

[G, S, R] = procStreamPreParse(fid_or_str, procElem);

switch(procElem.type)
case 'group'
    
    % generate default contents for group section if there's no % group header. 
    % This can happen if homer2-style config file was read    
    if isempty(G) | ~strcmpi(deblank([G{1},G{2}]), '%group')
        [~, str] = procStreamDefaultFileGroup(parseSection(R));
        foo = textscan(str, '%s');
        G = foo{1};
	end
    [procInput.func, procInput.param] = parseSection(G, procElem);
    
case 'subj'
    
    % generate default contents for subject section if scanned contents is
    % from a file and there's no % subj header. This can happen if
    % homer2-style config file was loaded
    if isempty(S) | ~strcmpi(deblank([S{1},S{2}]), '%subj')
        [~, str] = procStreamDefaultFileSubj(parseSection(R));
        foo = textscan(str, '%s');
        S = foo{1};
    end
    [procInput.func, procInput.param] = parseSection(S, procElem);
    
case 'run'
    
    [procInput.func, procInput.param] = parseSection(R, procElem);
    
end

% Lastly set the funcHelp field values for all func functions. 
procInput.func = procStreamSetHelp(procInput.func);

