function vals = getHomer2_paramValue(funcName, paramName, files)

DEBUG=0;

vals = cell(1,length(files));
for ii=1:length(files)
    
    if DEBUG
        fprintf('Searching Homer2 output %s for %s: %s value\n', files(ii).name, funcName, paramName);
    end
    
    load(files(ii).name);    
    
    for jj=1:length(group.subjs)
        for kk=1:length(group.subjs(jj).runs)
            for iFunc=1:length(group.subjs(jj).runs)
                if strcmp(group.subjs(jj).runs(kk).procInput.procFunc.funcName{iFunc}, funcName)
                    for iParam=1:group.subjs(jj).runs(kk).procInput.procFunc.nFuncParam(iFunc)
                        if strcmp(group.subjs(jj).runs(kk).procInput.procFunc.funcParam{iFunc}{iParam}, paramName)
                            vals{ii} = group.subjs(jj).runs(kk).procInput.procFunc.funcParamVal{iFunc}{iParam};
                            break
                        end
                    end                    
                end
                if ~isempty(vals{ii})
                    break;
                end
            end
            if ~isempty(vals{ii})
                break;
            end
        end
        if ~isempty(vals{ii})
            break;
        end
    end
    
end

