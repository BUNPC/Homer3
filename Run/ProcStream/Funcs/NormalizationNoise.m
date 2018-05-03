% [y_norm,coeff] = NormalizationNoise(y,qmfilter)

% This function estimates the noise level and normalizes the signal so as to
% have signal to noise ratio = 1. The output signal is scaled so that the
% median absolute deviation (MAD) of the wavelet coefficients at the
% finest level is 1. 
% sigma_estimated = K*MAD; in a normal distribution K = 1.4826
%
% INPUTS:
% y:   	       signal to normalize
% qmfilter:    quadrature mirror filter
%
% OUTPUTS:
% y_norm:       normalized signal
% coeff:       1/sigma_estimated
%
% LOG:
% 10/17/2012 S. Brigadoi

function [y_norm,coeff] = NormalizationNoise(y,qmf)

    c = cconv(y,qmf,length(y)); % circular convolution (final length = length(y))
	y_downsampled = dyaddown(c); % downsample by 2

	medianAbsDev = mad(y_downsampled);
    
	if medianAbsDev ~= 0
		y_norm =  (1/1.4826).*y./medianAbsDev;
                coeff = 1/(1.4826*medianAbsDev);
	else
		y_norm = y;
                coeff = 1;
	end

