% Usage:
%
%     d = distmatrix(varargin)
%
% Example 1:
%
%     d = distmatrix(v);
%
% Example 2:
%
%     d = distmatrix(v1,v2);
%
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/13/2008
%  

function d = distmatrix(varargin)

d=[];
if length(varargin)==1
    
    v = double(varargin{1});
    n = size(v,1);
    d = zeros(n);
    for i=1:n
        for j=i+1:n        
            d(i,j) = ((v(i,1) - v(j,1))^2 + ...
                      (v(i,2) - v(j,2))^2 + ...
                      (v(i,3) - v(j,3))^2)^0.5;
        end     
    end

elseif length(varargin)==2

    v1 = double(varargin{1});
    v2 = double(varargin{2});
    m = size(v1,1);
    n = size(v2,1);
    d = zeros(m,n);    
    for i=1:m
        for j=1:n
            d(i,j) = ((v1(i,1) - v2(j,1))^2 + ...
                      (v1(i,2) - v2(j,2))^2 + ...
                      (v1(i,3) - v2(j,3))^2)^0.5;
        end     
    end    

end
