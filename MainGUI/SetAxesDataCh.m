function SetAxesDataCh(handles, eventdata)

if ~exist('eventdata','var')
    eventdata = [];
end

% Find which channels were selected from axesSDG
SetAxesSDGCh(handles, eventdata);

