function [N, err] = getGroupErrors(N, type, err)

if ~exist('err','var') || isempty(err)
    err = 0;
end
N.err = 0;

switch(type)
    
case {'group','grp'}

    if ~isfield(N, 'name')
        N.err = 1;
        err = 1;
    end
    for ii=1:length(N.subjs)
        N.subjs(ii).err = 0;
        [N.subjs(ii), err] = getGroupErrors(N.subjs(ii), 'subj', err);
    end

case {'subj','subject'}

    if ~isfield(N, 'name')
        N.err = 1;
        err = 1;
    end
    for ii=1:length(N.runs)
        N.runs(ii).err = 0;
        [N.runs(ii), err] = getGroupErrors(N.runs(ii), 'run', err);
    end

case {'run'}

    if ~isfield(N, 'name')
        N.err = 1;
        err = 1;
    end
   
end

