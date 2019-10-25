function [rootdirexamples, currdir] = findexamplesdir()

rootdir = fileparts(which('SnirfClass.m'));
rootdirexamples = [rootdir, '/Examples/'];
rootdirexamples(rootdirexamples=='\') = '/';
currdir = pwd;
cd(rootdirexamples);
