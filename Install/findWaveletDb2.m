function pathname = findWaveletDb2(dirnameDst)

pathname = fileparts(which('db2.mat'));
if isempty(pathname)
    if isempty(pathname)
        msg{1} = sprintf('Warning: db2.mat wavelet file not found. This may be because the Wavelet Toolbox\n');
        msg{2} = sprintf('in the Matlab version you''re using has stopped supporting it or the Wavelet Toolbox\n');
        msg{3} = sprintf('is missing. Homer3 is generating a db2 file from known values and saving it in the\n');
        msg{4} = sprintf('Install folder\n');
        % menu([msg{:}], 'OK');
        fprintf('%s\n', [msg{:}]);
        fprintf('Generating file %s\n', [dirnameDst, 'db2.mat']);        
        db2 = [0.3415, 0.5915, 0.1585, -0.0915];
        save([dirnameDst, 'db2.mat'],'db2');
    end
else
    if pathname(end)~='/' & pathname(end)~='\'
        pathname(end+1)='/';
    end
end

