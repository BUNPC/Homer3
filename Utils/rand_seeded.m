function r = rand_seeded(seed, varargin)

% r = rand_seeded(seed, varargin)
%
% Generate repeatable random sequence of numbers based 
% on a number seed
%
rng(seed);
d = cell2mat(varargin);
r = rand(d);

