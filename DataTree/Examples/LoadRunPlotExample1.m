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
    MenuBox('No data set was loaded', {'OK'});
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
% Plot raw data for current element, for  1st wavelength of 3 source/detector pairs , [2,3], [3,5] and [4,6]:
% (NOTE: for non-HRF, raw, and OD, condition is 0 and datatype refers to wavelength)
%        for non-HRF, concentration, condition is 0 and datatype refers to Hb type)
%
%    ch A:      source idx = 2, detector idx = 3,  condition idx = 0,   datatype idx = 1
%    ch B:      source idx = 3, detector idx = 5,  condition idx = 0,   datatype idx = 1 
%    ch C:      source idx = 4, detector idx = 6,  condition idx = 0,   datatype idx = 1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.currElem;
obj.Load();
sdPairsSelect = [2,3,0,1; 3,5,0,1; 4,6,0,1];  % Channels to plot: 2d array where each channel row is [source idx, detector idx, condition idx, datatype idx]
h = obj.Plot('raw', sdPairsSelect);
repositionFigures(h,1);         % Local function to reposition figures so they can be all be seen on screen at once
pause(2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot raw data for 3rd run of the 1st session, 3rd subject,  
% and 1st group for 2nd wavelength of 3 source/detector pairs, [2,3], [3,5] and [4,6]:
% (NOTE: for non-HRF, raw, and OD, condition is 0 and datatype refers to wavelength)
%        for non-HRF, concentration, condition is 0 and datatype refers to Hb type)
%
%    ch A:      source idx = 2, detector idx = 3,  condition idx = 0,   datatype idx = 2
%    ch B:      source idx = 3, detector idx = 5,  condition idx = 0,   datatype idx = 2 
%    ch C:      source idx = 4, detector idx = 6,  condition idx = 0,   datatype idx = 2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.groups(1).subjs(2).sess(1).runs(3);
obj.Load();
sdPairsSelect = [2,3,0,2; 3,5,0,2; 4,6,0,2];  % Channels to plot: 2d array where each channel row is [source idx, detector idx, condition idx, datatype idx]
h = obj.Plot('raw', sdPairsSelect);
repositionFigures(h,2);          % Local function to reposition figures so they can be all be seen on screen at once
pause(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run processing stream for current element and plot concentration HRF for HbR of condition 1, 
% for 3 channels with source/detector pairs, [2,3], [3,5] and [4,6]:
%
% (NOTE: for HRF data OD, condition is > 0 and datatype refers to wavelength)
%        for HRF data concentration, condition is > 0 and datatype refers to Hb type)
%
%    ch A:      source idx = 2, detector idx = 3,  condition idx = 1,   datatype idx = 2 
%    ch B:      source idx = 3, detector idx = 5,  condition idx = 1,   datatype idx = 2 
%    ch C:      source idx = 4, detector idx = 6,  condition idx = 1,   datatype idx = 2 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.currElem;
obj.Calc();
sdPairsSelect = [2,3,1,2; 3,5,1,2; 4,6,1,2];  % Channels to plot: 2d array where each channel row is [source idx, detector idx, condition idx, datatype idx]
h = obj.Plot('conc hrf', sdPairsSelect);
repositionFigures(h,3);         % Local function to reposition figures so they can be all be seen on screen at once
pause(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run processing stream for group 1 and plot concentration HRF for HbT of condition 2, 
% for 2 channels with source/detector pairs, [3,6] and [4,8]:
%
% (NOTE: for HRF data OD, condition is > 0 and datatype refers to wavelength)
%        for HRF data concentration, condition is > 0 and datatype refers to Hb type)
%
%    ch A:      source idx = 3, detector idx = 6,  condition idx = 2,   datatype idx = 3 
%    ch B:      source idx = 4, detector idx = 8,  condition idx = 2,   datatype idx = 3 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.groups(1);
obj.Calc();
sdPairsSelect = [3,6,2,3; 4,8,2,3];  % Channels to plot: 2d array where each channel row is [source idx, detector idx, condition idx, datatype idx]
h = obj.Plot('conc hrf', sdPairsSelect);
repositionFigures(h,4);         % Local function to reposition figures so they can be all be seen on screen at once
pause(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close open log files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj.logger.Close();
MenuBox('When done, click okay button to close all plots', 'OK');
obj.ClosePlots('all')




% -------------------------------------------------------------------
function repositionFigures(h,i)
k = find(h(1,:)==-1)-1;
set(h(1,k), 'units','normalized')
set(h(2,k), 'units','normalized')
p1 = get(h(1,k), 'position');
p2 = get(h(2,k), 'position');
set(h(1,k), 'position',[p1(1)-(p1(1)/2),  1.0-(p1(4)+i/10),  p1(3),  p1(4)])
set(h(2,k), 'position',[p2(1)+(p2(1)/2),  1.0-(p2(4)+i/10),  p2(3),  p2(4)])






