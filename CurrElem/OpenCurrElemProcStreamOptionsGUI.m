function currElem = OpenCurrElemProcStreamOptionsGUI(currElem, mode)

if ~exist('mode', 'var') || isempty(mode)
    mode='open';
end

if ~ishandles(currElem.handles.ProcStreamOptionsGUI)
    if strcmp(mode,'open')
        currElem.handles.ProcStreamOptionsGUI = ProcStreamOptionsGUI(currElem, 'userargs');
    end
elseif strcmp(mode,'close')
    delete(currElem.handles.ProcStreamOptionsGUI);
end

