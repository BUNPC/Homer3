function diff = procStreamDiff(procInput1, procInput2)

diff = 0;

procFunc1 = procInput1.procFunc;
procFunc2 = procInput2.procFunc;

if length(procFunc1) ~= length(procFunc2)
    diff = 1;
    return;
end

for ii=1:length(procFunc1)
    if ii<=length(procFunc2)
        if ~strcmp(procFunc1(ii).funcName, procFunc2(ii).funcName)
            diff = 0;
        end
    end
end
