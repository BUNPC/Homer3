function diff = procStreamDiff(procInput1, procInput2)

diff = 0;

procFunc1 = procInput1.procFunc;
procFunc2 = procInput2.procFunc;

if procFunc1.nFunc ~= procFunc2.nFunc
    diff = 1;
    return;
end

for ii=1:procFunc1.nFunc
    if ii<=procFunc2.nFunc
        if ~strcmp(procFunc1.funcName{ii}, procFunc2.funcName{ii})
            diff = 0;
        end
    end
end
