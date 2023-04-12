function mlAct = mlAct_Initialize(mlAct0, ml)
% if size(ml,2) > 2
%     k = find(ml(:,4)==1);
% else
%     k = 1:size(ml,1);
% end
k = 1:size(ml,1);
if isvector(mlAct0) && (length(mlAct0) == length(k))
    if size(ml,2)==4
        mlAct = [ ml(:,1:2), mlAct0, ml(:,4) ];
    else
        mlAct = [ ml(:,1:2), mlAct0, ones(size(ml,1),1) ];
    end
elseif isvector(mlAct0) && (length(mlAct0) > length(k))
    mlAct = [ ml(k,1:2), ones(size(ml(k,:),1),1), ml(k,4) ];
elseif size(mlAct0,1) == length(k)
    mlAct = mlAct0;
elseif size(ml,2) == 2
    if ~isempty(mlAct0)
        mlAct = mlAct0;
    else
        mlAct = [ ml(k,1:2), ones(size(ml(k,:),1),2) ];
    end        
else
    mlAct = [ ml(k,1:2), ones(size(ml(k,:),1),1), ml(k,4) ];
end

if size(ml,2) == 2
    k = find(mlAct(:,4)==1);
    mlAct = mlAct(k,:);
end
