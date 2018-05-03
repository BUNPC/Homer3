function procResult = CalcGroup(group, hListboxFiles, listboxFilesFuncPtr)

group.procResult = procStreamCalcGroup(group, hListboxFiles, listboxFilesFuncPtr);

saveGroup(group);

procResult = group.procResult;

