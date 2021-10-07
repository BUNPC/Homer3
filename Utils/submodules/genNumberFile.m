function genNumberFile()
s = parseGitSubmodulesFile();
for ii = 1:size(s,1)
    filename = [s{ii,2}, '.numberfiles'];
    fid = fopen(filename,'wt');
    files = findAllFiles(s{ii,3});
    fprintf(fid, '%s', num2str(length(files)));
    fclose(fid);
end
fclose('all');


