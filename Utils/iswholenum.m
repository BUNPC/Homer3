function b = iswholenum(x)
% Reason for this function is that isinteger() looks at the class of the number 
% rather it's actual value. So isinteger(4) will return true but integer(4.0) will 
% be false even though 4.0 = 4. This is a problem. 

b = (x == floor(x));

