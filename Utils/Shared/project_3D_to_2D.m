function  p2 = project_3D_to_2D(p3)
d = distmatrix(p3);
p2_0 = p3(:,1:2);
fun = @(x)myfunc(x,d);

warnid = {'optim:fsolve:NonSquareSystem'};
for ii = 1:length(warnid)
    warning('OFF', warnid{ii});
end

p2 = fsolve(fun, p2_0, optimset('Display','off'));

for ii = 1:length(warnid)
    warning('ON', warnid{ii});
end




% -------------------------------------------------------
function  F = myfunc(p, d)
F = [];
kk = 1;
c = 1.2;
for ii = 1:size(d,1)
    for jj = 1:size(d,2)
        if d(ii,jj) == 0
            continue
        end
        F(kk) = sqrt((p(ii,1) - p(jj,1))^2 + (p(ii,2) - p(jj,2))^2) - d(ii,jj)*c;
        kk = kk+1;
    end
end



% -------------------------------------------------------------------
function d = distmatrix(varargin)

d=[];

v1 = double(varargin{1});
if size(v1,2) == 2
    v1 = [v1, zeros(size(v1,1),1)];
end

if length(varargin)==1
    
    n = size(v1,1);
    d = zeros(n);
    for i = 1:n
        for j = i+1:n        
            d(i,j) = ((v1(i,1) - v1(j,1))^2 + ...
                      (v1(i,2) - v1(j,2))^2 + ...
                      (v1(i,3) - v1(j,3))^2)^0.5;
        end     
    end

elseif length(varargin)==2

    v2 = double(varargin{2});
    m = size(v1,1);
    n = size(v2,1);
    d = zeros(m,n);    
    for i = 1:m
        for j=1:n
            d(i,j) = ((v1(i,1) - v2(j,1))^2 + ...
                      (v1(i,2) - v2(j,2))^2 + ...
                      (v1(i,3) - v2(j,3))^2)^0.5;
        end     
    end    

end

