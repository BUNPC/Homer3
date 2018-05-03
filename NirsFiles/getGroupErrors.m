function [N err] = getGroupErrors(N, type)
global err
err = 0;

switch(type)
    
case {'group','grp'}

    N.err = 0;
    if ~isfield(N, 'name')
        N.err = 1;
        err = 1;
    end
    for ii=1:length(N.subjs)
        N.subjs(ii).err = 0;
        N.subjs(ii) = getGroupErrors(N.subjs(ii), 'subj');
    end

case {'subj','subject'}

    if ~isfield(N, 'name')
        N.err = 1;
        err = 1;
    end
    for ii=1:length(N.runs)
        N.runs(ii).err = 0; 
        N.runs(ii) = getGroupErrors(N.runs(ii), 'run');
    end

case {'run'}

    if ~isfield(N, 'name')
        N.err = 1;
        err = 1;
    end
   
end
