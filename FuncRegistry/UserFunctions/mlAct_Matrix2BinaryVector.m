function mlAct = mlAct_Matrix2BinaryVector(mlAct0, ml)
N = max(size(ml,1), size(mlAct0,1));
mlAct = zeros(N,1);
for iCh = 1:N
    if all(size(mlAct0) == size(ml))
        k = find(mlAct0(:,1)==ml(iCh,1)  &  mlAct0(:,2)==ml(iCh,2)  &  mlAct0(:,4)==ml(iCh,4));
    else
        k = find(mlAct0(:,1)==ml(iCh,1)  &  mlAct0(:,2)==ml(iCh,2));
    end
    if mlAct0(k(1),3)==1
        mlAct(iCh) = 1;
    end
end
