function flags = checkNIRSFormat(files)

warning('off','MATLAB:load:variableNotFound');

nFiles = length(files);
flags = initErrFlagsStruct(nFiles);


% NIRS data set format 
hwait = waitbar(0,sprintf('Checking .nirs format for individual files') );
for iF=1:nFiles
    
    waitbar(iF/nFiles,hwait,sprintf('Checking file %d of %d',iF,nFiles));
    if files(iF).isdir
        continue;
    end

    %%%% Before checking the .nirs format make sure first that it's a .mat
    %%%% format. If not we have nothing to work with.
    try
        load( files(iF).name, '-mat','d','t','SD','s','aux','procInput','CondNames');
    catch 
        flags(iF).FileCorrupt = 1;
        continue;
    end

    %%%% t
    if ~exist('t','var')
        flags(iF).t = bitor(flags(iF).t,1);
    else
        if ~isnumeric(t)
            flags(iF).t = bitor(flags(iF).t,2);
        end
        if ~isvector(t)
            flags(iF).t = bitor(flags(iF).t,4);    
        end
    end


    %%%% d
    if ~exist('d','var')
        flags(iF).d = bitor(flags(iF).d,1);
    else
        if ~isnumeric(d)
            flags(iF).d = bitor(flags(iF).d,2);
        end
        if size(d,1)~=length(t)
            flags(iF).d = bitor(flags(iF).d,4);
        end
        if exist('SD','var') && isfield(SD,'MeasList')            
            if size(d,2)~=size(SD.MeasList,1)
                flags(iF).d = bitor(flags(iF).d,8);
            end           
        end
    end


    %%%% SD    
    if ~exist('SD','var') || isempty(SD)
        flags(iF).SD=bitor(flags(iF).SD,1)
    end
    if ~isfield(SD,'Lambda') || isempty(SD.Lambda)
        flags(iF).SD_Lambda=bitor(flags(iF).SD_Lambda,1);
    end
    if ~isfield(SD,'SrcPos') || isempty(SD.SrcPos)
        flags(iF).SD_SrcPos=bitor(flags(iF).SD_SrcPos,1);
    end
    if ~isfield(SD,'nSrcs')
        flags(iF).SD_nSrcs=bitor(flags(iF).SD_nSrcs,1);
    end
    if ~isfield(SD,'DetPos') || isempty(SD.DetPos)
        flags(iF).SD_DetPos=bitor(flags(iF).SD_DetPos,1);
    end
    if ~isfield(SD,'nDets')
        flags(iF).SD_nDets=bitor(flags(iF).SD_nDets,1);
    end
    if ~isfield(SD,'MeasList') || isempty(SD.MeasList)
        flags(iF).SD_MeasList=bitor(flags(iF).SD_MeasList,1);
    end
    if isfield(SD,'MeasList') && isfield(SD,'MeasListAct')
        if size(SD.MeasList,1) ~= size(SD.MeasListAct,1)
            flags(iF).SD_MeasList=bitor(flags(iF).SD_MeasList,2);
        end
    end
    if isfield(SD,'MeasList') && isfield(SD,'MeasListVis')
        if size(SD.MeasList,1) ~= size(SD.MeasListVis,1)
            flags(iF).SD_MeasList=bitor(flags(iF).SD_MeasList,4);
        end
    end
    if ~isfield(SD,'SpatialUnit')
        flags(iF).SD_SpatialUnit=bitor(flags(iF).SD_SpatialUnit,1);
    end
    

    %%%%% s
    if ~exist('s')
        flags(iF).s = bitor(flags(iF).s,1);
    else
        if ~isnumeric(s)
            flags(iF).s = bitor(flags(iF).s,2);
        end
        if size(s,1)~=length(t)
            flags(iF).s = bitor(flags(iF).s,4);
        end
        for jj=1:size(s,2) 
            if ~isempty(find(~ismember(s(:,jj),-2:2),1))
                flags(iF).s = bitor(flags(iF).s,8);
                break;
            end
        end
        if isempty(s)
            flags(iF).s = bitor(flags(iF).s,16);
        end
    end


    %%%%% aux
    if ~exist('aux')
        load( files(iF).name, '-mat','aux10');
        if exist('aux10','var')
            flags(iF).aux = bitor(flags(iF).aux,2);
        else
            flags(iF).aux = bitor(flags(iF).aux,1);
        end
    else
        if ~isnumeric(aux)
            flags(iF).aux = bitor(flags(iF).aux,4);
        end
        if size(aux,1)~=length(t)
            flags(iF).aux = bitor(flags(iF).aux,8);
        end
        if isempty(aux)
            flags(iF).aux = bitor(flags(iF).aux,16);
        end
        %{
        if ~isfield(SD,'auxChannels') || size(aux,2)~=length(SD.auxChannels)
            flags(iF).aux = bitor(flags(iF).aux,8);
        end
        %}
    end

    
    %%%%% procInput
    if exist('procInput','var')
        if ~isstruct(procInput)
            flags(iF).procInput=bitor(flags(iF).procInput,1);
        else
            if ~isfield(procInput,'procFunc')
                flags(iF).procInput_procFunc=bitor(flags(iF).procInput_procFun,1);
            end
            if ~isfield(procInput,'procParam')
                flags(iF).procInput_procParam=bitor(flags(iF).procInput_procParam,1);
            end
            if ~isfield(procInput,'changeFlag')
                flags(iF).procInput_changeFlag=bitor(flags(iF).procInput_changeFlag,1);
            end
        end
        %{
        if ~isfield(procInput,'SD')
            flags(iF).procInput.SD=1;
        end
        %}
    end
    
    
    %%%%% CondNames
    if exist('CondNames','var')
        if ~isempty(find(strcmp('',CondNames)))                    
            flags(iF).CondNames = bitor(flags(iF).CondNames,1);
        end
        for ii=1:length(CondNames)
            k=find(strcmp(CondNames{ii},CondNames));
            if length(k)>1
                flags(iF).CondNames = bitor(flags(iF).CondNames,2);
            end
        end
        if exist('s')
            if length(CondNames)~=size(s,2)
                flags(iF).CondNames = bitor(flags(iF).CondNames,4);
            end
        end
    end
    
    clear('d','t','SD','s','aux','procInput','CondNames');
    
end
close(hwait);

warning('on','MATLAB:load:variableNotFound');

