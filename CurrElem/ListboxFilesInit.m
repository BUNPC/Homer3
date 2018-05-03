function ListboxFilesInit(currElem, files, filesErr, listboxFiles, listboxFiles2)

% Set graphics objects: text and listboxes if handles exist
if ~ishandles(currElem.handles.listboxFiles)
    return;
end


hText     = currElem.handles.textStatus;
hListbox1 = currElem.handles.listboxFiles;
hListbox2 = currElem.handles.listboxFilesErr;

nFiles = length(files);
nFilesErr = length(filesErr);

% Report status in the status text object 
set( hText, 'string', ...
     {sprintf('%d files loaded successfully',nFiles),...
      sprintf('%d files failed to load',nFilesErr)} );

if ~isempty(files)
    set(hListbox1,'value',1)
    set(hListbox1,'string',listboxFiles)
end
   
if ~isempty(filesErr)
    set(hListbox2,'visible','on');
    set(hListbox2,'value',1);
    set(hListbox2,'string',listboxFiles2)
elseif isempty(filesErr)  && ishandle(hListbox2)
    set(hListbox2,'visible','off');
end

