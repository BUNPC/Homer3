function LoadRunPlotExample1(dataSetDir)

%
%   Syntax:
%       LoadRunPlotExample1(dataSetDir)
%
%   Description:
%       This script does the following:
%
%       1. If starting from scratch, first download the DataTree repo from
%          github
%
%           a) git clone  -b <branch_name>   https://github.com/<username>/DataTree  <local_path>/DataTree  
%           b) cd <local_path>/DataTree
%           c) setpaths
%
%       2. Change folder to dataSetDir
%       3. Load data set
%       4. Plot raw data for various dataTree elements
%       5. Run processing stream
%       6. Plot HRF for various dataTree elements
%
%   Examples:
%       cd <local_path>/DataTree
%       LoadRunPlotExample1('./Examples/Example4_twNI')
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('dataSetDir','var')
    f = which('LoadRunPlotExample1');
    dataSetDir = [fileparts(f), '/Example4_twNI']; 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a) Change current folder to a data set folder, 
% b) Load dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(dataSetDir,'dir')
    mkdir(dataSetDir);
end
cd(dataSetDir) 
if exist([dataSetDir, '/derivatives']','dir')
    rmdir([dataSetDir, '/derivatives'], 's')
end
dataTree = DataTreeClass();
if dataTree.IsEmpty()
    MenuBox('No data set was loaded',{'OK'});
    return
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This step is NOT essential, but is a good idea in order to
% set up logging. Since we are running data tree standalone 
% initilize logger here which would have been done by parent 
% gui like Homer3 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global logger
logger = Logger('DataTreeClass');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot raw data for current element for channels 6 nd 7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.currElem;
obj.Load();
obj.Plot('raw',[6,7]);
pause(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot raw data for 3rd run of the 1st session, 3rd subject,  
% and 1st group for channels 6 nd 7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.groups(1).subjs(2).sess(1).runs(3);
obj.Load();
obj.Plot('raw',[6,7]);
pause(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run processing stream for current element and plot 
% concentration HRF for channels 2,3 and 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.currElem;
obj.Calc();
obj.Plot('conc hrf',[2,3,4]);
pause(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run processing stream for the first group and plot it's
% concentration HRF for channels 2,3 and 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.groups(1);
obj.Calc();
obj.Plot('conc hrf', [2,3,4]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close open log files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj.logger.Close();

