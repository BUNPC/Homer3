function [ut, currpath] = launchHomer3(datafmt0, dirname)
[rootpath, currpath] = findRootFolder(dirname);
datafmt = datafmt0;
datafmt(datafmt=='.')='';
procStreamFile = ['../processOpt_default_homer3_', datafmt, '.cfg'];
ut = Homer3([rootpath, dirname], datafmt, GuiUnitTest([], [], procStreamFile));
