function t = isdigit(c)
%ISDIGIT True for decimal digits.
%
%   For a string C, ISDIGIT(C) is 1 for decimal digits and 0 otherwise.
%
%   (In ASCII: characters [0-9].)
%
%   See also: ISALNUM, ISALPHA, ISASCII, ISLOWER, ISPRTCHR, ISUPPER,
%   ISXDIGIT.

%   Author:      Peter John Acklam
%   Time-stamp:  2002-03-03 13:51:04 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   if verLessThan('matlab','9.0')
       error(nargchk(1, 1, nargin));
   else
       narginchk(1, 1);
   end
   
   t = ischar(c) & ( '0' <= c ) & ( c <= '9' );
