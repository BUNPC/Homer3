% [cc,ml,cc_thresh] = enCrossCorrelation( SD, dc0, cc_thresh )
% 
% UI NAME:
% Cross_Correlation
%
%

function [cc,ml,cc_thresh] = enCrossCorrelation( SD, dc0, cc_thresh )

ml = SD.MeasList;

% HbO
dc = squeeze(dc0(:,1,:));
dc = (dc-ones(length(dc),1)*mean(dc,1))./(ones(length(dc),1)*std(dc,[],1));
cc(:,:,1) = dc'*dc / length(dc);

% HbR
dc = squeeze(dc0(:,2,:));
dc = (dc-ones(length(dc),1)*mean(dc,1))./(ones(length(dc),1)*std(dc,[],1));
cc(:,:,2) = dc'*dc / length(dc);
