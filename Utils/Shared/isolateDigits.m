function digits = isolateDigits(x, base)
digits = [];

if ~exist('base','var') || (base < 2 || base > 16)
    base = 10;
end
if base ~= uint32(base)
    return;
end
if x == 0
    digits = 0;
    return;
end

kk = 1;
while 1
    
    d = mod(x,base);
    x = floor(x/base);
    
    if (x == 0) && (d == 0)
        break;
    end
    
    digits(kk) = d;
    kk = kk+1;
    
end

