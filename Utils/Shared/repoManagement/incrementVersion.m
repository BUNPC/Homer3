function n = incrementVersion(n, changelevel)
switch(changelevel)
    case 'majormajor'
        n(1) = n(1)+1;
        n(2) = 0;
        n(3) = 0;
    case 'major'
        if n(2)<100
            n(2) = n(2)+1;
            n(3) = 0;
        else        
            n(1) = n(1)+1;
            n(2) = 0;
            n(3) = 0;
        end
    case 'minor'
        if n(3)<100
            n(3) = n(3)+1;
        elseif n(2) < 100
            n(2) = n(2)+1;
            n(3) = 0;
        else
            n(1) = n(2)+1;
            n(2) = 0;
            n(3) = 0;
        end
end



