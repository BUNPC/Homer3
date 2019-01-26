% function wp = WT_inv(x,L,N,wavename)
%
% Perform a discrete wavelet transform of the data and of the shifted
% version of the data for every decomposition level up to N-L. The shift
% helps the reconstruction
% 
%
% INPUTS:
% x:            1D signal on which to perform the wavelet transform  
% L:            Lowest wavelet scale used in the analysis
% N:            Number of wavelet levels in which the signal can be decomposed
% wavename:     name of the wavelet used for the decomposition
%
%
% OUTPUTS:
% wp:           Wavelet decomposition coefficient matrix ( #of time
%               points x #of levels+1). The first column contains the last approximation while
%               from the second to the end the details at all levels
% 
%
% LOG:
% 10/17/2012 by S. Brigadoi


function wp = WT_inv(x,L,N,wavename)

D = N-L;
n = length(x);
wp = zeros(n,D+1);
dwtmode('per');  % set the wavelet mode to periodization

wp(:,1) = x';
for d=0:(D-1)
    n_blocks = 2^d; % number of blocks in the level
    l_blocks = n/n_blocks; % length of the blocks in the level
    for b=0:(2^d-1) 
        s = wp(b*l_blocks+1:b*l_blocks+l_blocks,1)'; % first time take signal, from the second the approximation
        s_shift = [s(end) s(1:end-1)]; % create a shift version of the block
        
        [cA,cD] = dwt(s,wavename);  % discrete wavelet transform
        [cA_shift,cD_shift] = dwt(s_shift,wavename); % discrete wavelet transform of the shifted version
        
        wp(b*l_blocks+1:b*l_blocks+l_blocks/2,1) = cA;
        wp(b*l_blocks+l_blocks/2+1:b*l_blocks+l_blocks,1) = cA_shift;
        
        wp(b*l_blocks+1:b*l_blocks+l_blocks/2,d+2) = cD;
        wp(b*l_blocks+l_blocks/2+1:b*l_blocks+l_blocks,d+2) = cD_shift;
    end
end