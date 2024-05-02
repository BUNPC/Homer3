function resig = resamplee(sig,upsample,downsample)
if upsample*downsample<2^31
    resig = resample(sig,upsample,downsample);
else
    sig1half = sig(1:floor(length(sig)/2));
    sig2half = sig(floor(length(sig)/2):end);
    resig1half = resamplee(sig1half, floor(upsample/2), length(sig1half));
    resig2half = resamplee(sig2half, upsample-floor(upsample/2), length(sig2half));
    resig = [resig1half(:); resig2half(:)];
end
