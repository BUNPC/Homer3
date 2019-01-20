% function x = IWT_inv(StatWT,wavename)
%
% Perform a discrete wavelet inverse transform using the wavelet coefficients
% found in wp. It is shift invariant.
% 
%
% INPUTS:
% StatWT:       matrix of wavelet coefficients (# of time points x # of levels+1).
%               The first columns contains the approximation coefficients,
%               the others the detailed coefficients. 
% wavename:     name of the wavelet used for the recontruction (should be
%               the same used for the previous decomposition)
%
%
% OUTPUTS:
% x:            Reconstructed signal after the wavelet inverse transform
% 
%
% LOG:
% 10/17/2012 by S. Brigadoi


function x = IWT_inv(StatWT,wavename)

[n,D] = size(StatWT);
D = D-1;

wp = StatWT;
dwtmode('per');

approx = wp(:,1)'; % approximation coefficients in the first column
for d = D-1:-1:0
     n_blocks = 2^d;
     l_blocks = n/n_blocks;
    for b = 0:(2^d-1)
        
        cD = wp(b*l_blocks+1:b*l_blocks+l_blocks/2,d+2)';
        cD_shift = wp(b*l_blocks+l_blocks/2+1:b*l_blocks+l_blocks,d+2)';
        cA = approx(b*l_blocks+1:b*l_blocks+l_blocks/2);
        cA_shift = approx(b*l_blocks+l_blocks/2+1:b*l_blocks+l_blocks);
        
        s1 = idwt(cA,cD,wavename); % discrete inverse wavelet transform
        s_shift = idwt(cA_shift,cD_shift,wavename); % discrete inverse wavelet transform of the shifted version
        s2 = [s_shift(2:end) s_shift(1)]; % reshifting the shifted version 
        
        approx(b*l_blocks+1:b*l_blocks+l_blocks) = (s1+s2)/2; % reconstruct the approximation of the next level
    end
end
x = approx;