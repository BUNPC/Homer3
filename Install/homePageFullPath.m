function pathname = homePageFullPath()
pathname = '';
currdir = pwd;
if ismac() || islinux()
    cd('~/');
    pathname = filesepStandard(pwd);
end
cd(currdir)

