function procFunc = procStreamSetHelp(procElem)

procFunc = procElem.procInput.procFunc;
procFuncR = repmat(InitProcFunc(),0,1);
reg = procStreamReg(procElem);

for jj=1:length(reg)
    C = textscan(reg{jj}{1}, '%s');
    procFuncR(jj) = parseSection(C{1}, procElem);    
    procFuncR(jj).funcHelp.strs = reg{jj};   
end

procFunc = procStreamHelpParse(procFuncR, procFunc);


% 
% for ii=1:length(procFunc)
%     for jj=1:length(reg)
%         C = textscan(reg{jj}{1}, '%s');
%         procFuncReg = parseSection(C{1}, procElem);
%         
%         procFuncReg.funcHelp.strs = reg{jj};
%         procFunc = procStreamHelpParse(procFuncReg, procFunc);
%     end
% end
% 
