function x = IWT_PO(wc,L,qmf)
% IWT_PO -- Inverse Wavelet Transform (periodized, orthogonal)
%  Usage
%    x = IWT_PO(wc,L,qmf)
%  Inputs
%    wc     1-d wavelet transform: length(wc) = 2^J.
%    L      Coarsest scale (2^(-L) = scale of V_0); L << J;
%    qmf    quadrature mirror filter
%  Outputs
%    x      1-d signal reconstructed from wc
%
%  Description
%    Suppose wc = FWT_PO(x,L,qmf) where qmf is an orthonormal quad. mirror
%    filter, e.g. one made by MakeONFilter. Then x can be reconstructed by
%      x = IWT_PO(wc,L,qmf)
%
%  See Also
%    FWT_PO, MakeONFilter
%
    wcoef = ShapeAsRow(wc);
	x = wcoef(1:2^L);
	[n,J] = dyadlength(wcoef);
	for j=L:J-1
		x = UpDyadLo(x,qmf) + UpDyadHi(wcoef(dyad(j)),qmf)  ;
	end
    x = ShapeLike(x,wc);

%
% Copyright (c) 1993. Iain M. Johnstone
%     
    
    

    
 
 
%
%  Part of Wavelab Version 850
%  Built Tue Jan  3 13:20:40 EST 2006
%  This is Copyrighted Material
%  For Copying permissions see COPYING.m
%  Comments? e-mail wavelab@stat.stanford.edu 
