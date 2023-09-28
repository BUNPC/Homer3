function fnamefullpath = findfile(rootdirexamples, fname)

fnamefullpath = [rootdirexamples, fname];
if ~exist(fnamefullpath, 'file')
    msg = sprintf('%s does not exist. You first have to generate it by running demo_snirf\n', fnamefullpath);
    MenuBox(msg, 'OK');
    fnamefullpath = '';
    return;
end
