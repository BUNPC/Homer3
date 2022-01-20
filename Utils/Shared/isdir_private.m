function b = isdir_private(dirname)
%
% isdir_private() is a backward compatible version of matlab's isdir()
% function.
%
% isdir() is a new matlab function that is an improvment over exist() to 
% tell if a pathname is a directory or not. But it didn't exist prior to R2017. 
% Therefore we use try/catch to still be able to use isdir when it exists

try
    b = isdir(dirname);
catch
    b = (exist(dirname,'dir') == 7);
end

