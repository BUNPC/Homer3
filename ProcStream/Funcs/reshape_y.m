function y = reshape_y(y, MeasList, Lambda)

yold = y;
lst1 = find(MeasList(:,4)==1);

if ndims(y)==2
    y = zeros(size(yold,1),length(lst1),length(Lambda));
elseif ndims(y)==3
    y = zeros(size(yold,1),length(lst1),length(Lambda),size(yold,3));
end

for iML = 1:length(lst1)
    for iLambda = 1:length(Lambda)
        
        idx = find(MeasList(:,1)==MeasList(lst1(iML),1) & ...
                   MeasList(:,2)==MeasList(lst1(iML),2) & ...
                   MeasList(:,4)==iLambda );
               
        if ndims(yold)==2
            y(:,iML,iLambda) = yold(:,idx);
        elseif ndims(yold)==3
            y(:,iML,iLambda,:) = yold(:,idx,:);
        end
        
    end
end

