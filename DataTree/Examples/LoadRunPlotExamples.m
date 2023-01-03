function LoadRunPlotExamples(rootdir, rooturl, branch, dataSetDir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('rootdir','var')
    rootdir = pwd;
end
if ~exist('rooturl','var')
    rooturl = 'https://github.com/jayd1860/DataTree';
end
if ~exist('branch','var')
    branch = 'development';
end
if ~exist('dataSetDir','var')
    dataSetDir = [pwd, '/emptyDataSet'];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Download DataTree by running git clone command from 
%    matlab command window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(rootdir,'dir')
    mkdir(rootdir)
end
cmd = sprintf('git clone -b %s %s/%s', branch, rooturl, rootdir);
        system(cmd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a) Change current folder to DataTree root folder and 
% b) initialize the DataTree repo - that is, download
%       dependensies and set search paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(rootdir);
initialize


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a) Change current folder to a data set folder, 
% b) Load dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(dataSetDir,'dir')
    mkdir(dataSetDir);
    end
cd(dataSetDir) 
dataTree = DataTreeClass();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot raw data for current element for channels 6 nd 7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataTree.currElem.Plot('raw',[6,7]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot raw data for 2nd run of the 1st session, 3rd subject,  
% for channels 6 nd 7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataTree.group(1).subjs(3).sess(1).runs(2).Plot('raw',[6,7]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run processing stream for current element and plot 
% concentration HRF for channels 2,3 and 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataTree.currElem.Calc();
dataTree.currElem.Plot('conc hrf',[2,3,4]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run processing stream for the first group and plot it's
% concentration HRF for channels 2,3 and 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataTree.group(1).Calc();
dataTree.group(1).Plot('conc hrf', [2,3,4]);




