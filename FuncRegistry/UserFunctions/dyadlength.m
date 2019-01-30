function [n,J] = dyadlength(x)
% dyadlength -- Find length and dyadic length of array
%  Usage
%    [n,J] = dyadlength(x)
%  Inputs
%    x    array of length n = 2^J (hopefully)
%  Outputs
%    n    length(x)
%    J    least power of two greater than n
%
%  Side Effects
%    A warning is issued if n is not a power of 2.
%
%  See Also
%    quadlength, dyad, dyad2ix
%
  n = length(x) ;
  J = ceil(log(n)/log(2));
  if 2^J ~= n ,
      disp('Warning in dyadlength: n != 2^J')
  end
    
    
 
 
%
%  Part of Wavelab Version 850
%  Built Tue Jan  3 13:20:40 EST 2006
%  This is Copyrighted Material
%  For Copying permissions see COPYING.m
%  Comments? e-mail wavelab@stat.stanford.edu 
