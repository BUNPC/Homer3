function procResult = CalcRun(run, hListboxFiles, listboxFilesFuncPtr)

% Load the fields in the run that are stored only in the 
% .nirs file, not the group tree. We keep all read only 
% parameters in the .nirs file as well as parameters 
% too big to store for every element in the group tree.

run = LoadCurrRun(run);
run.procResult = procStreamCalcRun(run, hListboxFiles, listboxFilesFuncPtr);
SaveRun(run,'savetodisk');
procResult = run.procResult;

