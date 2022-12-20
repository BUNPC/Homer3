function ylag = lagmatrix( y, lags )
    n = length(y);
    N = max(lags);
    
    ylag = convmtx(y, N+1);
    ylag = ylag(1:n, lags+1);

end

