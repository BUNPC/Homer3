function setpaths_proprietary()

r = checkToolboxes();

fprintf('\n');
if all(r==1)
    fprintf('All required toolboxes are installed.\n');
elseif ismember(3, r)
    fprintf('Unable to verify if all required toolboxes are installed ...\n');
elseif ismember(4, r)
    fprintf('Unable to verify if all required toolboxes are installed with older Matlab release...\n');
else
    fprintf('Some required toolboxes are missing...\n');
end

pause(2);
% Check if wavelet data db2.mat is available in toolbox.
% If no then create it from known data
fullpathhomer3 = fileparts(which('Homer3.m'));
if fullpathhomer3(end)~='/' & fullpathhomer3(end)~='\'
    fullpathhomer3(end+1)='/';
end
findWaveletDb2([fullpathhomer3, 'Install/']);
