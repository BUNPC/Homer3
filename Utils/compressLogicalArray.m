function ac = compressLogicalArray(a)
ac = [];
if isempty(a)
    return;
end
if all(a==1)
    ac = [1,length(a), 1];
    return
end
if all(a==0)
    ac = [1,length(a), 0];
    return
end
k = find(a==0);
kk = 1;

% Generate all zero intervals
for ii = 1:length(k)
    if ii == 1
        iS = k(ii);
        iE = k(ii);
    end
    if ii>1 && k(ii-1)+1 == k(ii)
        iE = iE+1;
    elseif ii>1 && k(ii-1)+1 < k(ii)
        ac(kk,:) = [iS, iE, 0]; %#ok<*AGROW>
        kk = kk+1;
        iS = k(ii);
        iE = k(ii);
    end
    if ii==length(k)
        ac(kk,:) = [iS, iE, 0];
    end
end


% Generate all one intervals
kk = 1;
for ii = 1:size(ac,1)
    if ii == 1
        if ac(ii,1) == 1
            ac2(kk,:) = ac(ii,:);
        else
            ac2(kk,:) = [1, ac(ii,1)-1, 1];
            kk = kk+1;
            ac2(kk,:) = ac(ii,:);
        end
    else
        ac2(kk,:) = [ac(ii-1,2)+1, ac(ii,1)-1, 1];
        kk = kk+1;
        ac2(kk,:) = ac(ii,:);
    end    
    kk = kk+1;
    if ii==size(ac,1) && ac(ii,2)<length(a)
        ac2(kk,:) = [ac(ii,2)+1, length(a), 1];
        kk = kk+1;
    end        
end

ac = ac2;

