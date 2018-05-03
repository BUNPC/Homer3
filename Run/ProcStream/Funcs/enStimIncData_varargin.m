% [s,nFuncParam,funcParam,funcParamFormat,funcParamVal] = enStimIncData_varargin(s,t,userdata,varargin)
%
% UI NAME:
% Stim_Include_UserDefVar
%
% Excludes stims based on user-defined variables
%
%
% INPUT:
% s:         s matrix (#time points x #conditions) containing 1 for 
%            each time point and condition that has a stimulus and 
%            zeros otherwise.
% t:         the time vector (#time points x 1)
% userdata:  table of user-defined variable values based on which stims can 
%            be excluded.  (# of stims  x  # of user defined variables)
% varargin:  ranges for each of the user defined variables from userdata.
%
%
% OUTPUT:
% s               : s matrix (#time points x #conditions) 
% nFuncParam      : # of user-defined variables from userdata used 
%                   when function is first added to processing stream. 
% funcParam       : Names of user-defined variables from userdata
%                   when function is first added to processing stream. 
% funcParamFormat : format of user-defined variables from userdata
%                   when function is first added to processing stream. 
% funcParamVal    : values of user-defined variables from userdata
%                   when function is first added to processing stream. 

function [s,nFuncParam,funcParam,funcParamFormat,funcParamVal] = enStimIncData_varargin(s,t,userdata,varargin)

nFuncParam = 0;
funcParam = {};
funcParamFormat = {};
funcParamVal = {};

% First pass during EasyNIRS_ProcessOpt_Init time
% Find out which paramters are in the usertable,
% that's what will be displayed for this function
% in ProcessOpt gui
if ~isempty(userdata)
    nFuncParam = size(userdata.data(:,2:end),2);
    if(nFuncParam==0)
        return;
    end
else
    return;
end

for iParam=1:nFuncParam
    if iParam > length(varargin)
        varargin{iParam}.val = [0 0];	
    end
    k = findstr(userdata.cnames{iParam},' ');
    userdata.cnames{iParam}(k) = '_';
    varargin{iParam}.name = userdata.cnames{iParam};
end

for iParam = 1:nFuncParam
    for iParam0=1:length(varargin)
        if strcmp(varargin{iParam0}.name,userdata.cnames{iParam})
            funcParam{iParam} = varargin{iParam0}.name;
            funcParamFormat{iParam} = '%0.1f %0.1f';
            funcParamVal{iParam} = varargin{iParam0}.val;
            continue;
        end
    end
end

%%%%% Second pass during EasyNIRS_Process time 
%%%%% Select or reject stims.

% If any stims fall within the selection criteria
% reject them.
selectCriteria = funcParamVal;
for ii=1:size(userdata.data,1)
    for jj=1:length(selectCriteria)
        id = userdata.data{ii,1};
        iS = find(t==id);
        tRange = selectCriteria{jj};
        val = str2num(userdata.data{ii,jj+1});        
        if(isscalar(val) && (val<tRange(1) || val>tRange(2)))
            k=find(s(iS,:)==1);
            s(iS,k)=-2;
        end
    end
end
