function rootdirexamples = findexamplesdir()

rootdir = fileparts(which('SnirfClass.m'));
rootdirexamples = filesepStandard([rootdir, '/Examples/']);
