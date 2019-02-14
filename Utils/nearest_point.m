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
dmin        = 0;

if isempty(p1) || isempty(p2)
    return;
end
if ~exist('ith_closest','var') | isempty(ith_closest)
    ith_closest = 1;
end

% Figure out the dimentions of p1 and p2 to see if they're compatible
sz1 = size(p1);
sz2 = size(p2);
ndim = sz1(sz1==sz2);
if isempty(ndim)
    if length(sz1)>2 || length(sz1)~=length(sz2)
        menu('nearest_point error: p1 and p2 number of dimensions incompatible','OK');
        return;
    end
    if length(sz1)>2 || length(sz1)~=length(sz2)
        menu('nearest_point error: p1 and p2 number of dimensions incompatible','OK');
        return;
    end
    if ismember(1,sz1) && ismember(1,sz2)
        ndim=1;
    end
end
if ndim~=3 && ndim~=1
    menu('nearest_point warning: currently only handles arguments in 1 and 3 dimensions.','OK');
    return;
end

m=size(p1,1);
n=size(p2,1);

if ith_closest>n
    fprintf('Error: %dth closest element is greater than size of first argument (%d)\n', ith_closest, n);
    return;
end

if ndim==3
    p2_closest  = zeros(m,3);
    ip2_closest = zeros(m,1);
    dmin = zeros(m,1);
    for k=1:m
        d = sqrt((p2(:,1)-p1(k,1)).^2+(p2(:,2)-p1(k,2)).^2+(p2(:,3)-p1(k,3)).^2);
        [d2, j] = sort(d);
        dmin(k) = d2(ith_closest);
        
        ip2_closest(k)  = j(ith_closest);
        p2_closest(k,:) = p2(ip2_closest(k),:);
    end
elseif ndim==1
    p2_closest  = zeros(m,1);
    ip2_closest = zeros(m,1);
    dmin = zeros(m,1);
    for k=1:m
        d = sqrt((p2(:)-p1(k)).^2);
        [d2, j] = sort(d);
        dmin(k) = d2(ith_closest);
        
        ip2_closest(k) = j(ith_closest);
        p2_closest(k)  = p2(ip2_closest(k));
    end
end

