function procResult = procStreamCalcRun(run, hListboxFiles, listboxFilesFuncPtr)

listboxFilesFuncPtr(hListboxFiles, [run.iSubj, run.iRun]);

procElem = run;
procStreamCalc();

