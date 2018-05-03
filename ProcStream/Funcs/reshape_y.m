function y = reshape_y(y, SD)

yold = y;
lst1 = find(SD.MeasList(:,4)==1);

if ndims(y)==2
    y = zeros(size(yold,1),length(lst1),length(SD.Lambda));
elseif ndims(y)==3
    y = zeros(size(yold,1),length(lst1),length(SD.Lambda),size(yold,3));
end

for iML = 1:length(lst1)
    for iLambda = 1:length(SD.Lambda)
        
        idx = find(SD.MeasList(:,1)==SD.MeasList(lst1(iML),1) & ...
                   SD.MeasList(:,2)==SD.MeasList(lst1(iML),2) & ...
                   SD.MeasList(:,4)==iLambda );
               
        if ndims(yold)==2
            y(:,iML,iLambda) = yold(:,idx);
        elseif ndims(yold)==3
            y(:,iML,iLambda,:) = yold(:,idx,:);
        end
        
    end
end

