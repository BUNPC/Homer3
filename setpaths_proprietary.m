function setpaths_proprietary(options)

% Check if wavelet data db2.mat is available in toolbox.
% If no then create it from known data
fullpathhomer3 = fileparts(which('Homer3.m'));
if fullpathhomer3(end)~='/' & fullpathhomer3(end)~='\'
    fullpathhomer3(end+1)='/';
end
findWaveletDb2([fullpathhomer3, 'Install/']);
