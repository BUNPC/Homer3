function [b, r, crit] = stepwise(X, y, criterion)
    
    if nargin<3, criterion = 'BIC'; end
    
    % qr factorization will speed up stepwise regression significantly
    [Q,R] = qr(X,0); % note that the zero is very important for performance
    invR = pinv(R);
    
    n = size(y,1);
    LL = nan(size(X,2),1);
    for i = 1:length(LL)
        % get residual for each fit
        b = invR(1:i,1:i) * Q(:,1:i)' * y;
        r = y - X(:,1:i)*b;
        
        % calculate log-likelihood
        LL(i) = -n/2*log( 2*pi*mean(r.^2) ) - n/2;
                
    end
    
    % Calculate information criterion
    crit = infocrit( LL , n , (1:length(LL))' , criterion );
    
    % optimal model order
    lst=find(~isnan(crit));
    [~, N] = min( crit(lst) ); 
    N=lst(N);
    
    % finally, our output
    b = invR(1:N,1:N) * Q(:,1:N)'*y;
    r = y - X(:,1:N)*b;
    
end

