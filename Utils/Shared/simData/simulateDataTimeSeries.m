function [t, y] = simulateDataTimeSeries(N, alpha, sigma, time0)

if ~exist('N','var')
    N = 1e3; 
end
if ~exist('alpha','var')
    alpha = 1;
end
if ~exist('sigma','var')
    sigma = .4; 
end
if ~exist('time0','var')
    time0 = 0;
end

% generate time
nTpts = N;
sampleRate = 10;
timeTotal = 1/sampleRate * nTpts;
t = 0:1/sampleRate:timeTotal;
t(N+1:end) = [];

% Generate data
generateRandNumSeed(time0);
y = zeros(N, 1); 
y(1) = randn; % Initialize
fprintf('Rand = %0.4f\n', y(1));

for k = 2:N
    y(k) = alpha*y(k-1) + randn*sigma;
end



% ---------------------------------------------------
function generateRandNumSeed(time0)
if time0 == 0
    x = uint32(100*rand);
    rng(x);
    y = uint32(100*rand);
    rng(y);
else
    s = 0;
    while s==0
        s = uint64(1e4*toc(time0));
    end    
    rng(s);
end



