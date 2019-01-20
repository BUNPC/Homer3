function y = lshift(x)
% lshift -- Circular left shift of 1-d signal
%  Usage
%    l = lshift(x)
%  Inputs
%    x   1-d signal
%  Outputs
%    l   1-d signal 
%        l(i) = x(i+1) except l(n) = x(1)
%

	y = [ x( 2:length(x) ) x(1) ];

%
% Copyright (c) 1993. Iain M. Johnstone
%     
    
    
 
 
%
%  Part of Wavelab Version 850
%  Built Tue Jan  3 13:20:40 EST 2006
%  This is Copyrighted Material
%  For Copying permissions see COPYING.m
%  Comments? e-mail wavelab@stat.stanford.edu 
