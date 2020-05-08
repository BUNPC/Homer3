function [Cstar, gamma, T] = cshrink(X)
%
% this is a reduced form of the function CLSUTIL_SHRINKAGE from the BBCI toolbox
% https://github.com/bbci/bbci_public
% Blankertz B, Acqualagna L, Dähne S, Haufe S, Schultze-Kraft M, Sturm I, 
% Uš?umlic M, Wenzel MA, Curio G, Müller KR. The Berlin Brain-Computer Interface: 
% Progress Beyond Communication and Control. Frontiers in Neuroscience. 2016; 10. 
% http://journal.frontiersin.org/article/10.3389/fnins.2016.00530

%Arguments:
%  X: DOUBLE [NxM] - Data matrix, with N feature dimensions, and M training points/examples.
%
%Returns:
%  CSTAR: estimated covariance matrix
%  GAMMA: selected shrinkage parameter
%  T: target matrix for shrinkage
%
%Description:
%  Shrinkage of covariance matrix with 'optimal' parameter, see:
%
%  [1] Ledoit O. and Wolf M. (2004) "A well-conditioned estimator for
%  large-dimensional covariance matrices", Journal of Multivariate
%  Analysis, Volume 88, Number 2, February 2004 , pp. 365-411(47)
%
%  [2] Schäfer, Juliane and Strimmer, Korbinian (2005) "A Shrinkage
%  Approach to Large-Scale Covariance Matrix Estimation and
%  Implications for Functional Genomics," Statistical Applications in
%  Genetics and Molecular Biology: Vol. 4 : Iss. 1, Article 32.
%

%%% Empirical covariance
[p, n] = size(X);
Xn     = X - repmat(mean(X,2), [1 n]);
S      = Xn*Xn';
Xn2    = Xn.^2;

%%% Define target matrix for shrinkage
%(diagonal, common variance): default
idxdiag    = 1:p+1:p*p;
idxnondiag = setdiff(1:p*p, idxdiag,'legacy');
nu = mean(S(idxdiag));
T  = nu*eye(p,p);


%%% Calculate optimal gamma for given target matrix
    V     = 1/(n-1) * (Xn2 * Xn2' - S.^2/n);
    gamma = n * sum(sum(V)) / sum(sum((S - T).^2));
    
    %%% Handle special cases
    if gamma>1,
        if opt.Verbose,
            warning('gamma forced to 1');
        end
        gamma= 1;
    elseif gamma<0,
        if opt.Verbose,
            warning('gamma forced to 0');
        end
        gamma= 0;
    end
%%% Estimate covariance matrix
Cstar = (gamma*T + (1-gamma)*S ) / (n-1);

end

