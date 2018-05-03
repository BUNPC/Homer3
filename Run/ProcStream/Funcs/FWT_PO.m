function wcoef = FWT_PO(x,L,qmf)
% FWT_PO -- Forward Wavelet Transform (periodized, orthogonal)
%  Usage
%    wc = FWT_PO(x,L,qmf)
%  Inputs
%    x    1-d signal; length(x) = 2^J
%    L    Coarsest Level of V_0;  L << J
%    qmf  quadrature mirror filter (orthonormal)
%  Outputs
%    wc    1-d wavelet transform of x.
%
%  Description
%    1. qmf filter may be obtained from MakeONFilter   
%    2. usually, length(qmf) < 2^(L+1)
%    3. To reconstruct use IWT_PO
%
%  See Also
%    IWT_PO, MakeONFilter
%
  [n,J] = dyadlength(x) ;
  wcoef = zeros(1,n) ;
  beta = ShapeAsRow(x);  %take samples at finest scale as beta-coeffts
  for j=J-1:-1:L
       alfa = DownDyadHi(beta,qmf);
       wcoef(dyad(j)) = alfa;
       beta = DownDyadLo(beta,qmf) ;  
  end
  wcoef(1:(2^L)) = beta;
  wcoef = ShapeLike(wcoef,x);

%
% Copyright (c) 1993. Iain M. Johnstone
%     
    
    

    
 
 
%
%  Part of Wavelab Version 850
%  Built Tue Jan  3 13:20:40 EST 2006
%  This is Copyrighted Material
%  For Copying permissions see COPYING.m
%  Comments? e-mail wavelab@stat.stanford.edu 
