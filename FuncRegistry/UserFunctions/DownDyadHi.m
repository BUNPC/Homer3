function d = DownDyadHi(x,qmf)
% DownDyadHi -- Hi-Pass Downsampling operator (periodized)
%  Usage
%    d = DownDyadHi(x,f)
%  Inputs
%    x    1-d signal at fine scale
%    f    filter
%  Outputs
%    y    1-d signal at coarse scale
%
%  See Also
%    DownDyadLo, UpDyadHi, UpDyadLo, FWT_PO, iconv
%
	d = iconv( MirrorFilt(qmf),lshift(x));
	n = length(d);
	d = d(1:2:(n-1));

%
% Copyright (c) 1993. Iain M. Johnstone
%     
    
 
 
%
%  Part of Wavelab Version 850
%  Built Tue Jan  3 13:20:40 EST 2006
%  This is Copyrighted Material
%  For Copying permissions see COPYING.m
%  Comments? e-mail wavelab@stat.stanford.edu 
