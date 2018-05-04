function [files, filesErr, errmsg] = getNIRSFileErrors(files)

%
% [files filesErr errmsg] = getNIRSFileErrors(files)
%
% Standalone function to check errors in a .nirs files set and 
% output the files that pass the .nirs error check and those that 
% don't.
%

filesErr = [];
nFiles = length(files);
errmsg = {};

flags = checkNIRSFormat(files);

count=1;
for iF=1:nFiles

    flags(iF).errCount=0;
    flags(iF).warningCount=0;
    errmsg_tmp = [files(iF).name ':  '];

    % First is the file a .mat file format
    if flags(iF).FileCorrupt~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: file corrupt or not valid .mat file.', flags(iF).errCount)];
    end
    
    % d
    if flags(iF).d~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: Invalid data matrix (d). ', flags(iF).errCount)];
    end
        
    % SD
    if flags(iF).SD~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD structure invalid;  ',flags(iF).errCount)];
    end    
    if flags(iF).SD_SrcPos~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD has invalid SrcPos;  ',flags(iF).errCount)];
    end    
    if flags(iF).SD_DetPos~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD has invalid DetPos;  ',flags(iF).errCount)];
    end
    if flags(iF).SD_MeasList~=0
        flags(iF).errCount = flags(iF).errCount+1;
        if bitand(flags(iF).SD_MeasList,1)
            errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD Measlist is invalid or doesn''t exist;  ',flags(iF).errCount)];
        elseif bitand(flags(iF).SD_MeasList,2)
            errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD MeasList differs in size with MeasListAct;  ',flags(iF).errCount)];
        elseif bitand(flags(iF).SD_MeasList,4)
            errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD MeasList differs in size with MeasListVis;  ',flags(iF).errCount)];
        end
    end
    if flags(iF).SD_Lambda~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD has invalid Lambda;  ',flags(iF).errCount)];
    end
    if flags(iF).SD_SpatialUnit~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD has invalid SpatialUnit;  ',flags(iF).errCount)];
    end
    if flags(iF).SD_auxChannels~=0
        flags(iF).errCount = flags(iF).errCount+1;
        if bitand(flags(iF).SD_auxChannels,1)        
            errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD auxChannels must be an array of string names;  ',flags(iF).errCount)];
        end
    end

    % t
    if flags(iF).t~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: invalid time vector (t);  ',flags(iF).errCount)];
    end
    
    % s
    if flags(iF).s~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: invalid stim matrix (s);  ',flags(iF).errCount)];            
    end
    
    % aux
    if flags(iF).aux~=0 
        flags(iF).errCount = flags(iF).errCount+1;
        if bitand(flags(iF).aux,1)
            errmsg_tmp = [errmsg_tmp sprintf('%d) Error: auxiliary matrix (aux) is missing;  ',flags(iF).errCount)];
        elseif bitand(flags(iF).aux,2)
            errmsg_tmp = [errmsg_tmp sprintf('%d) Error: auxiliary matrix (aux) has an obsolete name (aux10);  ',flags(iF).errCount)];
        else
            errmsg_tmp = [errmsg_tmp sprintf('%d) Error: invalid auxiliary matrix (aux);  ',flags(iF).errCount)];
        end
    end

    % procInput
    if flags(iF).procInput_procFunc~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: missing procFunc in procInput;  ',flags(iF).errCount)];
    end    
    if flags(iF).procInput_procParam~=0
        flags(iF).errCount = flags(iF).errCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: missing procParam in procInput;  ',flags(iF).errCount)];
    end    
    if flags(iF).procInput_changeFlag~=0
        flags(iF).warningCount = flags(iF).warningCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Warning: Older format - missing changeFlag in procInput;  ',...
                                         flags(iF).errCount+flags(iF).warningCount)];
    end
    if flags(iF).procInput_SD~=0
        flags(iF).warningCount=flags(iF).warningCount+1;
        errmsg_tmp = [errmsg_tmp sprintf('%d) Warning: Older format - missing SD in procInput;  ',...
                                         flags(iF).errCount+flags(iF).warningCount)];
    end
    
    
    % CondNames
    if flags(iF).CondNames~=0
        flags(iF).errCount = flags(iF).errCount+1;
        if bitand(flags(iF).CondNames,1)
            errmsg_tmp = [errmsg_tmp sprintf('%d) Error: CondNames has unassigned conditions;  ',...
                                             flags(iF).errCount+flags(iF).warningCount)];
        elseif bitand(flags(iF).CondNames,2)
            errmsg_tmp = [errmsg_tmp sprintf('%d) Error: CondNames has duplicate conditions names;  ',...
                                             flags(iF).errCount+flags(iF).warningCount)];
        elseif bitand(flags(iF).CondNames,4)
            errmsg_tmp = [errmsg_tmp sprintf('%d) Error: length(CondNames) ~= Columns in s;  ',...
                                             flags(iF).errCount+flags(iF).warningCount)];
        end
    end
    
    
    %%% Tally up the errors and error count.
    if flags(iF).errCount==0 && flags(iF).warningCount==0
        continue;
    end
    flags(iF).subj = 1; 
    if flags(iF).errCount>0 && files(iF).subjdiridx
        flags(files(iF).subjdiridx).errCount=1;
    end
    if flags(iF).warningCount>0 && files(iF).subjdiridx
        flags(files(iF).subjdiridx).warningCount=1;
    end
    errmsg{count} = errmsg_tmp;    
    count=count+1;
    
end

if ~isempty(errmsg)
    hFig = figure('numbertitle','off','menubar','none','name','Errors Found','units','pixels',...
                  'position',[200 500 350 450],'resize','on'); 
    hErrListbox = uicontrol('parent',hFig,'style','listbox','string',errmsg,...
                            'units','normalized','position',[.1 .25 .8 .7],'value',1);
    hButtn = uicontrol('parent',hFig,'style','pushbutton','tag','pushbuttonOk',...
                       'string','Ok','units','normalized','position',[.2 .1 .25 .1],...
                       'callback',@pushbuttonOk_Callback);
    set(hFig,'units','normalized', 'resize','on');
    p = get(hFig, 'position');
    if p(2)+p(4)>.95
        d = (p(2)+p(4)) - .95;
        set(hFig, 'position', [p(1), p(2)-d, p(3), p(4)]);
    end
    
    % Block execution thread until user presses the Ok button
    while ishandle(hFig)
        pause(1);
    end
    
    flags = fixOrUpgradeNIRS(flags,files);

    % Remove any files from data set that have fatal errors
    filesErr = mydir('');
    jj=1;
    kk=1;
    cc=[];
    for ii=1:length(flags)
        if flags(ii).errCount>0
            filesErr(kk)=files(ii);
            kk=kk+1;
            if ~files(ii).isdir
                cc(jj)=ii;
                jj=jj+1;                
            end
        end
    end
    files(cc)=[];
    
    % remove any directories from 'files' struct if they have no files 
    jj=1;
    cc=[];
    for ii=1:length(files)
        if ii<length(files)
            if files(ii).isdir && files(ii+1).isdir
                cc(jj)=ii;
                jj=jj+1;
            end
        elseif ii==length(files)
            if files(ii).isdir
                cc(jj)=ii;
                jj=jj+1;
            end
        end
    end
    files(cc)=[];
    
end



% -------------------------------------------------------
function pushbuttonOk_Callback(hObject,eventdata)

delete(get(hObject,'parent'));
