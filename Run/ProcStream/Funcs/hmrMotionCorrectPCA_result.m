function hmrMotionCorrectPCA_result( d, svs, nSV )

svsc = svs; 
for idx = 2:size(svs,1)
    svsc(idx,:) = svsc(idx-1,:) + svs(idx,:);
end

figure(2);
if size(svs,2)==1
    subplot(1,1,1)
    plot([svs svsc],'.');
    ylim([0 1])
    title( sprintf('Singular Value Spectrum (nSV=%d)',nSV) )
else
    subplot(1,2,1)
    plot([svs(:,1) svsc(:,1)],'.');
    ylim([0 1])
    title( sprintf('HbO Singular Value Spectrum (nSV=%d)',nSV(1)) )
    
    subplot(1,2,2)
    plot([svs(:,2) svsc(:,2)],'.');
    ylim([0 1])
    title( sprintf('HbR Singular Value Spectrum (nSV=%d)',nSV(2)) )
end