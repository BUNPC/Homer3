function EditStimExample(dataSetDir)

%
%   Syntax:
%       EditStimExample(dataSetDir)
%
%   Description:
%       This script shows how to export and edit stim and conditions. This script does the following:
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
%       4. Plot raw data with stim for current element 
%       5. Export stim for current element if the events TSV file does not
%          exist
%       6. Re-plot raw data with stim for current element showing edited stim
%          and conditions
%
%   Examples:
%       cd <local_path>/DataTree
%       EditStimExample('./Examples/SampleData')
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('dataSetDir','var')
    f = which('EditStimExample');
    dataSetDir = [fileparts(f), '/SampleData']; 
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
    MenuBox('No data set was loaded', 'OK');
    return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This step is NOT essential, but is a good idea in order to
% set up logging and load config settings, something that 
% would normally be done by the parent GUI. Since we are 
% running data tree standalone initilize logger an config 
% settings here instead of through parent gui like Homer3 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global logger
global cfg

logger = Logger('DataTreeClass');
cfg = ConfigFileClass();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Plot raw data for current element for channel 2
% 2. Export stim for the current element
% 3. Edit stim in the events TSV file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.currElem;
obj.Load();
h = obj.Plot('raw', [1,2,0,1]);
repositionFigures(h);         % Local function to reposition figures so they can be all be seen on screen at once

obj.ExportStim();

pause(2);

obj.EditStim(1);

obj.ClosePlots();
dataTree.ReloadStim();
h = obj.Plot('raw', [1,2,0,1]);
repositionFigures(h);         % Local function to reposition figures so they can be all be seen on screen at once


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close open log file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj.logger.Close();





% -------------------------------------------------------------------------
function editorTab = EditEventsTsvFile_InMatlabEditor(obj, dataSetDir)
% Get file name of data file
filenameData = [dataSetDir, '/', obj.GetFilename()];
[~,f] = fileparts(filenameData);

% From data file name get events TSV file and load in matlab editor
filenameEvents = [dataSetDir, '/', f, '_events.tsv'];

edit(filenameEvents);
editorTabs = matlab.desktop.editor.getAll;

% Search for editor tab containing loaded file and make it active
for ii = 1:length(editorTabs)
    if pathscompare(editorTabs(ii).Filename, filenameEvents)
        break
    end
end
editorTab = editorTabs(ii);
editorTab.makeActive;
MenuBox('Please edit TSV stim file and save it, then click the ''OK'' button.', 'OK');




% -------------------------------------------------------------------
function repositionFigures(h,i)
if ~exist('i','var')
    i = 1;
end
k = find(h(1,:)==-1)-1;
set(h(1,k), 'units','normalized')
set(h(2,k), 'units','normalized')
p1 = get(h(1,k), 'position');
p2 = get(h(2,k), 'position');
set(h(1,k), 'position',[p1(1)-(p1(1)/2),  1.0-(p1(4)+i/10),  p1(3),  p1(4)])
set(h(2,k), 'position',[p2(1)+(p2(1)/2),  1.0-(p2(4)+i/10),  p2(3),  p2(4)])






