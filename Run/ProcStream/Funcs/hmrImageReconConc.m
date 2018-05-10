function [HbO, HbR, err] = hmrImageReconConc(dodavgimg, dodresid, alpha, Adot)

HbO = [];
HbR = [];
err = 0;
if size(dodavgimg,1) ~=  size(Adot,1)
    err=1;
    return;
end

nconc = size(dodavgimg,2);
img = zeros(size(Adot,2),length(nconc));

B = Adot*Adot';


%%  Tikhonov regularization
% solution to arg min ||Y-Ax||^2 + lamda * ||x||^2 (prior only on state estimate)
 img =  Adot' * (inv(B + alpha * eigs(B,1) * eye(size(Adot,1))) * dodavgimg);  % Custo2010NI; BoasDale2005; typical alpha = 0.01

 % solution to arg min ||Y-Ax||^2 + lamda * ||x - x0||^2
 %img = img0 + Adot' * ((B + alpha^2 * eye(size(Adot,1))) \ (dodavgimg - Adot * img0 * ones(size(Adot,2),1) )); 
 
% solution to arg min ||C^1/2*(Y-Ax)||^2 + lamda * ||P^1/2*(x - x0)||^2
% P = alpha^2 * speye(size(Adot,2));
% invP = inv(P);
% C = abs(cov(dodresid)); % (var(dod)); % variance of the measurement       
% invC = abs(pinv(C));
% As = sparse(double(Adot));
% img =  P * As' * ((As*P*As' + C) \ dodavgimg); % or: img = (As' * invC * As + invP)\(As' * invC * dodavgimg);

% 
% C = cov(dodresid);
% img = Adot' * ((B + alpha*C) \ dodavgimg);
 
% get HbO and HbR 
HbO = img(1:size(img,1)/2);
HbR = img(size(img,1)/2+1:end);

