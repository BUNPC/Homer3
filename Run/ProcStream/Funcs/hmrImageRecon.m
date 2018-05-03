function img = hmrImageRecon( SD, dodavgimg, dodresid, alpha )

img = [];

% load Adot if it exists in the fw directory
if ~exist('fw','dir')
    menu('You need the file fw/Adot.mat to perform an image reconstruction.','Okay');
    return;
end
cd('fw')
if ~exist('Adot.mat','file')
    menu('You need the file fw/Adot.mat to perform an image reconstruction.','Okay');
    return;
end
load('Adot.mat')

nMeas = length(find(SD.MeasList(:,4)==1));

img = zeros(size(Adot,2),length(SD.Lambda),size(dodavgimg,2));
for ii=1:size(dodavgimg,2)
    for iWav=1:length(SD.Lambda)
        lst = find(SD.MeasList(:,4)==iWav);
        B = Adot(lst,:)*Adot(lst,:)';
        Bmax = eigs(double(B),1);
        C = cov(dodresid(:,lst));
%        img(:,iWav,ii) = Adot(lst,:)' * ((B + alpha*Bmax*eye(nMeas,nMeas)) \ dodavgimg(lst,ii));
        img(:,iWav,ii) = Adot(lst,:)' * ((B + alpha*C) \ dodavgimg(lst,ii));
    end
end

save('Aimg.mat','img')
cd('..')







    