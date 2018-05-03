function currElem = UpdateCurrElemProcStreamOptionsGUI(currElem)

% Update only if the gui is already active. Otherwise do nothing
pos=[];
if ishandles(currElem.handles.ProcStreamOptionsGUI)
    % Get position in character units
    set(currElem.handles.ProcStreamOptionsGUI, 'units','characters');
    pos = get(currElem.handles.ProcStreamOptionsGUI, 'position');
    
    % Race condition in matlab versions 2014b and higher: give some time  
    % for set/get to finish before deleting GUI
    pause(0.1);
    delete(currElem.handles.ProcStreamOptionsGUI);
    
    % Another race condition, which might make GUI disappear when going through files in the 
    % listboxFiles and this time in any matlab version with the
    % ProcStreamOptionsGUI active
    pause(0.1);
    currElem.handles.ProcStreamOptionsGUI = ProcStreamOptionsGUI(currElem, pos, 'userargs');
end
