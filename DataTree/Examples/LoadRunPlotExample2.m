function LoadRunPlotExample2(dataSetDir)

%
%   Syntax:
%       LoadRunPlotExample2(dataSetDir)
%
%   Description:
%       LoadRunPlotExample2 does the exast same thing as it accesses snirf objects directly without any methods 
%       and then plots them directly in the script to show user how snirf objects work. This script does the following:
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
%       LoadRunPlotExample2('./Examples/Eaxmple4_twNI')
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('dataSetDir','var')
    f = which('LoadRunPlotExample2');
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
t = obj.acquired.data(1).time;
d = obj.acquired.data(1).dataTimeSeries;
id = [obj.iGroup, obj.iSubj, obj.iSess, obj.iRun];
hfig = Plot(t, d, [6,7], obj.GetName(), 'raw', id);
pause(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot raw data for 3rd run of the 1st session, 3rd subject,  
% and 1st group for channels 6 nd 7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.groups(1).subjs(2).sess(1).runs(3);
obj.Load();
t = obj.acquired.data(1).time;
d = obj.acquired.data(1).dataTimeSeries;
hfig = Plot(t, d, [6,7], id, obj.GetName(), 'raw', hfig);
pause(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run processing stream for current element and plot 
% concentration HRF for channels 2,3 and 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.currElem;
obj.Calc();
t = obj.procStream.output.dcAvg.time;
d = obj.procStream.output.dcAvg.dataTimeSeries;
id = [obj.iGroup, obj.iSubj, obj.iSess, obj.iRun];
hfig = Plot(t, d, [2,3,4], id, obj.GetName(), 'conc hrf', hfig);
pause(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run processing stream for the first group and plot it's
% concentration HRF for channels 2,3 and 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj = dataTree.groups(1);
obj.Calc();
t = obj.procStream.output.dcAvg.time;
d = obj.procStream.output.dcAvg.dataTimeSeries;
id = [obj.iGroup, obj.iSubj, obj.iSess, obj.iRun];
Plot(t, d, [2,3,4], id, obj.GetName(), 'conc hrf', hfig);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close open log file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj.logger.Close();




% ------------------------------------------------------------------------------------
function hfig = Plot(t, d, iChs, id, name, datatype, hfig)
if ~exist('hfig','var')
    hfig = [];
end
if ishandles(hfig)
    close(hfig);
end
hfig = figure;
figname = sprintf('PROCESSING ELEMENT: "%s" (ID = [%s]) ;   DATATYPE: "%s";   CHANNELS: [ %s ]', name, ...
    num2str(id), datatype, num2str(iChs));
namesize = uint32(length(figname)/2);
set(hfig, 'units','characters');
p1 = get(hfig, 'position');
set(hfig, 'name',figname, 'menubar','none', 'NumberTitle','off', 'position',[p1(1)/2, p1(2), p1(3)+namesize, p1(4)]);
plot(t, d(:, iChs));
hAxes = gca;
set(hAxes, 'xlim', [t(1), t(end)]);



