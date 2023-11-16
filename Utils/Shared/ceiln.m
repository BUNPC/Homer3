function val = ceiln(val0, n)
if ~exist('n','var')
    n = 0;
end
pw = ceil(log10(abs(val0))); % Find order of magnitude of val.
res = 10^(pw-n-2); % Resolution to round to.
valtemp = val0*res;
val = ceil(valtemp)/res; % < change floor() to ceil(), for ceiling equivalent.
