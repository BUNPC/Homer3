function [rootdirexamples, currdir] = findexamplesdir()

rootdir = fileparts(which('Homer3.m'));
rootdirexamples = [rootdir, '/DataTree/AcquiredData/Snirf/Examples/'];
rootdirexamples(rootdirexamples=='\') = '/';
currdir = pwd;
cd(rootdirexamples);
