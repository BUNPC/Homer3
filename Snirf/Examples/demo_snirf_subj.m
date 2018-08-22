
files = dir('./*.nirs');

for ii=1:length(files)
    [snirf_saved{ii}, snirf_loaded{ii}, nirs{ii}] = demo_snirf_load_save(files(ii).name);
    fprintf('\n');
end
