function procInput = procStreamCopy2Old(procInput)

if procInput.conversionFlag==false
    return;
end

msg1 = sprintf('NIRS files version were generated by an older version of Homer.\n');
msg2 = sprintf('About to save processing stream to NIRS files. Do you want to \n');
msg3 = sprintf('save new processing results in the older format (ie, keep the current\n');
msg4 = sprintf('older format in the NIRS files) or in the current format.');

msg = [msg1, msg2, msg3, msg4];
q = menu(msg, 'Save in Current Format', 'Save in Older Format');
if q==1
    return;
end

procFunc = procInput.procFunc;
procFunc2 = struc([]);

nFunc = 0;
for ii=1:length(procFunc)
    nFunc=nFunc+1;
    procFunc2.funcName{ii}        = procFunc(ii).funcName;
    procFunc2.funcNameUI{ii}      = procFunc(ii).funcNameUI;
    procFunc2.funcArgOut{ii}      = procFunc(ii).funcArgOut;
    procFunc2.funcArgIn{ii}       = procFunc(ii).funcArgIn;
    procFunc2.nFuncParam(ii)      = procFunc(ii).nFuncParam;
    procFunc2.nFuncParamVar(ii)   = procFunc(ii).nFuncParamVar;
    procFunc2.funcParam{ii}       = procFunc(ii).funcParam;
    procFunc2.funcParamFormat{ii} = procFunc(ii).funcParamFormat;
    procFunc2.funcParamVal{ii}    = procFunc(ii).funcParamVal;
end

procInput.procFunc = procFunc2;

