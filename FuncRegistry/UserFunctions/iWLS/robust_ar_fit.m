function [coef, res, wres, ymoco] = robust_ar_fit( y, Pmax )
    [~, res] = ar_fit(y, Pmax);
    
    w = wfun(res);
    [coef, ~] = ar_fit(w.*y, Pmax);
    
    res     = filter([1; -coef(2:end)], 1, y-coef(1));
    wres    = filter([1; -coef(2:end)], 1, w.*y-coef(1));
    
    ymoco   = filter(1, [1; -coef(2:end)], w.*res);
end

function w = wfun(r)
    s = mad(r, 0) / 0.6745;
    r = r/s/4.685;
    
    w = (1 - r.^2) .* (r < 1 & r > -1);
end