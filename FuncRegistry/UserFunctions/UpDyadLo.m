function y = UpDyadLo(x,qmf)
% UpDyadLo -- Lo-Pass Upsampling operator; periodized
%  Usage
%    u = UpDyadLo(d,f)
%  Inputs
%    d    1-d signal at coarser scale
%    f    filter
%  Outputs
%    u    1-d signal at finer scale
%
%  See Also
%    DownDyadLo, DownDyadHi, UpDyadHi, IWT_PO, iconv
%
	y =  iconv(qmf, UpSampleN(x) );


%  Revision History
%  10/1/05       AM      UpSample is changed to UpSampleN

%
% Copyright (c) 1993. Iain M. Johnstone
% Last modified on October 2005.    
%     
    
    
 
 
%
%  Part of Wavelab Version 850
%  Built Tue Jan  3 13:20:40 EST 2006
%  This is Copyrighted Material
%  For Copying permissions see COPYING.m
%  Comments? e-mail wavelab@stat.stanford.edu 
