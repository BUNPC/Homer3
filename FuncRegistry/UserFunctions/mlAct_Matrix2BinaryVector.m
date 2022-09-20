function mlAct = mlAct_Matrix2BinaryVector(mlAct0, ml)
mlAct = zeros(size(ml,1),1);
for iCh = 1:size(ml,1)
    if size(ml,2)==4
        k = find(mlAct0(:,1)==ml(iCh,1)  &  mlAct0(:,2)==ml(iCh,2)  &  mlAct0(:,4)==ml(iCh,4));
    else
        k = find(mlAct0(:,1)==ml(iCh,1)  &  mlAct0(:,2)==ml(iCh,2));
    end
    if mlAct0(k,3)==1
        mlAct(iCh) = 1;
    end
end

