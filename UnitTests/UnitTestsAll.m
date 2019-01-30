function status = UnitTestsAll()
global DEBUG1
DEBUG1=0;

delete ./*.snirf

status(1) = unitTest_DefaultProcStream('.nirs');
status(2) = unitTest_DefaultProcStream('.snirf');
status(3) = unitTest_ModifiedLPF('.nirs', 0.70);
status(4) = unitTest_ModifiedLPF('.nirs', 0.50);
status(5) = unitTest_ModifiedLPF('.snirf', 3.00);
status(6) = unitTest_ModifiedLPF('.snirf', 0.50);

k = find(status~=0);
for ii=1:length(status)
    if status(ii)~=0
        fprintf('Unit test %d did NOT pass.\n', ii);
    else
        fprintf('Unit test %d passed.\n', ii);
    end
end