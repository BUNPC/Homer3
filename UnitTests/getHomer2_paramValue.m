function val = getHomer2_paramValue(funcName, paramName, file)

val = [];

DEBUG=0;
if DEBUG
    fprintf('Searching Homer2 output %s for %s: %s value\n', file.name, funcName, paramName);
end
load(file.name);
for jj=1:length(group.subjs)
    for kk=1:length(group.subjs(jj).runs)
        for iFunc=1:length(group.subjs(jj).runs)
            if strcmp(group.subjs(jj).runs(kk).procInput.procFunc.funcName{iFunc}, funcName)
                for iParam=1:group.subjs(jj).runs(kk).procInput.procFunc.nFuncParam(iFunc)
                    if strcmp(group.subjs(jj).runs(kk).procInput.procFunc.funcParam{iFunc}{iParam}, paramName)
                        val = group.subjs(jj).runs(kk).procInput.procFunc.funcParamVal{iFunc}{iParam};
                        break
                    end
                end
            end
            if ~isempty(val)
                break;
            end
        end
        if ~isempty(val)
            break;
        end
    end
    if ~isempty(val)
        break;
    end
end



