function [group, files] = LoadNIRS2Group(files)

group = [];

if isempty(files)
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create new group based only on the .nirs files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rnum = 1;
groupCurr = createGroup(files(1).name);
files(1) = MapFile2Group(files(1),1,1);
for ii=2:length(files)
    
    fname = files(ii).name;
    if files(ii).isdir
        
        jj = length(groupCurr(1).subjs)+1;
        groupCurr(1).subjs(jj) = createSubj(fname, jj, 0, rnum);
        files(ii) = MapFile2Group(files(ii),jj,rnum);

    else
        
        [sname, rnum_tmp, iExt] = getSubjNameAndRun(fname, rnum);
        if rnum_tmp ~= rnum
            rnum = rnum_tmp;
        end

        jj=1;
        while jj<=length(groupCurr(1).subjs)
            if(strcmp(sname, groupCurr(1).subjs(jj).name))
                nRuns = length(groupCurr(1).subjs(jj).runs);
                
                % If this run already exists under this subject, the user probably 
                % made a mistake in naming the file (e.g., having two files named
                % <subjname>_run01.nirs and <subjname>_run01_<descriptor>.nirs)
                % We handle it anyways by continuing through all existing subjects 
                % until we are forced to create a new subject with one run.
                flag=0;
                for kk=1:nRuns
                    if rnum == groupCurr(1).subjs(jj).runs(kk).rnum
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
                groupCurr(1).subjs(jj).runs(nRuns+1) = createRun(fname, jj, nRuns+1, rnum);
                groupCurr(1).nFiles = groupCurr(1).nFiles+1;
                        files(ii) = MapFile2Group(files(ii), jj, nRuns+1);

                rnum=rnum+1;
                break;
            end
            jj=jj+1;
        end

        % Create new subject with one run
        if(jj>length(groupCurr(1).subjs))

            groupCurr(1).subjs(jj) = createSubj(fname, jj, 1, rnum);
            groupCurr(1).nFiles = groupCurr(1).nFiles+1;
            files(ii) = MapFile2Group(files(ii), jj, 1);

            rnum=rnum+1;

        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load group results if they exist and compare with the 
% current group of files represented by groupCurr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('./groupResults.mat','file')

    load( './groupResults.mat' );
    groupPrev = group;
    
    % copy procResult from previous group to current group for 
    % all nodes that still exist in the current group.
    hwait = waitbar(0,'Loading group');
    groupCurr = copyProcParams(groupCurr, groupPrev, 'group', hwait, length(files));
    close(hwait);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find out if we need to ask user for prcessing options config file
% to initialize procInput.procFunc at the run, subject or group level.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subj = groupCurr(1).subjs(1);
run = groupCurr(1).subjs(1).runs(1);

for jj=1:length(groupCurr(1).subjs)
    if ~procStreamIsEmpty(groupCurr(1).subjs(jj).procInput)
        subj = groupCurr(1).subjs(jj);
    end 
    for kk=1:length(groupCurr(1).subjs(jj).runs)
        if ~procStreamIsEmpty(groupCurr(1).subjs(jj).runs(kk).procInput)
            run = groupCurr(1).subjs(jj).runs(kk);
        end
    end
end

% Find the procInput defaults at each level with which to initialize 
% uninitialized procInput
[procInputGroupDefault, procfilenm] = GetProcInputDefaultGroup(groupCurr);
[procInputSubjDefault, procfilenm] = GetProcInputDefaultSubj(subj, procfilenm);
[procInputRunDefault, procfilenm] = GetProcInputDefaultRun(run, procfilenm);


% Copy default procInput to all uninitialized nodes in the group
if procStreamIsEmpty(groupCurr(1).procInput)
    groupCurr(1).procInput = procStreamCopy2Native(procInputGroupDefault);
end
for jj=1:length(groupCurr(1).subjs)
    if procStreamIsEmpty(groupCurr(1).subjs(jj).procInput)
        groupCurr(1).subjs(jj).procInput = procStreamCopy2Native(procInputSubjDefault);
    end 
    for kk=1:length(groupCurr(1).subjs(jj).runs)
        
        % Backwards compatibility code between homer3 and homer2 formats: use 
        % procStreamCopy to make sure that a homer2 generated .nirs file is
        % converted to homer3 procInput format
        groupCurr(1).subjs(jj).runs(kk).procInput = ...
            procStreamCopy2Native(groupCurr(1).subjs(jj).runs(kk).procInput);
        
        if procStreamIsEmpty(groupCurr(1).subjs(jj).runs(kk).procInput)
            groupCurr(1).subjs(jj).runs(kk).procInput = procStreamCopy2Native(procInputRunDefault);
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy SD to subject and group procInput 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for jj=1:length(groupCurr(1).subjs)
    if isempty(groupCurr(1).subjs(jj).SD)
        groupCurr(1).subjs(jj).SD = SetSDSubj(groupCurr(1).subjs(jj).runs(1).SD);
    end
end
if isempty(groupCurr(1).SD)
    groupCurr(1).SD = SetSDGroup(groupCurr(1).subjs(1).SD);
end


group = groupCurr;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract the subject name and run number from a .nirs 
% filename.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sname rnum k2] = getSubjNameAndRun(fname,rnum)

k1=findstr(fname,'/');
k2=findstr(fname,'.nirs');
if ~isempty(k1)
    sname = fname(1:k1-1);
else
    k1=findstr(fname,'_run');

    % Check if there's subject and run info in the filename 
    if(~isempty(k1))
        sname = fname(1:k1-1);
        rnum = [fname(k1(1)+4:k2(1)-1)];
        k3 = findstr(rnum,'_');
        if ~isempty(k3)
            if ~isempty(rnum)
                rnum = rnum(1:k3-1);
            end
        end
        if isempty(rnum) | ~isnumber(rnum)
            rnum = 1;
        else
            rnum = str2num(rnum);
        end
    else
        sname = fname(1:k2-1);
        rnum = 1;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy processing params (procInut and procResult) from 
% N2 to N1 if N1 and N2 are same nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function N1 = copyProcParams(N1,N2,type,hwait,ntot)

switch lower(type)

case {'group','grp'}

    if strcmp(N1.name,N2.name)
        for i=1:length(N1.subjs)
            j=existSubj(N1.subjs(i),N2);
            if (j>0)
                N1.subjs(i) = copyProcParams(N1.subjs(i),N2.subjs(j),'subj',hwait,ntot);
            end
        end
        if groupsSame(N1,N2)
            N1 = copyProcParamsFieldByField(N1,N2,'group');
        else
            N1.procInput.changeFlag=1;
        end
    end

case {'subj','subject'}

    if strcmp(N1.name,N2.name)
        % No need to copy run data from previous N2's runs to N1.
        % All run data was loaded from .nirs file when the current 
        % group was initialized.
        if subjsSame(N1,N2)
            N1 = copyProcParamsFieldByField(N1,N2,'subj');
        else
            N1.procInput.changeFlag=1;
        end
    end

case {'run'}

    hwait = waitbar( N1.fileidx/ntot, hwait, ...
                     sprintf('Loading file %s, %d of %d',N1.name,N1.fileidx,ntot) );
    if strcmp(N1.name,N2.name)
        N1 = copyProcParamsFieldByField(N1,N2,'run');
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy processing params (procInut and procResult) from 
% N2 to N1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function N1 = copyProcParamsFieldByField(N1,N2,type)

switch lower(type)

case {'group','grp'}

    % procInput
    if isfield(N2,'procInput') && ~isempty(N2.procInput)
        if isfield(N2.procInput,'procFunc') && ~isempty(N2.procInput.procFunc)
            N1.procInput = copyStructFieldByField(N1.procInput,N2.procInput,'procInput');
        else
            [N1.procInput.procFunc, N1.procInput.procParam] = procStreamDefault(type);
        end
    end
    
    % procResult
    if isfield(N2,'procResult') && ~isempty(N2.procResult)
        N1.procResult = copyStructFieldByField(N1.procResult,N2.procResult);
    end

    % CondNames
    if isfield(N2,'CondNames') && ~isempty(N2.CondNames)
        N1.CondNames = copyStructFieldByField(N1.CondNames, N2.CondNames);
    end

    % CondGroup2Subj
    if isfield(N2,'CondGroup2Subj') && ~isempty(N2.CondGroup2Subj)
        N1.CondGroup2Subj = copyStructFieldByField(N1.CondGroup2Subj, N2.CondGroup2Subj);
    end

    % SD
    if isfield(N2,'SD') && ~isempty(N2.SD)
        N1.SD = copyStructFieldByField(N1.SD, N2.SD);
    end

case {'subj','subject'}

    % procInput
    if isfield(N2,'procInput')
        if isfield(N2.procInput,'procFunc') && ~isempty(N2.procInput.procFunc)
            N1.procInput = copyStructFieldByField(N1.procInput,N2.procInput,'procInput');
        else
            [N1.procInput.procFunc, N1.procInput.procParam] = procStreamDefault(type);
        end
    end

    % procResult
    if isfield(N2,'procResult') && ~isempty(N2.procResult)
        N1.procResult = copyStructFieldByField(N1.procResult,N2.procResult);
    end

    % CondNames
    if isfield(N2,'CondNames') && ~isempty(N2.CondNames)
        N1.CondNames = copyStructFieldByField(N1.CondNames, N2.CondNames);
    end

    % CondSubj2Run
    if isfield(N2,'CondSubj2Run') && ~isempty(N2.CondSubj2Run)
        N1.CondSubj2Run = copyStructFieldByField(N1.CondSubj2Run, N2.CondSubj2Run);
    end

    % SD
    if isfield(N2,'SD') && ~isempty(N2.SD)
        N1.SD = copyStructFieldByField(N1.SD, N2.SD);
    end
    
case {'run'}
    
    % Nothing to do here. We load the run data when we load the .nirs files 
    % which is the first thing we do in LoadNIRS2Group

    ;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Groups N1 and N2 are considered same if their names 
% are same and their subject set is same.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function B=groupsSame(N1,N2)

B=1;
if ~strcmp(N1.name,N2.name)
    B=0;
    return;
end
for i=1:length(N1.subjs)
    j=existSubj(N1.subjs(i),N2);
    if j==0 || ~subjsSame(N1.subjs(i),N2.subjs(j))
        B=0;
        return;
    end
end
for i=1:length(N2.subjs)
    j=existSubj(N2.subjs(i),N1);
    if j==0 || ~subjsSame(N2.subjs(i),N1.subjs(j))
        B=0;
        return;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subjects N1 and N2 are considered same if their names 
% are same and their sets of runs is same.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function B=subjsSame(N1,N2)

B=1;
if ~strcmp(N1.name,N2.name)
    B=0;
    return;
end
for i=1:length(N1.runs)
    j=existRun(N1.runs(i),N2);
    if j==0
        B=0;
        return;
    end
end
for i=1:length(N2.runs)
    j=existRun(N2.runs(i),N1);
    if j==0
        B=0;
        return;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check whether subject S exists in group G and return 
% its index in G if it does exist. Else return 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function j=existSubj(S,G)

j=0;
for i=1:length(G.subjs)
    if strcmp(S.name,G.subjs(i).name)
        j=i;
        break;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check whether run R exists in subject S and return
% its index in S if it does exist. Else return 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function j=existRun(R,S)

j=0;
for i=1:length(S.runs)
    [sname1, rnum1] = getSubjNameAndRun(R.name,i);
    [sname2, rnum2] = getSubjNameAndRun(S.runs(i).name,i);
    if strcmp(sname1,sname2) && rnum1==rnum2
        j=i;
        break;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No built in matlab function isnumber function which 
% takes a string arg. Using my own.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function b = isnumber(str)    
b = ~isempty(str2num(str));







