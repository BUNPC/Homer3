function group = SaveCurrElem(currElem, group, duration, varargin)

if ~exist('duration','var') | isempty(duration)
    duration = 'permanent';
end

iRun  =  currElem.iRun;
iSubj =  currElem.iSubj;
if strcmp(currElem.procElem.type, 'group')
    group = currElem.procElem;
    
    % Propagate whatever parameters were included in varargin, to 
    % all the elements in the group subtree - ie all the subjects 
    % and all the runs in those subjects
    for kk=1:length(varargin)
        param = varargin{kk};
        
        for ii=1:length(group.subjs)
            eval(sprintf('group.subjs(ii).%s = currElem.procElem.%s', varargin{kk}, varargin{kk}));
            for jj=1:length(group.subjs(ii).runs)
                eval(sprintf('group.subjs(ii).runs(jj).%s = currElem.procElem.%s', varargin{kk}, varargin{kk}));
            end
        end
    end
    
elseif strcmp(currElem.procElem.type, 'subj')
    group.subjs(iSubj) = currElem.procElem;

    % Propagate whatever parameters were included in varargin, to 
    % all the elements in the subject subtree - ie all the runs in this
    % subject
    for kk=1:length(varargin)
        param = varargin{kk};
        for jj=1:length(group.subjs(iSubj).runs)
            eval(sprintf('group.subjs(iSubj).runs(jj).%s = currElem.procElem.%s', varargin{kk}, varargin{kk}));
        end
    end
    
elseif strcmp(currElem.procElem.type, 'run')
    group.subjs(iSubj).runs(iRun) = SaveRun(currElem.procElem);
end

if strncmp(duration, 'perm', 4)
	save('groupResults.mat','-mat','group');
end

