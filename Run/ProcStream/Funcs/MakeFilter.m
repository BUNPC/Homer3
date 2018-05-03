%$Release 4.0
% Copyright (c) 2005, Massachusetts General Hospital
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without modification, 
% are permitted provided that the following conditions are met:
% 
% Redistributions of source code must retain the above copyright notice, this 
% list of conditions and the following disclaimer. Redistributions in binary 
% form must reproduce the above copyright notice, this list of conditions and
% the following disclaimer in the documentation and/or other materials provided
% with the distribution. Neither the name of the Massachusetts General Hospital
% nor the names of its contributors may be used to endorse or promote products 
% derived from this software without specific prior written permission. THIS 
% SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%


function [fb,fa] = MakeFilter(FilterType,FilterOrder,fs,cutoff,highlow,Rp,Rs)
%Types
%    Butterworth
%    Chebyshev Type I 
%    Chebyshev Type II
%    Cauer (Elliptic)
%    sliding average filter

if ~exist('Rp')
     Rp=0.5;  %PassBand suppression (in dB)
end

if ~exist('Rs')
     Rs=30;   %SideBand suppression (in dB)
end


Wn=cutoff*2/fs;


lst=find(Wn==0);
Wn(lst)=[];
if lst==2 & strcmp(highlow,'band')
    highlow='high';
end

if any(Wn<0) | any(Wn>=1) | isempty(Wn)
   if ~isempty(Wn)
        h=warndlg('Filter parameters exceed Nyquist frequency');
        while ishandle(h)
            pause(0.1);
        end
   end
    fa=[1 0];  %This will effectively not do anything to the data
    fb=[1 0];
    return
end

    

switch(FilterType)
    case 1
        %Butterworth
        
        if strcmp(highlow,'band') & length(Wn)==2
            [fb,fa]=butter(FilterOrder,Wn);
        elseif strcmp(highlow,'high')
            [fb,fa]=butter(FilterOrder,Wn,'high');
        else
            %Low
            [fb,fa]=butter(FilterOrder,Wn);
        end
     case 2
        %Chebyshev Type I 
      
        
        if strcmp(highlow,'band') & length(Wn)==2
            [fb,fa]=cheby1(FilterOrder,Rp,Wn);
        elseif strcmp(highlow,'high')
            [fb,fa]=cheby1(FilterOrder,Rp,Wn,'high');
        else
            %Low
            [fb,fa]=cheby1(FilterOrder,Rp,Wn);
        end
        
     case 3
        %Chebyshev Type II 
       
        
        if strcmp(highlow,'band') & length(Wn)==2
            [fb,fa]=cheby2(FilterOrder,Rp,Wn);
        elseif strcmp(highlow,'high')
            [fb,fa]=cheby2(FilterOrder,Rp,Wn,'high');
        else
            %Low
            [fb,fa]=cheby2(FilterOrder,Rp,Wn);
        end
      case 4
        %Ellipic 
         
        if strcmp(highlow,'band') & length(Wn)==2
            [fb,fa]=ellip(FilterOrder,Rp,Rs,Wn);
        elseif strcmp(highlow,'high')
            [fb,fa]=ellip(FilterOrder,Rp,Rs,Wn,'high');
        else
            %Low
            [fb,fa]=ellip(FilterOrder,Rp,Rs,Wn);
        end
    case 5
        %sliding average version
        fb=ones(floor(2/Wn),1)/floor(2/Wn);
        fa=1;
end
return
        
