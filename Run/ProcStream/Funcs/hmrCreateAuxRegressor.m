function Aaux = hmrCreateAuxRegressor( aux, t, param )

if param(1)==0
    Aaux = [];
    return;
end

nReg = size(param,1);
Aaux = zeros(size(aux,1),nReg);
for iReg = 1:nReg
    y = aux(:,param(iReg,1));
    y = hmrBandpassFilt( y, t, param(iReg,2), param(iReg,3) );
    Aaux(:,iReg) = y;
end
