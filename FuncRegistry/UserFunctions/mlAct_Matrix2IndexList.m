function lstAct = mlAct_Matrix2IndexList(mlAct, ml)
lstAct = [];
for iCh = 1:size(ml,1)
    if size(ml,2)==4
        k = find(mlAct(:,1)==ml(iCh,1)  &  mlAct(:,2)==ml(iCh,2)  &  mlAct(:,4)==ml(iCh,4));
    else
        k = find(mlAct(:,1)==ml(iCh,1)  &  mlAct(:,2)==ml(iCh,2));
    end
    if mlAct(k,3)==1
        lstAct = [lstAct; iCh];
    end
end

