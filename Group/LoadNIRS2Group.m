function [group, files] = LoadNIRS2Group(files)

group = GroupClass().empty();

if ~exist('files','var') || isempty(files)
    return;
end

% Create new group based only on the .nirs files

rnum = 1;
groupCurr = GroupClass(files(1).name);
files(1) = MapFile2Group(files(1),1,1);ls
for ii=2:length(files)
    
    fname = files(ii).name;
    if files(ii).isdir
        
        jj = length(groupCurr.subjs)+1;
        groupCurr.subjs(jj) = SubjClass(fname, jj, 0, rnum);
        files(ii) = MapFile2Group(files(ii),jj,rnum);

    else
        
        [sname, rnum_tmp, iExt] = getSubjNameAndRun(fname, rnum);
        if rnum_tmp ~= rnum
            rnum = rnum_tmp;
        end

        jj=1;
        while jj<=length(groupCurr.subjs)
            if(strcmp(sname, groupCurr.subjs(jj).name))
                nRuns = length(groupCurr.subjs(jj).runs);
                
                % If this run already exists under this subject, the user probably 
                % made a mistake in naming the file (e.g., having two files named
                % <subjname>_run01.nirs and <subjname>_run01_<descriptor>.nirs)
                % We handle it anyways by continuing through all existing subjects 
                % until we are forced to create a new subject with one run.
                flag=0;
                for kk=1:nRuns
                    if rnum == groupCurr.subjs(jj).runs(kk).rnum
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
                groupCurr.subjs(jj).runs(nRuns+1) = RunClass(fname, jj, nRuns+1, rnum);
                groupCurr.nFiles = groupCurr.nFiles+1;
                        files(ii) = MapFile2Group(files(ii), jj, nRuns+1);

                rnum=rnum+1;
                break;
            end
            jj=jj+1;
        end

        % Create new subject with one run
        if(jj>length(groupCurr.subjs))

            groupCurr.subjs(jj) = SubjClass(fname, jj, 1, rnum);
            groupCurr.nFiles = groupCurr.nFiles+1;
            files(ii) = MapFile2Group(files(ii), jj, 1);

            rnum=rnum+1;

        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load group results from a file if it exists 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groupCurr.LoadGroupFile();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find out if we need to ask user for prcessing options config file
% to initialize procInput.procFunc at the run, subject or group level.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subj = groupCurr.subjs(1);
run = groupCurr.subjs(1).runs(1);

for jj=1:length(groupCurr.subjs)
    if ~procStreamIsEmpty(groupCurr.subjs(jj).procInput)
        subj = groupCurr.subjs(jj);
    end 
    for kk=1:length(groupCurr.subjs(jj).runs)
        if ~procStreamIsEmpty(groupCurr.subjs(jj).runs(kk).procInput)
            run = groupCurr.subjs(jj).runs(kk);
        end
    end
end

% Find the procInput defaults at each level with which to initialize 
% uninitialized procInput
[procInputGroupDefault, procfilenm] = groupCurr.GetProcInputDefault();
[procInputSubjDefault, procfilenm] = subj.GetProcInputDefault(procfilenm);
[procInputRunDefault, procfilenm] = run.GetProcInputDefault(procfilenm);

% Copy default procInput to all uninitialized nodes in the group
groupCurr.CopyProcInput('group', procInputGroupDefault);
groupCurr.CopyProcInput('subj', procInputSubjDefault);
groupCurr.CopyProcInput('run', procInputRunDefault);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy SD to subject and group procInput 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groupCurr.CopySD();


group = groupCurr;



