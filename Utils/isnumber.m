function b = isnumber(str)
    
b = true;

if isempty(str)
    b = false;
    return;
end

d = isdigit(str);

% Get all the nonnumeric characters and check if they form a numeric string 
k = find(d==0);
for ii=1:length(k)
    
    str_left  = str(1:k(ii)-1);
    str_right = str(k(ii)+1:end);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Rules for legal numeric string
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch( str(k(ii)) )
        
        case '.'
            
            % String with '.' is a numeric string if
            %     1) the string to the left and right of '.' is numeric (e.g., 2.3)
            %     2) the string to only to the left of '.' is numeric (e.g.,  2.)
            %     3) the string to only to the right of '.' is numeric (e.g., .3)
            if isnumber(str_left) & isnumber(str_right)
                continue;
            end
            if isnumber(str_right)
                continue;
            end
            if isnumber(str_left)
                continue;
            end
            
        case 'e'
            
            % String with 'e' is a numeric string if
            %     1) the string to the left and right of 'e' is numeric (e.g., 1e4)
            if isnumber(str_left) & isnumber(str_right)
                continue;
            end
            
            
        case '-'
            
            % String with '-' is a numeric string if
            %     1) the string to the left and right of '-' is numeric (e.g., 8-6)
            %     2) the string to only to the left of '-' is numeric (e.g., -6)
            if isnumber(str_left) & isnumber(str_right)
                continue;
            end
            if isnumber(str_right)
                continue;
            end
            
        case '+'
            
            % String with '+' is a numeric string if
            %     1) the string to the left and right of '-' is numeric (e.g., 8+6)
            %     2) the string to only to the left of '-' is numeric (e.g., +6)
            if isnumber(str_left) & isnumber(str_right)
                continue;
            end
            if isnumber(str_right)
                continue;
            end
            
        case ' '
            
            if isnumber(str_left)
                continue;
            end
            if isnumber(str_right)
                continue;
            end
            
    end
    b = false;
end
