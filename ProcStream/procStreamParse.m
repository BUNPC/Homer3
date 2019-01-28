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

[G, S, R] = procInput.PreParse(fid_or_str, class(procElem));

switch(procElem.type)
case 'group'
    
    % generate default contents for group section if there's no % group header. 
    % This can happen if homer2-style config file was read    
    if isempty(G) | ~strcmpi(strtrim([G{1},G{2}]), '%group')
        [~, str] = procInput.DefaultFileGroup(procInput.Parse(R));
        foo = textscan(str, '%s');
        G = foo{1};
	end
    procInput.Parse(G);
case 'subj'
    
    % generate default contents for subject section if scanned contents is
    % from a file and there's no % subj header. This can happen if
    % homer2-style config file was loaded
    if isempty(S) | ~strcmpi(strtrim([S{1},S{2}]), '%subj')
        [~, str] = procInput.DefaultFileSubj(procInput.Parse(R));
        foo = textscan(str, '%s');
        S = foo{1};
    end
    procInput.Parse(S);
    
case 'run'
    
    procInput.Parse(R);
    
end

% Lastly set the help field values for all func functions. 
procInput.SetHelp();

