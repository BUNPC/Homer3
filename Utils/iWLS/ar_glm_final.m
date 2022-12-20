function [dmoco, beta, tstat, pval, sigma, CovB, dfe, w, P, f] = ar_glm_final( d,X,tune )

    % preallocation
    dmoco = zeros(size(d));
    beta = zeros([size(X,2) size(d,2)]);
    tstat = beta;
    pval = beta;
    w = zeros(size(d));
    
    Sall=[];

    for j = 1:size(d,2)
        y = d(:,j);
        
        B = X \ y;
        B0 = 1e6*ones(size(B));
        
        iter = 0;
        maxiter = 10;
        while norm(B-B0)/norm(B0) > 1e-2 && iter < maxiter 
            B0 = B;
            
            res = y-X*B;
            
            a = robust_ar_fit(res);
            f = [1; -a(2:end)];
            
            Xf = filter(f,1,X);
            yf = filter(f,1,y);

            [B, S] = robustfit(Xf,yf,[],[],'off');

            iter = iter + 1;
        end
        
        % moco data & statistics
        w(:,j) = S.w;
%         dmoco(:,j) = ymoco;
        beta(:,j) = B;
        tstat(:,j) = B./sqrt(diag(S.covb));
        pval(:,j) = 2*tcdf(-abs(tstat(:,j)),S.dfe);
        P(j,1) = length(a)-1;
        sigma(:,j)=S.s;
        CovB(:,:,j)=S.covb;
        dfe=S.dfe;
    end
    
   dmoco=filter(f,1,d); 
    
end

% function w = biweight( y,c )
%     sig = mad(y,1)/.6745;
%     y = y/sig;
%     
%     lst = y < c & y > -c;
%     w = zeros( size(y) );
%     w(lst) = abs(1 - (y(lst)/c).^2);
% end

% function F = getFilterMatrix( a,ly )
%     P = length(a)-1;
%     F = speye(ly);
%     F = spdiags(repmat(-a(2:end)',[ly 1]),-1:-1:-P,F);
% end

