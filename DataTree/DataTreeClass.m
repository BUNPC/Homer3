classdef DataTreeClass <  handle
    
    properties
        files
        filesErr
        group
        currElem
        reg
    end
    
    methods
        
        % ---------------------------------------------------------------
        function obj = DataTreeClass(fmt, cfgfilename)
            if ~exist('fmt','var')
                fmt = '';
            end
            if ~exist('cfgfilename','var')
                cfgfilename = '';
            end
            
            % Get file names
            dataInit = FindFiles(fmt);
            if isempty(dataInit) || dataInit.isempty()
                return;
            end
            obj.files    = dataInit.files;
            obj.filesErr = dataInit.filesErr;
            obj.reg = RegistriesClass();
            obj.LoadData(cfgfilename);
            
            % Initialize the current processing element within the group
            obj.SetCurrElem(1,1,1);
        end
        
        
        % --------------------------------------------------------------
        function delete(obj)
            if isempty(obj.currElem)
                return;
            end
        end


        % ---------------------------------------------------------------
        function LoadData(obj, cfgfilename)
            if ~exist('cfgfilename','var')
                cfgfilename = '';
            end
            
            obj.AcqData2Group();
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Load derived or post-acquisition data from a file if it 
            % exists
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.group.Load();
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Initialize procStream.input for all tree nodes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.group.InitProcInput(obj.reg, cfgfilename);
                        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Copy input variables for group, subjects and runs
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.group.SetConditions();
            obj.group.SetMeasList();
        end
        
        
        % ----------------------------------------------------------
        function AcqData2Group(obj)
            obj.group = GroupClass().empty();
            
            if isempty(obj.files)
                return;
            end
            
            % Create new group based only on acquisition data
            rnum = 1;
            obj.group = GroupClass(obj.files(1).name);
            obj.files(1).MapFile2Group(1,1,1);
            hwait = waitbar(0, sprintf('Loading proc elements') );
            p = get(hwait,'position');
            set(hwait, 'Position',[p(1), p(2), p(3)*1.5, p(4)]);
            for ii=2:length(obj.files)
                
                waitbar(ii/length(obj.files), hwait, sprintf('Loading %s: %d of %d', ...
                    sprintf_s(obj.files(ii).name), ii, length(obj.files)) );
                
                fname = obj.files(ii).name;
                if obj.files(ii).isdir
                    jj = length(obj.group.subjs)+1;
                    obj.group.subjs(jj) = SubjClass(fname, jj, 0, rnum);
                    obj.files(ii).MapFile2Group(1,jj,rnum);
                else
                    [sname, rnum_tmp, iExt] = getSubjNameAndRun(fname, rnum);
                    if rnum_tmp ~= rnum
                        rnum = rnum_tmp;
                    end
                    
                    jj=1;
                    while jj<=length(obj.group.subjs)
                        if(strcmp(sname, obj.group.subjs(jj).name))
                            nRuns = length(obj.group.subjs(jj).runs);
                            
                            % If this run already exists under this subject, the user probably
                            % made a mistake in naming the file (e.g., having two files named
                            % <subjname>_run01.nirs and <subjname>_run01_<descriptor>.nirs)
                            % We handle it anyways by continuing through all existing subjects
                            % until we are forced to create a new subject with one run.
                            flag=0;
                            for kk=1:nRuns
                                if rnum == obj.group.subjs(jj).runs(kk).rnum
                                    sname = fname(1:iExt-1);
                                    jj=jj+1;
                                    flag = 1;
                                    break;
                                end
                            end
                            if flag==1
                                flag = 0;
                                continue
                            end
                            
                            % Create new run in existing subject
                            obj.group.subjs(jj).runs(nRuns+1) = RunClass(fname, jj, nRuns+1, rnum);
                            obj.group.nFiles = obj.group.nFiles+1;
                            obj.files(ii).MapFile2Group(1,jj,nRuns+1);
                            rnum=rnum+1;
                            break;
                        end
                        jj=jj+1;
                    end
                    
                    % Create new subject with one run
                    if(jj>length(obj.group.subjs))
                        obj.group.subjs(jj) = SubjClass(fname, jj, 1, rnum);
                        obj.group.nFiles = obj.group.nFiles+1;
                        obj.files(ii).MapFile2Group(1,jj,1);
                        rnum=rnum+1;
                    end
                end
            end
            close(hwait);
        end


       
        % ----------------------------------------------------------
        function SetCurrElem(obj, iGroup, iSubj, iRun)
            if nargin==1
                iGroup = 0;
                iSubj = 0;
                iRun  = 0;
            elseif nargin==2
                iSubj = 0;
                iRun  = 0;
            elseif nargin==3
                iRun  = 0;
            end
            
            if iSubj==0 && iRun==0
                obj.currElem = obj.group(iGroup);
            elseif iSubj>0 && iRun==0
                obj.currElem = obj.group(iGroup).subjs(iSubj);
            elseif iSubj>0 && iRun>0
                obj.currElem = obj.group(iGroup).subjs(iSubj).runs(iRun);
            end
        end


        % ----------------------------------------------------------
        function procElem = GetCurrElem(obj)
            procElem = obj.currElem;
        end


        % ----------------------------------------------------------
        function [iGroup, iSubj, iRun] = GetCurrElemIdx(obj)
            iGroup = obj.currElem.iGroup;
            iSubj = obj.currElem.iSubj;
            iRun = obj.currElem.iRun;
        end


        % ----------------------------------------------------------
        function SaveCurrElem(obj)
            obj.currElem.Save();
        end


        % ----------------------------------------------------------
        function CalcCurrElem(obj)
            obj.currElem.Calc();
        end

        
        % ----------------------------------------------------------
        function iFile = MapGroup2File(obj, iGroup, iSubj, iRun)
            iFile = 0;
            for ii=1:length(obj.files)
                if obj.files(ii).map2group.iGroup==iGroup && ...
                   obj.files(ii).map2group.iSubj==iSubj && ...
                   obj.files(ii).map2group.iRun==iRun
                    iFile = ii;
                    break;
                end
            end 
        end

        
        % ----------------------------------------------------------
        function [iGroup, iSubj, iRun] = MapFile2Group(obj, iFile)
            iGroup = obj.files(iFile).map2group.iGroup;
            iSubj = obj.files(iFile).map2group.iSubj;
            iRun = obj.files(iFile).map2group.iRun;
        end


        % ----------------------------------------------------------
        function b = IsEmpty(obj)
            b = true;
            if isempty(obj)
                return
            end
            if isempty(obj.files)
                return;
            end
            if isempty(obj.group)
                return;
            end
            if isempty(obj.currElem)
                return;
            end
            b = false;
        end

    end
    
end