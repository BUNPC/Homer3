function [status, ut] = unitTest_MainGUI_GenerateHRF(datafmt, dirname)
global logger
global testidx 
global UNIT_TEST

if isempty(testidx)
    testidx=0;
end
testidx=testidx+1;

status = 0;

UNIT_TEST = 1; %#ok<NASGU>

logger.Write('################################################################');
logger.Write(sprintf('Running test #%d - unitTest_MainGUI_GenerateHRF(''%s'', ''%s'')\n', testidx, datafmt, dirname));
fprintf('\n');

[ut, currpath] = launchHomer3(datafmt, dirname);
pos = selectAxesPoint(ut);
try 
    global maingui
    
    logger.Write('unitTest_MainGUI_GenerateHRF: Select channel in SDG axes.\n');
    ut.callbacks.axesSDG(ut.handles.axesSDG, pos, ut.handles);
    pause(3);

    logger.Write('unitTest_MainGUI_GenerateHRF: Select Group radiobutton group in "Current Processing Element" panel.\n');
    selectProcLevel(1, ut)
    ut.callbacks.radiobuttonProcTypeGroup(ut.handles.radiobuttonProcTypeGroup, [], ut.handles);    
    pause(3);
    
    logger.Write('unitTest_MainGUI_GenerateHRF: Run processing stream using "RUN" pushbutton.\n');
    ut.callbacks.pushbuttonCalcProcStream(ut.handles.pushbuttonCalcProcStream, [], ut.handles);    
    pause(3);
        
    maingui.dataTree.ResetAllGroups();
    
catch
    
    status = -1;
    
end
UNIT_TEST = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Report results of the comparison
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logger.Write(sprintf('\n'));
if status==0
    logger.Write(sprintf('#%d - unitTest_MainGUI_GenerateHRF(''%s'', ''%s''): TEST PASSED.\n', testidx, datafmt, dirname));
else
    logger.Write(sprintf('#%d - unitTest_MainGUI_GenerateHRF(''%s'', ''%s''): TEST FAILED\n', testidx, datafmt, dirname));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean up before exiting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logger.Write('\n');
logger.Close('unitTest_MainGUI_GenerateHRF');

cd(currpath);


% -----------------------------------------------
function pos = selectAxesPoint(ut)
xlim = get(ut.handles.axesSDG, 'xlim');
ylim = get(ut.handles.axesSDG, 'ylim');
pos = [(xlim(2)-xlim(1))/2, (ylim(2)-ylim(1))/2];



% -----------------------------------------------
function selectProcLevel(level, ut)

switch(level)
    case 1
        set(ut.handles.radiobuttonProcTypeGroup, 'value', 1);
        set(ut.handles.radiobuttonProcTypeSubj, 'value', 0);
        set(ut.handles.radiobuttonProcTypeRun, 'value', 0);
    case 2
        set(ut.handles.radiobuttonProcTypeGroup, 'value', 0);
        set(ut.handles.radiobuttonProcTypeSubj, 'value', 1);
        set(ut.handles.radiobuttonProcTypeRun, 'value', 0);
    case 3
        set(ut.handles.radiobuttonProcTypeGroup, 'value', 0);
        set(ut.handles.radiobuttonProcTypeSubj, 'value', 0);
        set(ut.handles.radiobuttonProcTypeRun, 'value', 1);
end

