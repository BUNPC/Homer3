function [err, msg] = downloadSharedLibs()
[err, msg] = gitSubmodulesUpdate();

