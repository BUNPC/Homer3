function vec = ShapeLike(sig,proto)
% ShapeLike -- Make 1-d signal with given shape
%  Usage
%    vec = ShapeLike(sig,proto)
%  Inputs
%    sig      a row or column vector
%    proto    a prototype shape (row or column vector)
%  Outputs
%    vec      a vector with contents taken from sig
%             and same shape as proto
%
%  See Also
%    ShapeAsRow
%
	sp = size(proto);
	ss = size(sig);
	if( sp(1)>1 & sp(2)>1 )
	   disp('Weird proto argument to ShapeLike')
	elseif ss(1)>1 & ss(2) > 1,
	   disp('Weird sig argument to ShapeLike')
	else
	   if(sp(1) > 1),
		  if ss(1) > 1,
			 vec = sig;
		  else
			 vec = sig(:);
		  end
	   else
		  if ss(2) > 1,
			 vec = sig;
		  else
			 vec = sig(:)';
		  end
	   end
	end
    
    
 
 
%
%  Part of Wavelab Version 850
%  Built Tue Jan  3 13:20:43 EST 2006
%  This is Copyrighted Material
%  For Copying permissions see COPYING.m
%  Comments? e-mail wavelab@stat.stanford.edu 
