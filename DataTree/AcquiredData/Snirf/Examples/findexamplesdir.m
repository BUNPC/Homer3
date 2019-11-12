function rootdirexamples = findexamplesdir()

rootdir = fileparts(which('SnirfClass.m'));
rootdirexamples = convertToStandardPath([rootdir, '/Examples/']);
