classdef NirsFilesClass < DataFilesClass
    
    properties
        flags
    end
    
    methods
        
        % -----------------------------------------------------------------------------------
        function obj = NirsFilesClass(varargin)

            % Call base class constructor explicitly in order to pass 
            % our derived class arguments. 
            obj@DataFilesClass(varargin);            
            obj.GetDataSet();
            
        end
        
        
        % -----------------------------------------------------------------------------------
        function GetDataSet(obj)
            
            if exist(obj.pathnm, 'dir')~=7
                error(sprintf('Invalid subject folder: ''%s''', obj.pathnm));
            end

            cd(obj.pathnm);
            currdir = obj.pathnm;
            
            % Init output parameters
            % Get .nirs file names from current directory. If there are none
            % check sub-directories.
            obj.findDataSet('nirs');
            
            files0 = obj.files;
            
            % First get errors for .nirs files as individual files
            obj.getFileErrors();
                        
            % Now check the .nirs files data set as a whole. That is make
            % sure they all belong to the same group. This means only that the
            % SD geometries are compatible.
            obj.checkFormatAcrossFiles();
            if ~obj.loadData
                obj.files = mydir('');
                obj.filesErr = files0;
                if isempty( obj.files )
                    fprintf('No loadable .nirs files found. Choose another directory\n');
                    
                    % This pause is a workaround for a matlab bug in version
                    % 7.xx for Linux, where uigetfile/uigetdir won't block unless there's
                    % a breakpoint.
                    pause(.5);
                    obj.pathnm = uigetdir(currdir,'No loadable .nirs files found. Choose another directory' );
                    if obj.pathnm~=0
                        obj.GetDataSet();
                    end
                end
            end
            
            %%% Display loaded and error files in GUI
%             obj.Display();
            
        end
        
        
        
        % -----------------------------------------------------------------------------------
        function initErrFlags(obj, n)
            
            flag = struct(...
                'FileCorrupt',0, ...
                'SD',0, ...
                'SD_Lambda',0, ...
                'SD_SrcPos',0, ...
                'SD_nSrcs',0, ...
                'SD_DetPos',0, ...
                'SD_nDets',0, ...
                'SD_MeasList',0, ...
                'SD_auxChannels',0, ...
                'SD_SpatialUnit',0, ...
                'd',0, ...
                't',0, ...
                's',0, ...
                'aux',0, ...
                'ml',0, ...
                'CondNames',0, ...
                'status',0, ...
                'subj',0 ...
                );
            
            obj.flags = repmat(flag,n,1);
            
        end
        
        
        % -----------------------------------------------------------------------------------
        function getFileErrors(obj)
            
            %
            % Function to check errors in a .nirs files set and
            % output the files that pass the .nirs error check and those that
            % don't.
            %
            
            nFiles = length(obj.files);            
            obj.checkFormat();
            
            count=1;
            for iF=1:nFiles
                
                obj.flags(iF).errCount=0;
                obj.flags(iF).warningCount=0;
                errmsg_tmp = [obj.files(iF).name ':  '];
                
                % First is the file a .mat file format
                if obj.flags(iF).FileCorrupt~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    errmsg_tmp = [errmsg_tmp sprintf('%d) Error: file corrupt or not valid .mat file.', obj.flags(iF).errCount)];
                end
                
                % d
                if obj.flags(iF).d~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    errmsg_tmp = [errmsg_tmp sprintf('%d) Error: Invalid data matrix (d). ', obj.flags(iF).errCount)];
                end
                
                % SD
                if obj.flags(iF).SD~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD structure invalid;  ',obj.flags(iF).errCount)];
                end
                if obj.flags(iF).SD_SrcPos~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD has invalid SrcPos;  ',obj.flags(iF).errCount)];
                end
                if obj.flags(iF).SD_DetPos~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD has invalid DetPos;  ',obj.flags(iF).errCount)];
                end
                if obj.flags(iF).SD_MeasList~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    if bitand(obj.flags(iF).SD_MeasList,1)
                        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD Measlist is invalid or doesn''t exist;  ',obj.flags(iF).errCount)];
                    elseif bitand(obj.flags(iF).SD_MeasList,2)
                        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD MeasList differs in size with MeasListAct;  ',obj.flags(iF).errCount)];
                    elseif bitand(obj.flags(iF).SD_MeasList,4)
                        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD MeasList differs in size with MeasListVis;  ',obj.flags(iF).errCount)];
                    end
                end
                if obj.flags(iF).SD_Lambda~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD has invalid Lambda;  ',obj.flags(iF).errCount)];
                end
                if obj.flags(iF).SD_SpatialUnit~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD has invalid SpatialUnit;  ',obj.flags(iF).errCount)];
                end
                if obj.flags(iF).SD_auxChannels~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    if bitand(obj.flags(iF).SD_auxChannels,1)
                        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: SD auxChannels must be an array of string names;  ',obj.flags(iF).errCount)];
                    end
                end
                
                % t
                if obj.flags(iF).t~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    errmsg_tmp = [errmsg_tmp sprintf('%d) Error: invalid time vector (t);  ',obj.flags(iF).errCount)];
                end
                
                % s
                if obj.flags(iF).s~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    errmsg_tmp = [errmsg_tmp sprintf('%d) Error: invalid stim matrix (s);  ',obj.flags(iF).errCount)];
                end
                
                % aux
                if obj.flags(iF).aux~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    if bitand(obj.flags(iF).aux,1)
                        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: auxiliary matrix (aux) is missing;  ',obj.flags(iF).errCount)];
                    elseif bitand(obj.flags(iF).aux,2)
                        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: auxiliary matrix (aux) has an obsolete name (aux10);  ',obj.flags(iF).errCount)];
                    else
                        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: invalid auxiliary matrix (aux);  ',obj.flags(iF).errCount)];
                    end
                end
                                
                % CondNames
                if obj.flags(iF).CondNames~=0
                    obj.flags(iF).errCount = obj.flags(iF).errCount+1;
                    if bitand(obj.flags(iF).CondNames,1)
                        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: CondNames has unassigned conditions;  ', ...
                            obj.flags(iF).errCount+obj.flags(iF).warningCount)];
                    elseif bitand(obj.flags(iF).CondNames,2)
                        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: CondNames has duplicate conditions names;  ', ...
                            obj.flags(iF).errCount+obj.flags(iF).warningCount)];
                    elseif bitand(obj.flags(iF).CondNames,4)
                        errmsg_tmp = [errmsg_tmp sprintf('%d) Error: length(CondNames) ~= Columns in s;  ', ...
                            obj.flags(iF).errCount+obj.flags(iF).warningCount)];
                    end
                end
                
                
                %%% Tally up the errors and error count.
                if obj.flags(iF).errCount==0 && obj.flags(iF).warningCount==0
                    continue;
                end
                obj.flags(iF).subj = 1;
                if obj.flags(iF).errCount>0 && obj.files(iF).subjdiridx
                    obj.flags(obj.files(iF).subjdiridx).errCount=1;
                end
                if obj.flags(iF).warningCount>0 && obj.files(iF).subjdiridx
                    obj.flags(obj.files(iF).subjdiridx).warningCount=1;
                end
                obj.errmsg{count} = errmsg_tmp;
                count=count+1;
                
            end
            
            obj.dispErrmsgs();
            
        end
   
    
        % -----------------------------------------------------------------------------------
        function checkFormat(obj)
        
            warning('off','MATLAB:load:variableNotFound');
            
            nFiles = length(obj.files);
            obj.initErrFlags(nFiles);
                        
            % NIRS data set format
            hwait = waitbar(0,sprintf('Checking .nirs format for individual files') );
            for iF=1:nFiles
                
                waitbar(iF/nFiles,hwait,sprintf('Checking file %d of %d',iF,nFiles));
                if obj.files(iF).isdir
                    continue;
                end
                
                %%%% Before checking the .nirs format make sure first that it's a .mat
                %%%% format. If not we have nothing to work with.
                try
                    load( obj.files(iF).name, '-mat', 'd','t','SD','s','aux','CondNames');
                catch
                    obj.flags(iF).FileCorrupt = 1;
                    continue;
                end
                
                %%%% t
                if ~exist('t','var')
                    obj.flags(iF).t = bitor(obj.flags(iF).t,1);
                else
                    if ~isnumeric(t)
                        obj.flags(iF).t = bitor(obj.flags(iF).t,2);
                    end
                    if ~isvector(t)
                        obj.flags(iF).t = bitor(obj.flags(iF).t,4);
                    end
                end
                
                
                %%%% d
                if ~exist('d','var')
                    obj.flags(iF).d = bitor(obj.flags(iF).d,1);
                else
                    if ~isnumeric(d)
                        obj.flags(iF).d = bitor(obj.flags(iF).d,2);
                    end
                    if size(d,1)~=length(t)
                        obj.flags(iF).d = bitor(obj.flags(iF).d,4);
                    end
                    if exist('SD','var') && isproperty(SD,'MeasList')
                        if size(d,2)~=size(SD.MeasList,1)
                            obj.flags(iF).d = bitor(obj.flags(iF).d,8);
                        end
                    end
                end
                
                
                %%%% SD
                if ~exist('SD','var') || isempty(SD)
                    obj.flags(iF).SD = bitor(obj.flags(iF).SD,1);
                end
                if ~isproperty(SD,'Lambda') || isempty(SD.Lambda)
                    obj.flags(iF).SD_Lambda = bitor(obj.flags(iF).SD_Lambda,1);
                end
                if ~isproperty(SD,'SrcPos') || isempty(SD.SrcPos)
                    obj.flags(iF).SD_SrcPos = bitor(obj.flags(iF).SD_SrcPos,1);
                end
                if ~isproperty(SD,'nSrcs')
                    obj.flags(iF).SD_nSrcs = bitor(obj.flags(iF).SD_nSrcs,1);
                end
                if ~isproperty(SD,'DetPos') || isempty(SD.DetPos)
                    obj.flags(iF).SD_DetPos = bitor(obj.flags(iF).SD_DetPos,1);
                end
                if ~isproperty(SD,'nDets')
                    obj.flags(iF).SD_nDets = bitor(obj.flags(iF).SD_nDets,1);
                end
                if ~isproperty(SD,'MeasList') || isempty(SD.MeasList)
                    obj.flags(iF).SD_MeasList = bitor(obj.flags(iF).SD_MeasList,1);
                end
                if isproperty(SD,'MeasList') && isproperty(SD,'MeasListAct')
                    if size(SD.MeasList,1) ~= size(SD.MeasListAct,1)
                        obj.flags(iF).SD_MeasList = bitor(obj.flags(iF).SD_MeasList,2);
                    end
                end
                if isproperty(SD,'MeasList') && isproperty(SD,'MeasListVis')
                    if size(SD.MeasList,1) ~= size(SD.MeasListVis,1)
                        obj.flags(iF).SD_MeasList = bitor(obj.flags(iF).SD_MeasList,4);
                    end
                end
                if ~isproperty(SD,'SpatialUnit')
                    obj.flags(iF).SD_SpatialUnit = bitor(obj.flags(iF).SD_SpatialUnit,1);
                end
                if isproperty(SD,'auxChannels')
                    if ~isempty(SD.auxChannels)
                        if ~exist('aux')
                            load( obj.files(iF).name, '-mat','aux10');
                            if exist('aux10','var')
                                aux = aux10;
                            end
                        end
                        if ~iscell(SD.auxChannels)
                            obj.flags(iF).SD_auxChannels = bitor(obj.flags(iF).SD_auxChannels,1);
                        end
                    end
                end
                
                
                %%%%% s
                if ~exist('s')
                    obj.flags(iF).s = bitor(obj.flags(iF).s,1);
                else
                    if ~isnumeric(s)
                        obj.flags(iF).s = bitor(obj.flags(iF).s,2);
                    end
                    if size(s,1)~=length(t)
                        obj.flags(iF).s = bitor(obj.flags(iF).s,4);
                    end
                    for jj=1:size(s,2)
                        if ~isempty(find(~ismember(s(:,jj),-2:2),1))
                            obj.flags(iF).s = bitor(obj.flags(iF).s,8);
                            break;
                        end
                    end
                    if isempty(s)
                        obj.flags(iF).s = bitor(obj.flags(iF).s,16);
                    end
                end
                
                
                %%%%% aux
                if ~exist('aux')
                    load( obj.files(iF).name, '-mat','aux10');
                    if exist('aux10','var')
                        obj.flags(iF).aux = bitor(obj.flags(iF).aux,2);
                    else
                        obj.flags(iF).aux = bitor(obj.flags(iF).aux,1);
                    end
                else
                    if ~isnumeric(aux)
                        obj.flags(iF).aux = bitor(obj.flags(iF).aux,4);
                    end
                    if size(aux,1)~=length(t)
                        obj.flags(iF).aux = bitor(obj.flags(iF).aux,8);
                    end
                    if isempty(aux)
                        obj.flags(iF).aux = bitor(obj.flags(iF).aux,16);
                    end
                end
                
                %%%%% CondNames
                if exist('CondNames','var')
                    if ~isempty(find(strcmp('',CondNames)))
                        obj.flags(iF).CondNames = bitor(obj.flags(iF).CondNames,1);
                    end
                    for ii=1:length(CondNames)
                        k=find(strcmp(CondNames{ii},CondNames));
                        if length(k)>1
                            obj.flags(iF).CondNames = bitor(obj.flags(iF).CondNames,2);
                        end
                    end
                    if exist('s')
                        if length(CondNames)~=size(s,2)
                            obj.flags(iF).CondNames = bitor(obj.flags(iF).CondNames,4);
                        end
                    end
                end
                
                clear('d','t','SD','s','aux','CondNames');
                
            end
            close(hwait);
            
            warning('on','MATLAB:load:variableNotFound');            
            
        end  
        
        
        % -----------------------------------------------------------------------------------
        function fixOrUpgrade(obj)
            
            warning('off','MATLAB:load:variableNotFound');
            
            nFiles = length(obj.files);
            ch_all = zeros(length(obj.files));
            yestoallflag = 0;
            informUserFilesCopiedFlag = 0;
            spatialUnits = 0;
            for iF=1:nFiles
                
                if obj.flags(iF).errCount>0  &&  obj.flags(iF).FileCorrupt==0 &&  ~obj.files(iF).isdir
                    
                    if yestoallflag==1
                        ch=2;
                    else
                        if obj.flags(iF).errCount>0
                            ch = menu(sprintf('Error in %s files.\nDo you want to try to fix it?',obj.files(iF).name), ...
                                'Yes','Yes to All','No','No to All');
                        elseif obj.flags(iF).warningCount>0
                            ch = menu(sprintf('Obsolete format in %s files.\nDo you want to try to upgrade to current format?',obj.files(iF).name), ...
                                'Yes','Yes to All','No','No to All');
                        end
                    end
                    ch_all(iF) = ch;
                    
                    if ch==1 || ch==2
                        
                        % User chose to fix file.
                        savestr = [];
                        
                        % Error handling for d
                        if obj.flags(iF).d~=0
                            load(obj.files(iF).name,'-mat','d');
                            
                            if bitand(obj.flags(iF).d,4)
                                load(obj.files(iF).name,'-mat','t');
                                m = size(d,1);
                                n = length(t);
                                q = n-m;
                                if q>0
                                    d=[d; zeros(q,size(d,2))];
                                elseif q<0
                                    d(m+q+1:m,:)=[];
                                end
                                obj.flags(iF).d = bitxor(obj.flags(iF).d,4);
                            end
                            
                            if obj.flags(iF).d==0
                                obj.flags(iF).errCount = obj.flags(iF).errCount-1;
                                savestr = [savestr, '''d'','];
                            end
                        end
                        
                        
                        % Error handling for s
                        if obj.flags(iF).s~=0
                            load(obj.files(iF).name,'-mat','s');
                            
                            if bitand(obj.flags(iF).s,1)
                                load(obj.files(iF).name,'-mat','t');
                                s = zeros(length(t),1);
                                obj.flags(iF).s = bitxor(obj.flags(iF).s,1);
                            end
                            if bitand(obj.flags(iF).s,4)
                                load(obj.files(iF).name,'-mat','t');
                                m = size(s,1);
                                n = length(t);
                                q = n-m;
                                if q>0
                                    s=[s; zeros(q,size(s,2))];
                                elseif q<0
                                    s(m+q+1:m,:)=[];
                                end
                                obj.flags(iF).s = bitxor(obj.flags(iF).s,4);
                            end
                            if bitand(obj.flags(iF).s,8)
                                for jj=1:size(s,2)
                                    k = find(~ismember(s(:,jj),-2:2));
                                    s(k,jj)=0;
                                end
                                obj.flags(iF).s = bitxor(obj.flags(iF).s,8);
                            end
                            if bitand(obj.flags(iF).s,16)
                                load(obj.files(iF).name,'-mat','t');
                                n = length(t);
                                s = zeros(n,1);
                                obj.flags(iF).s = bitxor(obj.flags(iF).s,16);
                            end
                            
                            if obj.flags(iF).s==0
                                obj.flags(iF).errCount = obj.flags(iF).errCount-1;
                                savestr = [savestr, '''s'','];
                            end
                        end
                        
                        
                        % Error handling for aux
                        if obj.flags(iF).aux~=0
                            load(obj.files(iF).name,'-mat','aux');
                            
                            if bitand(obj.flags(iF).aux,2)
                                load(obj.files(iF).name,'-mat','aux10');
                                aux = aux10;
                                obj.flags(iF).aux = bitxor(obj.flags(iF).aux,2);
                            end
                            if bitand(obj.flags(iF).aux,8)
                                load(obj.files(iF).name,'-mat','t');
                                m = size(aux,1);
                                n = length(t);
                                q = n-m;
                                if q>0
                                    aux=[aux; zeros(q,size(aux,2))];
                                elseif q<0
                                    aux(m+q+1:m,:)=[];
                                end
                                obj.flags(iF).aux = bitxor(obj.flags(iF).aux,8);
                            end
                            if bitand(obj.flags(iF).aux,16)
                                load(obj.files(iF).name,'-mat','t');
                                n = length(t);
                                aux = zeros(n,1);
                                obj.flags(iF).aux = bitxor(obj.flags(iF).aux,16);
                            end
                            
                            if obj.flags(iF).aux==0
                                obj.flags(iF).errCount = obj.flags(iF).errCount-1;
                                savestr = [savestr, '''aux'','];
                            end
                        end
                        
                        
                        % Error handling for SD_Lambda
                        if obj.flags(iF).SD_Lambda~=0
                            load(obj.files(iF).name,'-mat','SD');
                            
                            if bitand(obj.flags(iF).SD_Lambda,1)
                                q = menu('Wavelengths missing from file. Do you want to enter it here?','YES','Cancel');
                                if q==1
                                    name = 'Enter missing wavelengths:';
                                    vals = inputdlg({'wavelength 1','wavelength 2'}, name, [1, length(name)+22]);
                                    if length(vals)==2
                                        SD.Lambda = [str2num(vals{1}), str2num(vals{2})];
                                        obj.flags(iF).SD_Lambda = bitxor(obj.flags(iF).SD_Lambda,1);
                                    end
                                end
                            end
                            
                            if obj.flags(iF).SD_Lambda==0
                                obj.flags(iF).errCount = obj.flags(iF).errCount-1;
                                savestr = [savestr, '''SD'','];
                            end
                        end
                        
                        
                        % Error handling for SD_MeasList
                        if obj.flags(iF).SD_MeasList~=0
                            load(obj.files(iF).name,'-mat','SD');
                            
                            if bitand(obj.flags(iF).SD_MeasList,2)
                                m=size(SD.MeasList,1);
                                n=size(SD.MeasListAct,1);
                                d = m-n;
                                if d>0
                                    SD.MeasListAct = [SD.MeasListAct; ones(d,1)];
                                elseif d<0
                                    SD.MeasListAct(m+d+1:m) = [];
                                end
                                obj.flags(iF).SD_MeasList = bitxor(obj.flags(iF).SD_MeasList,2);
                            end
                            
                            if bitand(obj.flags(iF).SD_MeasList,4)
                                m=size(SD.MeasList,1);
                                n=size(SD.MeasListVis,1);
                                d = m-n;
                                if d>0
                                    SD.MeasListVis = [SD.MeasListVis; ones(d,1)];
                                elseif d<0
                                    SD.MeasListVis(m+d+1:m) = [];
                                end
                                obj.flags(iF).SD_MeasList = bitxor(obj.flags(iF).SD_MeasList,4);
                            end
                            
                            if obj.flags(iF).SD_MeasList==0
                                obj.flags(iF).errCount = obj.flags(iF).errCount-1;
                                savestr = [savestr, '''SD'','];
                            end
                        end
                        
                        
                        % Error handling for SD_SpatialUnit
                        if obj.flags(iF).SD_SpatialUnit~=0
                            load(obj.files(iF).name,'-mat','SD');
                            
                            if bitand(obj.flags(iF).SD_SpatialUnit,1)
                                obj.flags(iF).SD_SpatialUnit = bitxor(obj.flags(iF).SD_SpatialUnit,1);
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
                                    if isproperty(SD,'SpringList')
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
                                if obj.flags(iF).SD_SpatialUnit==0
                                    obj.flags(iF).errCount = obj.flags(iF).errCount-1;
                                    savestr = [savestr, '''SD'','];
                                end
                            end
                        end
                        
                        
                        % Error handling for SD_auxChannels
                        if obj.flags(iF).SD_auxChannels~=0
                            load(obj.files(iF).name,'-mat','SD','aux','aux10');
                            if ~exist('aux','var')
                                if ~exist('aux10','var')
                                    aux = zeros(n,1);
                                else
                                    aux = aux10;
                                end
                            end
                            
                            if bitand(obj.flags(iF).SD_auxChannels,1)
                                SD.auxChannels = {};
                                m=length(SD.auxChannels);
                                for ii=1:size(aux,2)
                                    SD.auxChannels{ii} = ['Aux, ',num2str(ii)];
                                end
                            end
                            
                            if obj.flags(iF).SD_MeasList==0
                                obj.flags(iF).errCount = obj.flags(iF).errCount-1;
                                savestr = [savestr, '''SD'','];
                            end
                        end
                        
                        
                        % Error handling for procInput
                        if obj.flags(iF).procInput_SD~=0
                            load(obj.files(iF).name,'-mat','procInput','SD');
                            
                            if exist('SD','var')
                                procInput.SD = SD;
                                obj.flags(iF).procInput_SD = bitxor(obj.flags(iF).procInput_SD,1);
                                obj.flags(iF).errCount = obj.flags(iF).errCount-1;
                            end
                            
                            if obj.flags(iF).procInput_SD==0
                                obj.flags(iF).errCount = obj.flags(iF).errCount-1;
                                savestr = [savestr, '''procInput'','];
                            end
                        end
                        
                        
                        % Error handling for CondNames
                        if obj.flags(iF).CondNames~=0
                            load(obj.files(iF).name,'-mat','CondNames','s');
                            
                            if bitand(obj.flags(iF).CondNames,1)
                                CondNames = stimCondInit(s,CondNames);
                                obj.flags(iF).CondNames = bitxor(obj.flags(iF).CondNames,1);
                            end
                            if bitand(obj.flags(iF).CondNames,2)
                                CondNames = stimCondInit(s,CondNames);
                                obj.flags(iF).CondNames = bitxor(obj.flags(iF).CondNames,2);
                            end
                            if bitand(obj.flags(iF).CondNames,4)
                                if length(CondNames)<size(s,2)
                                    for ii=length(CondNames)+1:size(s,2)
                                        jj=ii;
                                        while ~isempty(find(strcmp(CondNames, num2str(jj))))
                                            jj=jj+10;
                                        end
                                        CondNames{ii} = num2str(jj);
                                    end
                                else
                                    for ii=1:size(s,2)
                                        boo{ii} = CondNames{ii};
                                    end
                                    CondNames = boo;
                                end
                                obj.flags(iF).CondNames = bitxor(obj.flags(iF).CondNames,4);
                            end
                            
                            if obj.flags(iF).CondNames==0
                                obj.flags(iF).errCount = obj.flags(iF).errCount-1;
                                savestr = [savestr, '''CondNames'','];
                            end
                        end
                        
                        
                        % Add more NIRS variable fixes here
                        
                        
                        % Now save fixed parameters to nirs files only if all errors
                        % were fixed. Otherwise tell user can't fix it and do nothing.
                        if obj.flags(iF).errCount==0
                            
                            hwait = waitbar(0,sprintf('Saving fixed %s file. This may take a few seconds...', obj.files(iF).name));
                            if ~exist([obj.files(iF).name '.orig'],'file')
                                copyfile(obj.files(iF).name,[obj.files(iF).name '.orig']);
                            end
                            eval( sprintf('save( obj.files(iF).name, %s, ''-mat'',''-append'' );', savestr(1:end-1)) );
                            informUserFilesCopiedFlag = informUserFilesCopiedFlag+1;
                            close(hwait);
                            
                            % files(iF).subjdiridx is only relevant if we have separate subject
                            % directories. Otherwise files(iF).subjdiridx is zero and
                            % we ignore it.
                            if obj.files(iF).subjdiridx
                                obj.flags(files(iF).subjdiridx).errCount=0;
                            end
                            
                        else
                            menu(sprintf('Can''t fix file %s. Skipping...', obj.files(iF).name), 'OK');
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
                     
        end
        
        
        
        % -----------------------------------------------------------------------------------
        function checkFormatAcrossFiles(obj)
            
            nFiles = length(obj.files);
            uniqueSD = zeros(1,nFiles);
            
            if isempty(obj.files)
                return;
            end
                       
            sd_common = {};
            
            hwait = waitbar(0,sprintf('Checking .nirs format consistency across files: processing 1 of %d', nFiles) );
            for iF=1:nFiles
                
                waitbar(iF/nFiles,hwait,sprintf('Checking .nirs format consistency across files: processing %d of %d', iF, nFiles));
                if obj.files(iF).isdir
                    continue;
                end
                load( obj.files(iF).name, '-mat','SD' );
                
                % Easy fix if nSrcs or nDets aren't there
                if ~isproperty(SD,'nSrcs')
                    SD.nSrcs = size(SD.SrcPos,1);
                end
                if ~isproperty(SD,'nDets')
                    SD.nDets = size(SD.DetPos,1);
                end
                
                if isempty(sd_common)
                    sd_common{1} = SD;
                    nSD = 1;
                    uniqueSD(iF) = 1;
                end
                
                
                % Compare SD geometries
                flag = [];
                for iSD = 1:nSD
                    flag(iSD) = 0;
                    if ~isequal(SD.Lambda, sd_common{iSD}.Lambda)
                        flag(iSD) = 1;
                    end
                    if ~isequal(SD.SrcPos, sd_common{iSD}.SrcPos)
                        flag(iSD) = 1;
                    end
                    if ~isequal(SD.DetPos, sd_common{iSD}.DetPos)
                        flag(iSD) = 1;
                    end
                    if ~isequal(SD.MeasList, sd_common{iSD}.MeasList)
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
                    sd_common{nSD} = SD;
                    uniqueSD(iF) = nSD;
                end
                
            end
            close(hwait);
            
            % Report results
            obj.reportGroupErrors();
            
        end        
        
    end
    
end