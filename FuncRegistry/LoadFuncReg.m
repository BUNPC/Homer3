function R = LoadFuncReg(parent)

% Syntax:
%
%       R = LoadFuncReg()
%       R = LoadFuncReg(parent)
%
% Description:
%       
%       


% First get all the argument there are to get using the 8 possible syntax
% calls 
if nargin==0
    parent = [];
end

if ~isempty(parent) && isproperty(parent, 'R') && ~isempty(parent.reg)
    reg = parent.reg;
else
    reg = RegistriesClass();
end

