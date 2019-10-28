#!sh

rm -rf ~/Desktop/Homer3*
rm -rf ~/Desktop/SubjDataSample

perl ~/Downloads/homer3_install/makefinalapp.pl ~/homer3/run_Homer3.sh ~/Desktop/Homer3.$1
ln -s ~/homer3/SubjDataSample ~/Desktop/SubjDataSample

chmod 755 ~/Desktop/Homer3.$1
chmod 755 ~/Desktop/SubjDataSample

exit
