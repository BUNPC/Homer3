function [t, y] = simulateDataTimeSeries(N, alpha, sigma)

if ~exist('N','var')
    N = 1e3; 
end
if ~exist('alpha','var')
    alpha = 1;
end
if ~exist('sigma','var')
    sigma = .4; 
end

% generate time
nTpts = N;
sampleRate = 10;
timeTotal = 1/sampleRate * nTpts;
t = 0:1/sampleRate:timeTotal;
t(N+1:end) = [];

% Generate data

y = zeros(N, 1); 
y(1) = randn; % Initialize
fprintf('Rand = %0.4f\n', y(1));

for k = 2:N
    y(k) = alpha*y(k-1) + randn*sigma;
end

