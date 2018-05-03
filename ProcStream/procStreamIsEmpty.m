function b = procStreamIsEmpty(procInput)

b=0;
if ~isfield(procInput, 'procFunc')
   b=1;
   return;
end

procFunc = procInput.procFunc;

if isempty(procFunc)
   b=1;
   return;
end

if procFunc.nFunc==0
   b=1;
   return;
end
