function [lpf, std] = getUserOptionsVals()
global QUICK_TEST
if ~QUICK_TEST(2)
    lpf = [00.30, 00.70, 01.00];
    std = [05.00, 10.00, 15.00, 20.00];
else
    lpf = 00.30;
    std = 05.00;
end
