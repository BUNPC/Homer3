function cmp = cstrcmp(s1,s2)

    % Force the strings to equal length
    x = char({s1;s2});

    % Subtract one from the other
    d = x(1,:) - x(2,:);

    % Remove zero entries
    d(~d) = [];
    if isempty(d)
        cmp = 0;
    else
        cmp = d(1);
    end

end

