function [ REG, ADD ] = rtcca( X, AUX, param, flags )
% rtcca uses multimodal data, here fNIRS, acceleration and auxiliary signals, to
% extract regressors for GLM-based noise reduction using temporally embedded
% CCA regularized with shrinkage of covariance matrices with 'optimal' parameter from Ledoit & Wolf 2004

% This function is an adaptation of the BLISSARD artifact rejection code by
% Alexander von Luhmann, written in 2018 at TUB
% Main difference: CCA is performed with shrinked covariance matrices and
% is therefore implemented as generalized eigenvalue problem (in previous
% versions Matlab's canoncorr was used)
%
% INPUTS:
% X:    input nirs data with dimensions |time x channels|
% AUX:   input accel data with dimensions |time x channels|
%                    feeding in orthogonalized (PCA) data is advised.
% param.tau:  temporal embedding parameter (lag in samples)
% param.NumOfEmb: Number of temporally embedded copies
% param.ct:   correlation threshold. returns only those regressors that
%               have a canonical correlation greater than the threshold.
% flags.pcaf:  flags for performing pca of [AUX X] as preprocessing step.
%       default: [0 0]
% flags.shrink: regularize CCA with automatic shrinkage of covariance
%       matrices. default: true
%
% OUTPUTS:
% REG: Regressors found by temp. embedded CCA
% ADD.ccac: CCA correlation coefficients between projected fNIRS sources
%       and projected aux data
% ADD.aux_emb:   Temp. embedded accelerometer signals
% ADD.U,V:  sources in CCA space found by CCA
% ADD.gammaX,gammaAUX:  selected shrinkage parameters
% ADD.Av_red:   return (cca threshold) reduced mapping matrix Av


%% Perform PCA
if flags.pcaf(1)==true
    [coeff_afs aux_pca latent_afs] = pca(AUX);
    aux_sigs = aux_pca;
else
    aux_sigs =AUX;
end
if flags.pcaf(2)==true
    [coeff_x x_pca latent_x] = pca(X);
    nirs_sigs = x_pca;
else
    nirs_sigs = X;
end

%% Temporally embed auxiliary data
% Aux with shift left
aux_emb = aux_sigs;
for i=1:param.NumOfEmb
    aux=circshift( aux_sigs, i*param.tau, 1);
    aux(1:2*i,:)=repmat(aux(2*i+1,:),2*i,1);
    aux_emb=[aux_emb aux];
    ADD.aux_emb=aux_emb;
end

%cut to same length of samples
s1=size(aux_emb,1);
s2=size(X,1);
if s1 ~=s2
    aux_emb=aux_emb(1:min([s1 s2]),:);
    X=X(:,1:min([s1 s2]));
end

%% Z-score signals
X = zscore(X);
Y = zscore(aux_emb);


%% Perform CCA with fNIRS signals and temporally embedded aux signals
[Au,Av,ccac,Us,Vs] = canoncorr(X,aux_emb);

%% Calculate Auto-Covariance matrices
% time points
T = size(X,1);
% with shrinkage?
if flags.shrink
    % Shrinkage of covariance matrix with 'optimal' parameter see Ledoit et al. 2004
    % Calculate estimated Auto-Covariance matrices
    [Cxx, ADD.gammaX, Tx] = cshrink(X');
    [Cyy, ADD.gammaAUX, Ty] = cshrink(Y');
else
    % Calculate empirical Auto-Covariance matrices
    Cxx = X'*X/(T-1);
    Cyy = Y'*Y/(T-1);
end

%% Calculate empirical Cross-Covariance matrices
Cxy = X'*Y/(T-1);
Cyx = Y'*X/(T-1);

%% put auto-covariance matrices into block matrix form (generalized eigenvalue problem)
[dx, dy] = size(Cxy);
% smaller of both dimensions:
ds = min(dx,dy);
% A = [0 Cxy; Cyx 0]
A = [zeros(dx,dx) Cxy; Cyx zeros(dy, dy)];
% B = [Cxx 0; 0 Cyy]
B = [Cxx zeros(dx,dy); zeros(dy, dx) Cyy ];

%% Calculate Generalized Eigenvalues
%   [V,D] = EIG(A,B) produces a diagonal matrix D of generalized
%   eigenvalues and a full matrix V whose columns are the corresponding
%   eigenvectors so that A*V = B*V*D.
nev = min(rank(X),rank(Y));
[V, D] = eigs(A,B,nev,'largestreal');

%% canoncorr coefficients
ADD.ccac = diag(D)';

% extract CCA Filter
Wx = V(1:dx,:);
Wy = V(dx+1:end,:);

% save sources and filters
ADD.U = X*Wx;
ADD.V = Y*Wy;
ADD.Au = Wx;
ADD.Av = Wy;

% return auxiliary cca components that have correlation > ct
compindex=find(ADD.ccac>param.ct);
REG = ADD.V(:,compindex);
% return reduced mapping matrix Av
ADD.Av_red = ADD.Av(:,compindex);




%% TEMPORARY FOR INVESTIGATION
eigenspec = false;
if eigenspec
    
    % calculate eigenvalues of B
    lambda_b = eig(B);
    figure
    plot(lambda_b)
       
end
end

