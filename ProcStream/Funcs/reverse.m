function r = reverse(x)
% reverse -- Reverse order of elements in 1-d signal
%  Usage
%    r = reverse(x)
%  Inputs
%    x     1-d signal
%  Outputs
%    r     1-d time-reversed signal
%
%  See Also
%    flipud, fliplr
%
   r = x(length(x):-1:1);

%
% Copyright (c) 1993. David L. Donoho
%     
    
    
 
 
%
%  Part of Wavelab Version 850
%  Built Tue Jan  3 13:20:40 EST 2006
%  This is Copyrighted Material
%  For Copying permissions see COPYING.m
%  Comments? e-mail wavelab@stat.stanford.edu 
