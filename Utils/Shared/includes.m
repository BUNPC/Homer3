function b = includes(s1, s2)

    % Sep 4, 2020: Removed verLessThan because it's slowing down Homer3 startup 

% if verLessThan('matlab','9.1')
%     b = ~isempty(strfind(s1,s2));
% else
%     b = contains(s1,s2);
% end
b = ~isempty(strfind(s1,s2)); %#ok<STREMP>
% b = contains(s1,s2);

