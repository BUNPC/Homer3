function s2 = sprintf_waitbar(s)
% Syntax: 
%    s2 = sprintf_waitbar(s)
% 
% Description:
%    Change character string with '_' character(s), to '\_', 
%    so that the string is correctly displayed in a waitbar object. 
%    Waitbar does not handle char strings with '_' gracefully. 
%    This function inserts a '\' chararcter before each occurrence of 
% '_' so that it shows up corrctly when displayed in a waitbar object
% 
s2 = s;
k = find(s=='_');
for ii=1:length(k)
    s2 = sprintf('%s\\%s', s2(1:k(ii)+(ii-1)-1), s2(k(ii)+(ii-1):end));
end
