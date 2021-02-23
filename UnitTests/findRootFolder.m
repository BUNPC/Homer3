function [rootpath, currpath] = findRootFolder(dirname)

rootpath = filesepStandard(fileparts(which('Homer3.m')));
currpath = pwd;
cd([rootpath, dirname]);
resetGroupFolder('','keep_registry:nodatatree');

