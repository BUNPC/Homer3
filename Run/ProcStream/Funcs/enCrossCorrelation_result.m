function [cc,ml] = enCrossCorrelation_result( cc, ml, cc_thresh )

lst = find(ml(:,4)==1);
nch = length(lst);
tlabel = '';
for ii=1:length(lst)
    tlabel = sprintf( '%s,''%c%d''',tlabel,char(64+ml(lst(ii),1)), ml(lst(ii),2) );
end
tlabel(1) = [];


% HbO
figure(1)

cc0 = cc(:,:,1);
cc0(find(abs(cc(:,:,1))<cc_thresh))=0;

imagesc(cc0,[-1 1])
colorbar
set(gca,'xtick',[1:nch])
set(gca,'xticklabel',eval(sprintf('{%s}', tlabel)) )
set(gca,'ytick',[1:nch])
set(gca,'yticklabel',eval(sprintf('{%s}', tlabel)) )
title( 'HbO Cross-Correlation')

% HbR
figure(2)

cc0 = cc(:,:,2);
cc0(find(abs(cc(:,:,2))<cc_thresh))=0;

imagesc(cc0,[-1 1])
colorbar
set(gca,'xtick',[1:nch])
set(gca,'xticklabel',eval(sprintf('{%s}', tlabel)) )
set(gca,'ytick',[1:nch])
set(gca,'yticklabel',eval(sprintf('{%s}', tlabel)) )
title( 'HbR Cross-Correlation')
