function lstAct = mlAct_CombineIndexLists( mlAct1, mlAct2, ml )

lstAct1 = mlAct_Matrix2IndexList(mlAct1, ml);
lstAct2 = mlAct_Matrix2IndexList(mlAct2, ml);
lstAct = [lstAct1(:)', lstAct2(:)'];

k = find(ismember(lstAct,lstAct1) & ismember(lstAct,lstAct2)); 
lstAct = unique(lstAct(k));

