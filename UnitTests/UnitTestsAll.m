function status = UnitTestsAll()
global DEBUG1
DEBUG1=0;

status(1) = unitTest1('.nirs');
status(2) = unitTest1('.snirf');
status(3) = unitTest2('.nirs', 0.70);
status(4) = unitTest2('.nirs', 0.50);
status(5) = unitTest2('.snirf', 3.00);
status(6) = unitTest2('.snirf', 0.50);

k = find(status~=0);
for ii=1:length(status)
    if status(ii)~=0
        fprintf('Unit test %d did NOT pass.\n', ii);
    else
        fprintf('Unit test %d passed.\n', ii);
    end
end