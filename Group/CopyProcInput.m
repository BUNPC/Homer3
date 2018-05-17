function group = CopyProcInput(group, argIn)

procInput = InitProcInput();

if isfield(argIn, 'procElem')
    type = argIn.procElem.type;
    procInput = argIn.procElem.procInput;
elseif isfield(argIn, 'procInput')
    type = argIn.type;
    procInput = argIn.procInput;
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
