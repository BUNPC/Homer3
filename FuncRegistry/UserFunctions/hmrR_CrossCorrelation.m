% SYNTAX:
% [cc, cc_thresh] = hmrR_CrossCorrelation(data_dc, cc_thresh)
%
% UI NAME:
% Cross_Correlation
%
% DESCRIPTION:
%
% INPUT:
% data_dc0: SNIRF.data container with the delta concentration
%
% OUTPUT:
% cc:
%
% USAGE OPTIONS:
% Cross_Correlation: cc = hmrR_BlockAvg(dc, cc_thresh)
%
% PARAMETERS:
% cc_thresh: 0.40
%
function cc = hmrR_CrossCorrelation(data_dc, cc_thresh)

cc = cell(length(data_dc),1);
for iBlk=1:length(data_dc)
    dc0 = data_dc(iBlk).GetDataTimeSeries();    
    dc0 = reshape(dc0, size(dc0,1), 3, size(dc0,2)/3);    
    
    % HbO
    dc = squeeze(dc0(:,1,:));
    dc = (dc-ones(length(dc),1)*mean(dc,1))./(ones(length(dc),1)*std(dc,[],1));
    cc{iBlk}(:,:,1) = dc'*dc / length(dc);
    
    % HbR
    dc = squeeze(dc0(:,2,:));
    dc = (dc-ones(length(dc),1)*mean(dc,1))./(ones(length(dc),1)*std(dc,[],1));
    cc{iBlk}(:,:,2) = dc'*dc / length(dc);
end

