function b = filesEqual(filename1, filename2, options)
global filesequal

b = [];
if nargin<2
    return;
end
if ~ischar(filename1) || ~ischar(filename2)
    return;
end
if ~ispathvalid(filename1) || ~ispathvalid(filename2) 
    return;
end
if ~exist('options','var')
    options = '';
end

b = false;

if optionExists(options,'exact')
    if GetFileSize(filename1) ~= GetFileSize(filename1)
        return;
    end
end
filesequal.fd1 = fopen(filename1);
filesequal.fd2 = fopen(filename2);

lcount1 = 0;
lcount2 = 0;
while 1
    l1 = fgetl(filesequal.fd1);
    lcount1 = lcount1+1;

    l2 = fgetl(filesequal.fd2);
    lcount2 = lcount2+1;

    if optionExists(options,'exact')
        if ~strcmp(l1,l2)
            Close();
            return
        end
    end
    
    while isblankline(l1) 
        if feof(filesequal.fd1)
            break
        end
        l1 = fgetl(filesequal.fd1);
        lcount1 = lcount1+1;
    end
    while isblankline(l2)
        if feof(filesequal.fd2)
            break
        end
        l2 = fgetl(filesequal.fd2);
        lcount2 = lcount2+1;
    end
    if ~equivalent(l1, l2)
        Close();
        return;
    end
    
    if feof(filesequal.fd1) && feof(filesequal.fd2)
        break;
    end
        
end

Close();
b = true;


% ------------------------------------
function Close()
global filesequal

fclose(filesequal.fd1);
fclose(filesequal.fd2);




% ------------------------------------
function b = equivalent(s1, s2)
if iswholenum(s1) && iswholenum(s2)
    b = s1 == s2;
    return;
end
s1(s1<33) = '';
s2(s2<33) = '';
b = strcmp(s1,s2);



% ------------------------------------
function b = isblankline(s)
s(s<33)='';
b = isempty(s);



