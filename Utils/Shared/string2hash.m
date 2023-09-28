function hash = string2hash(str, len, type)
% This function generates a hash value from a text string
%
% hash = string2hash(str,type);
%
% inputs,
%   str : The text string, or array with text strings.
% outputs,
%   hash : The hash value, integer value between 0 and 2^32-1
%   type : Type of has 'djb2' (default) or 'sdbm'
%
% From c-code on : http://www.cse.yorku.ca/~oz/hash.html
%
% djb2
%  this algorithm was first reported by dan bernstein many years ago
%  in comp.lang.c
%
% sdbm
%  this algorithm was created for sdbm (a public-domain reimplementation of
%  ndbm) database library. it was found to do well in scrambling bits,
%  causing better distribution of the keys and fewer splits. it also happens
%  to be a good general hashing function with good distribution.
%
% example,
%
%  hash=string2hash('hello world');
%  disp(hash);
%
% Function is written by D.Kroon University of Twente (June 2010)
% From string to double array
str = double(str);
if ~exist('len','var')
    len = []; 
end
if ~exist('type','var')
    type = 'djb2'; 
end
N = size(str, 2);
k = 0;
switch(type)
    case 'djb2'
        hash = 5381*ones(size(str,1),1);
        for i = 1:N
            hash = mod(hash * 33 + str(:,i), 2^32-1);
            k = k + str(:,i)*2^i;
        end
    case 'sdbm'
        hash = zeros(size(str,1),1);
        for i = 1:N
            hash = mod(hash * 65599 + str(:,i), 2^32-1);
            k = k + str(:,i)*2^i;
        end
    otherwise
        error('string_hash:inputs','unknown type');
end

hash = hash+k;
%fprintf('Initial hash:  %d\n', hash)

if ~isempty(len) && len<6
    N = round(log10(hash));
    if N <= len
        return;
    end
    
    d = isolateDigits(hash);
    hash = 0;
    for ii = 1:len
        hash = hash + d(ii)*10^(ii-1);
    end
end



% --------------------------------------------------------------
function digits = isolateDigits(x, base)
digits = [];

if ~exist('base','var') || (base < 2 || base > 16)
    base = 10;
end
if base ~= uint32(base)
    return;
end
if x == 0
    digits = 0;
    return;
end

kk = 1;
while 1
    
    d = mod(x,base);
    x = floor(x/base);
    
    if (x == 0) && (d == 0)
        break;
    end
    
    digits(kk) = d;
    kk = kk+1;
    
end

