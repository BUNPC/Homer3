function b = isfile_private(dirname)
%
% isfile_private() is a backward compatible version of matlab's isfile()
% function.
%
% isfile() is a new matlab function that is an improvment over exist() to 
% tell if a pathname is a file or not. But it didn't exist prior to R2017. 
% Therefore we use try/catch to still be able to use isfile when it exists

try
    b = isfile(dirname);
catch
    b = (exist(dirname,'file') == 2);
end

