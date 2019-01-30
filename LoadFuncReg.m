function funcReg = LoadFuncReg(parent)

% Syntax:
%
%       funcReg = LoadFuncReg()
%       funcReg = LoadFuncReg(parent)
%
% Description:
%       
%       


% First get all the argument there are to get using the 8 possible syntax
% calls 
if nargin==0
    parent = [];
end

if ~isempty(parent) && isproperty(parent, 'funcReg') && ~isempty(parent.funcReg)
    funcReg = parent.funcReg;
else
    funcReg = FuncRegClass();
end

