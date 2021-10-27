function copyFolderContents(pnamesrc, pnamedst)

copyfile([pnamesrc, '/*'], pnamedst);
copyfile([pnamesrc, '/*.*'], pnamedst);
copyfile([pnamesrc, '/.*'], pnamedst);
