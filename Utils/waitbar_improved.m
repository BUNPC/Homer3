function h = waitbar_improved(X, msg, varargin)

h = [];
if nargin<2
    return;
end

if nargin==2
    if ~ischar(msg)
        msg = '';
    end
elseif nargin==3
    h = msg;
    msg = varargin{1};
end

nchar = length(msg);

if ishandles(h)
    buff = 20;
    
    set(h, 'units','characters');
    hc = get(h, 'children');
    set(hc, 'units','characters');
    
    p1 = get(h, 'position'); 
    p2 = get(hc(1), 'position'); 
    
    if nchar>=p1(3)-buff
        set(h, 'position',[p1(1), p1(2), p1(3)+(nchar-p1(3))+1.5*buff, p1(4)]);
    end
    if nchar>=p2(3)-buff
        set(hc(1), 'position',[p2(1), p2(2), p2(3)+(nchar-p2(3))+buff, p2(4)]);
    end
end

if ~ishandles(h)
    h = waitbar(X, sprintf_waitbar(msg));
else
    waitbar(X, h, sprintf_waitbar(msg));
end


