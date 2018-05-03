function [loadDataOut uniqueSD] = checkNIRSFormatAcrossFiles( files )

loadDataOut=0;
nFiles = length(files);
uniqueSD = zeros(1,nFiles);

if isempty(files)    
    return;
end

global loadData
loadDataOut=0;

SDo = {};

hwait = waitbar(0,sprintf('Checking .nirs format consistency across files: processing 1 of %d',nFiles) );
for iF=1:nFiles

    waitbar(iF/nFiles,hwait,sprintf('Checking .nirs format consistency across files: processing %d of %d',iF,nFiles));
    if files(iF).isdir
        continue;
    end    
    load( files(iF).name, '-mat','SD');
    
    % Easy fix if nSrcs or nDets aren't there
    if ~isfield(SD,'nSrcs')
        SD.nSrcs = size(SD.SrcPos,1);
    end
    if ~isfield(SD,'nDets')
        SD.nDets = size(SD.DetPos,1);
    end
    
    if isempty(SDo)
        SDo{1} = SD;
        nSD = 1;
        uniqueSD(iF) = 1;
    end
       
    
    % Compare SD geometries
    flag = [];
    for iSD = 1:nSD
        flag(iSD) = 0;
        if ~isequal(SD.Lambda, SDo{iSD}.Lambda)
            flag(iSD) = 1;
        end
        if ~isequal(SD.SrcPos, SDo{iSD}.SrcPos)
            flag(iSD) = 1;
        end
        if ~isequal(SD.DetPos, SDo{iSD}.DetPos)
            flag(iSD) = 1;
        end
        if ~isequal(SD.MeasList, SDo{iSD}.MeasList)
            flag(iSD) = 1;
        end
    end
    lst = find(flag==0);
    if ~isempty(lst)
        uniqueSD(iF) = lst(1);
    end
    
    % If they don't compare we have a new SD structure. Possible
    % incompatibility
    if uniqueSD(iF)==0
        nSD = nSD + 1;
        SDo{nSD} = SD;
        uniqueSD(iF) = nSD;
    end
    
end
close(hwait);


% Report results
nSD = length(SDo);
if nSD > 1
    loadData = -1;

    count = 1;
    for ii=1:nSD
        errmsg{count} = sprintf('SD%d',ii);
        kk = find(uniqueSD==ii);
        for jj=1:length(kk)
            errmsg{count+jj} = sprintf('  %s',files(kk(jj)).name);
        end
        count = count+jj+1;
    end

    hFig = figure('numbertitle','off','menubar','none','name','NIRS Group Error Report','units','pixels',...
                  'position',[200 500 300 450],'resize','on'); 

    hErrListbox = uicontrol('parent',hFig,'style','listbox','string',errmsg,...
                            'units','normalized','position',[.1 .25 .8 .7],'value',1);
    hErrText = uicontrol('parent',hFig,'style','text','string','WARNING: More than one SD geometry found. Might cause errors.',...
                         'units','normalized',    'position',[.1 .15 .7 .055],'horizontalalignment','left');
    hErrText2 = uicontrol('parent',hFig,'style','text','string','Do you still want to load this data set or select a different one?',...
                          'units','normalized',   'position',[.1 .095 .7 .055],'horizontalalignment','left');
    hButtnLoad = uicontrol('parent',hFig,'style','pushbutton','tag','pushbuttonLoad',...
                           'string','Load','units','normalized','position',[.2 .03 .20 .05],...
                           'callback',@pushbuttonLoadDataset_Callback);
    hButtnSelectAnother = uicontrol('parent',hFig,'style','pushbutton','tag','pushbuttonSelectAnother',...
                             'string','Select Another','units','normalized','position',[.4 .03 .30 .05],...
                             'callback',@pushbuttonLoadDataset_Callback);
 
    set(hErrText,'units','pixels');
    set(hErrText2,'units','pixels');
    set(hButtnLoad,'units','pixels');
    set(hButtnSelectAnother,'units','pixels');
    
    % Block execution thread until user presses the Ok button
    while loadData==-1
        pause(1);
    end
    
else
    loadData = 1;
end

loadDataOut = loadData;




% -------------------------------------------------------
function pushbuttonLoadDataset_Callback(hObject,eventdata)
global loadData

hp = get(hObject,'parent');
hc = get(hp,'children');
for ii=1:length(hc)

    if strcmp(get(hc(ii),'tag'),'pushbuttonLoad')
        hButtnLoad = hc(ii);
    elseif strcmp(get(hc(ii),'tag'),'pushbuttonSelectAnother')
        hButtnSelectAnother = hc(ii);
    end

end

if hObject==hButtnLoad
    delete(hButtnSelectAnother);
    loadData = 1;
elseif hObject==hButtnSelectAnother
    delete(hButtnLoad);
    loadData = 0;
end
delete(hp);
