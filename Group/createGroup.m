function group = createGroup(fname)

group = [];
subj = createSubj(fname, 1, 1, 1);
if isempty(subj)
    return;
end

% Derive group name from the name of the root directory
curr_dir = pwd; 
k = sort([findstr(curr_dir,'/') findstr(curr_dir,'\')]);
name = curr_dir(k(end)+1:end);

group.name = name;
group.type = 'group';
group.fileidx = 0;
group.procInput = InitProcInputGroup();
group.procResult = InitProcResultGroup();
group.nFiles = 0;
group.SD = struct([]);
group.CondNames = {};
group.CondGroup2Subj = [];
group.CondColTbl = [];
group.subjs(1) = subj;

% check criteria for inclusion in group average
%{
group.tRange  = str2num( get(handles.editGrpAvgPassTrange,'string') );
group.chkFlag = get(handles.checkboxGrpAvgPassAllCh,'value');
group.thresh  = str2num( get(handles.editGrpAvgPassThresh,'string') ) * 1e-6;
%}
