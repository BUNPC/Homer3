function [p2_closest, ip2_closest, dmin] = nearest_point(p2, p1, ith_closest)
%
% Usage:
%
%    [p2_closest ip2_closest] = nearest_point(p2,p1)
%
% Description:
%
%    Find the points in p2 that are nearest to the points in p1.
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   11/13/2008
%
% Updates:
%
% 01/21/2010 - Jay Dubb changed variable names and modified comment
%              to better describe the way this function works.
%

% Output arguments
p2_closest  = [];
ip2_closest = [];
dmin        = -1;

% Error check input args
if nargin<2
    return;
end
if isempty(p2) || isempty(p1)
    return;
end
if ndims(p2) ~= ndims(p1)
    return;
end
if ~exist('ith_closest','var') | isempty(ith_closest)
    ith_closest = 1;
end

ndim = getNdim([p2;p1]);

m=size(p1,1);
n=size(p2,1);
dmin=0;

if ith_closest>n
    fprintf('Error: %dth closest element is greater than size of first argument (%d)\n', ith_closest, n);
    return;
end

p2_closest  = zeros(m,ndim);
ip2_closest = zeros(m,1);
dmin = zeros(m,1);
for k=1:m
    if ndim==3
        d = dist3(p2, p1(k,:));
    elseif ndim==2
        d = dist2(p2, p1(k,:));
    elseif ndim==1
        d = abs(p2-p1(k));
    end
    [d2, j] = sort(d);
    dmin(k) = d2(ith_closest);
    ip2_closest(k)  = j(ith_closest);
    p2_closest(k,:) = p2(ip2_closest(k),:);
end



