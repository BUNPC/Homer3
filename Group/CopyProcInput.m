function group = CopyProcInput(group, varargin)

procInput = InitProcInput();

if nargin==2
    if isfield(varargin{1}, 'procElem')
        type = varargin{1}.procElem.type;
        procInput = varargin{1}.procElem.procInput;
    elseif isfield(varargin{1}, 'procInput')
        type = varargin{1}.type;
        procInput = varargin{1}.procInput;
    end
elseif nargin==3
    type = varargin{1};
    procInput = varargin{2};
end

switch(type)
    case 'group'
        group.procInput = procInput;
    case 'subj'
        for ii=1:length(group.subjs)
            group.subjs(ii).procInput = procInput;
        end
    case 'run'
        for ii=1:length(group.subjs)
            for jj=1:length(group.subjs(ii).runs)
                group.subjs(ii).runs(jj).procInput = procInput;
            end
        end
end
