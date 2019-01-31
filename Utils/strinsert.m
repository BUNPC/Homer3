function s3 = strinsert(s1,s2,k,mode)

%  Syntax:
%  
%     s3 = strinsert(s1,s2,k);
%     s3 = strinsert(s1,s2,k,mode);
%
%  Description:
%
%     Insert string s2 into string s1 before or after the kth character, depending 
%     on the mode argument. If k is a character (currently has to be a single 
%     character, rather than a string) then insert s2 depending on the 
%     mode argument, before or after, all occurrences of k in s1.
%     
%     If the mode argument isn't provided, the default is to insert before.
%     
%  Examples:
%     
%     Insert '$' before all occurrences of '+' in str1.
%
%       str1 = sprintf('This string has 3 +''s: here + and here + and maybe else where.');
%       str2 = strinsert(str1, '$', '+', 'before');
%
%     Insert '$' after all occurrences of '+' in str1.
%
%       str2 = strinsert(str1, '$', '+', 'after');
%     
%
% Known Bugs:
%     
%     TBD: Currently does not handles insertion before or after consecutive occurrences of k
%     in s1 gracefully. Needs to be fixed.
%

s3='';

if ~exist('s1','var') || ~ischar(s1)
    return;
end
if ~exist('s2','var') || ~ischar(s2)
    return;
end
if ~ischar(k)
    if ~exist('k','var') || ~iswholenumber(k) || k<1 || length(k)>1
        return;
    end
    s3 = sprintf('%s%s%s', s1(1:k-1), s2, s1(k:end));
    return;
end
if ~exist('mode','var') || ~ischar(mode) || ~ismember(mode, {'before','after'})
    mode='before';
end

[c,i] = str2cell(s1, k);

% If there are no occurences of k in s1, then set return value to original
% string
if isempty(i)
    s3 = s1;
    return;
end

lentot = 0;
s3 = '';
for jj=1:length(i)
    if jj<=length(c)
        lentot = lentot+length(c{jj})+1;
    else
        lentot = lentot+1;
    end
    if strcmp(mode, 'before')
        if i(jj)<lentot
            if jj<=length(c)
                s3 = sprintf('%s%s%s%s', s3, s2, k, c{jj});
            else
                s3 = sprintf('%s%s%s', s3, s2, k);
            end
        else
            if jj<=length(c)
                s3 = sprintf('%s%s%s%s', s3, c{jj}, s2, k);
            else
                s3 = sprintf('%s%s%s%s', s3, s2, k);
            end
        end
    else
        if i(jj)<lentot
            if jj<=length(c)
                s3 = sprintf('%s%s%s%s', s3, k, s2, c{jj});
            else
                s3 = sprintf('%s%s%s', s3, k, s2);
            end
        else
            if jj<=length(c)
                s3 = sprintf('%s%s%s%s', s3, c{jj}, k, s2);
            else
                s3 = sprintf('%s%s%s', s3, k, s2);
            end
        end
    end
end
if jj<length(c)
    s3 = sprintf('%s%s', s3, c{jj+1});
end

