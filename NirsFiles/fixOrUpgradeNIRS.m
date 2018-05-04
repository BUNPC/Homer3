function [err, ch_all] = fixOrUpgradeNIRS(err,files)

warning('off','MATLAB:load:variableNotFound');

nFiles = length(files);
ch_all = zeros(length(files));
yestoallflag = 0;
informUserFilesCopiedFlag = 0;
spatialUnits = 0;
for iF=1:nFiles
    
    if err(iF).errCount>0  &&  err(iF).FileCorrupt==0 &&  ~files(iF).isdir        
        
        if yestoallflag==1  
            ch=2;
        else
            if err(iF).errCount>0
                ch = menu(sprintf('Error in %s files.\nDo you want to try to fix it?',files(iF).name),...
                                  'Yes','Yes to All','No','No to All');
            elseif err(iF).warningCount>0
                ch = menu(sprintf('Obsolete format in %s files.\nDo you want to try to upgrade to current format?',files(iF).name),...
                                  'Yes','Yes to All','No','No to All');
            end
        end
        ch_all(iF) = ch;
        
        if ch==1 || ch==2
            
            % User chose to fix file. 
            savestr = [];

            % Error handling for d
            if err(iF).d~=0
                load(files(iF).name,'-mat','d');
                
                if bitand(err(iF).d,4)
                    load(files(iF).name,'-mat','t');
                    m = size(d,1);
                    n = length(t);
                    q = n-m;
                    if q>0
                        d=[d; zeros(q,size(d,2))];
                    elseif q<0
                        d(m+q+1:m,:)=[];
                    end
                    err(iF).d = bitxor(err(iF).d,4);
                end
                
                if err(iF).d==0
                    err(iF).errCount = err(iF).errCount-1;
                    savestr = [savestr '''d'','];
                end
            end

            
            % Error handling for s
            if err(iF).s~=0
                load(files(iF).name,'-mat','s');
                
                if bitand(err(iF).s,1)
                    load(files(iF).name,'-mat','t');
                    s = zeros(length(t),1);
                    err(iF).s = bitxor(err(iF).s,1);
                end
                if bitand(err(iF).s,4)
                    load(files(iF).name,'-mat','t');
                    m = size(s,1);
                    n = length(t);
                    q = n-m;
                    if q>0
                        s=[s; zeros(q,size(s,2))];
                    elseif q<0
                        s(m+q+1:m,:)=[];
                    end
                    err(iF).s = bitxor(err(iF).s,4);         
                end
                if bitand(err(iF).s,8)
                    for jj=1:size(s,2)
                        k = find(~ismember(s(:,jj),-2:2));
                        s(k,jj)=0;
                    end
                    err(iF).s = bitxor(err(iF).s,8);
                end
                if bitand(err(iF).s,16)
                    load(files(iF).name,'-mat','t');
                    n = length(t);
                    s = zeros(n,1);
                    err(iF).s = bitxor(err(iF).s,16);
                end
                
                if err(iF).s==0
                    err(iF).errCount = err(iF).errCount-1;
                    savestr = [savestr '''s'','];
                end
            end

            
            % Error handling for aux
            if err(iF).aux~=0                
                load(files(iF).name,'-mat','aux');

                if bitand(err(iF).aux,2)
                    load(files(iF).name,'-mat','aux10');
                    aux = aux10;
                    err(iF).aux = bitxor(err(iF).aux,2);
                end
                if bitand(err(iF).aux,8)
                    load(files(iF).name,'-mat','t');
                    m = size(aux,1);
                    n = length(t);
                    q = n-m;
                    if q>0
                        aux=[aux; zeros(q,size(aux,2))];
                    elseif q<0
                        aux(m+q+1:m,:)=[];
                    end
                    err(iF).aux = bitxor(err(iF).aux,8);
                end
                if bitand(err(iF).aux,16)
                    load(files(iF).name,'-mat','t');
                    n = length(t);
                    aux = zeros(n,1);
                    err(iF).aux = bitxor(err(iF).aux,16);
                end
                
                if err(iF).aux==0
                    err(iF).errCount = err(iF).errCount-1;
                    savestr = [savestr '''aux'','];
                end
            end
            
            
            % Error handling for SD_MeasList
            if err(iF).SD_MeasList~=0
                load(files(iF).name,'-mat','SD');
                                               
                if bitand(err(iF).SD_MeasList,2)
                    m=size(SD.MeasList,1);
                    n=size(SD.MeasListAct,1);
                    d = m-n;
                    if d>0
                        SD.MeasListAct = [SD.MeasListAct; ones(d,1)];
                    elseif d<0
                        SD.MeasListAct(m+d+1:m) = [];
                    end
                    err(iF).SD_MeasList = bitxor(err(iF).SD_MeasList,2);                    
                end
                
                if bitand(err(iF).SD_MeasList,4)
                    m=size(SD.MeasList,1);
                    n=size(SD.MeasListVis,1);
                    d = m-n;
                    if d>0
                        SD.MeasListVis = [SD.MeasListVis; ones(d,1)];
                    elseif d<0
                        SD.MeasListVis(m+d+1:m) = [];
                    end
                    err(iF).SD_MeasList = bitxor(err(iF).SD_MeasList,4);                    
                end
                
                if err(iF).SD_MeasList==0
                    err(iF).errCount = err(iF).errCount-1;
                    savestr = [savestr '''SD'','];
                end
            end
            
            % Error handling for SD_SpatialUnit
            if err(iF).SD_SpatialUnit~=0
                load(files(iF).name,'-mat','SD');
                
                if bitand(err(iF).SD_SpatialUnit,1)
                    err(iF).SD_SpatialUnit = bitxor(err(iF).SD_SpatialUnit,1);
                end
                
                if spatialUnits==0
                    spatialUnits = menu('What spatial units are used for the optode positions?','cm','mm','Do not know');
                end
                flagFix = 0;
                if spatialUnits==1
                    spatialUnits = menu('We will convert cm to mm for you.','Okay','Cancel');
                    if spatialUnits==1
                        SD.SpatialUnit = 'mm';
                        SD.SrcPos = SD.SrcPos * 10;
                        SD.DetPos = SD.DetPos * 10;
                        if isfield(SD,'SpringList')
                            if ~isempty(SD.SpringList)
	                            lst = find(SD.SpringList(:,3)~=-1);
	                            SD.SpringList(lst,3) = SD.SpringList(lst,3) * 10;
                            end
                        end
                        flagFix = 1;
                    end
                elseif spatialUnits==2
                    SD.SpatialUnit = 'mm';
                    flagFix = 1;
                end
                                
                if flagFix==1
                    if err(iF).SD_SpatialUnit==0
                        err(iF).errCount = err(iF).errCount-1;
                        savestr = [savestr '''SD'','];
                    end
                end
            end
            
            
            % Error handling for SD_auxChannels
            if err(iF).SD_auxChannels~=0
                load(files(iF).name,'-mat','SD','aux','aux10');
                if ~exist('aux','var')
                    if ~exist('aux10','var')
                        aux = zeros(n,1);
                    else
                        aux = aux10;
                    end
                end
                
                if bitand(err(iF).SD_auxChannels,1)
                    SD.auxChannels = {};
                    m=length(SD.auxChannels);
                    for ii=1:size(aux,2)
                        SD.auxChannels{ii} = ['Aux ',num2str(ii)];
                    end
                end
                
                if err(iF).SD_MeasList==0
                    err(iF).errCount = err(iF).errCount-1;
                    savestr = [savestr '''SD'','];
                end
            end
            
            
            % Error handling for procInput
            if err(iF).procInput_SD~=0
                load(files(iF).name,'-mat','procInput','SD');
                
                if exist('SD','var')
                    procInput.SD = SD;
                    err(iF).procInput_SD = bitxor(err(iF).procInput_SD,1);
                    err(iF).errCount = err(iF).errCount-1;
                end
                
                if err(iF).procInput_SD==0
                    err(iF).errCount = err(iF).errCount-1;
                    savestr = [savestr '''procInput'','];
                end
            end
            
            
            % Error handling for CondNames
            if err(iF).CondNames~=0
                load(files(iF).name,'-mat','CondNames','s');
                
                if bitand(err(iF).CondNames,1)
                    CondNames = stimCondInit(s,CondNames);
                    err(iF).CondNames = bitxor(err(iF).CondNames,1);
                end
                if bitand(err(iF).CondNames,2)
                    CondNames = stimCondInit(s,CondNames);
                    err(iF).CondNames = bitxor(err(iF).CondNames,2);
                end
                if bitand(err(iF).CondNames,4)
                    if length(CondNames)<size(s,2)
                        for ii=length(CondNames)+1:size(s,2)
                            jj = ii;
                            while ~isempty(find(strcmp(CondNames, num2str(jj))))
                                jj = jj + 10;
                            end
                            CondNames{ii} = num2str(jj);
                        end
                    else
                        for ii=1:size(s,2)
                            boo{ii} = CondNames{ii};
                        end
                        CondNames = boo;
                    end
                    err(iF).CondNames = bitxor(err(iF).CondNames,4);
                end
                
                if err(iF).CondNames==0
                    err(iF).errCount = err(iF).errCount-1;
                    savestr = [savestr '''CondNames'','];
                end
            end
            
            
            % Add more NIRS variable fixes here
            
            
            % Now save fixed parameters to nirs files only if all errors
            % were fixed. Otherwise tell user can't fix it and do nothing.
            if err(iF).errCount==0
                
                hwait = waitbar(0,sprintf('Saving fixed %s file. This may take a few seconds...',files(iF).name));
                if ~exist([files(iF).name '.orig'],'file')
                    copyfile(files(iF).name,[files(iF).name '.orig']);
                end
                eval( sprintf('save( files(iF).name, %s, ''-mat'',''-append'' );', savestr(1:end-1)) );
                informUserFilesCopiedFlag = informUserFilesCopiedFlag+1;
                close(hwait);

                % files(iF).subjdiridx is only relevant if we have separate subject
                % directories. Otherwise files(iF).subjdiridx is zero and
                % we ignore it.
                if files(iF).subjdiridx
                    err(files(iF).subjdiridx).errCount=0;
                end

            else
                menu(sprintf('Can''t fix file %s. Skipping...',files(iF).name), 'OK');
            end
            
            if ch==2
                yestoallflag=1;
            end
            
        elseif ch==3
            
            continue;
            
        elseif ch==4
            
            return;
            
        end
    end   
end
if informUserFilesCopiedFlag == 1
    menu(sprintf('%d error fixed - original .nirs file saved to .nirs.orig', informUserFilesCopiedFlag),'OK');
elseif informUserFilesCopiedFlag > 1
    menu(sprintf('%d errors fixed - original .nirs files saved to .nirs.orig', informUserFilesCopiedFlag),'OK');
end
warning('on','MATLAB:load:variableNotFound');
