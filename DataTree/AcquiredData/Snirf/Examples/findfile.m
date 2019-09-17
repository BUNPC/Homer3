function fnamefullpath = findfile(rootdirexamples, fname, currdir)

fnamefullpath = [rootdirexamples, fname];
if ~exist(fname, 'file')
    msg = sprintf('%s does not exist. You first have to generate it by running demo_snirf\n', fnamefullpath);
    MenuBox(msg, 'OK');
    fnamefullpath = '';
    cd(currdir);
    return;
end
