function h = waitbar_improved(X, msg, varargin)
global cfg
cfg = InitConfig(cfg);

h = [];

quietMode = cfg.GetValue('Quiet Mode');
if strcmpi(quietMode, 'on')
    return
end

if nargin<2
    return;
end

if nargin==2
    if ~ischar(msg)
        msg = '';
    end
    if ishandle(X) && strcmpi(get(X,'Type'),'figure')
        h = X;
    end
elseif nargin==3
    h = msg;
    msg = varargin{1};
end

nchar = length(msg);

if ishandles(h)
    
    if strcmpi(msg, 'close')
        close(h);
        return;
    end
    
    buff = 20;
    set(h, 'units','characters');
    hc = get(h, 'children');    
    for ii = 1:length(hc)
        if strcmpi(get(hc(ii), 'type'), 'axes')
            set(hc(ii), 'units','characters');
            
            p1 = get(h, 'position');
            p2 = get(hc(ii), 'position');
            
            if nchar>=p1(3)-buff
                set(h, 'position',[p1(1), p1(2), p1(3)+(nchar-p1(3))+1.5*buff, p1(4)]);
            end
            if nchar>=p2(3)-buff
                set(hc(ii), 'position',[p2(1), p2(2), p2(3)+(nchar-p2(3))+buff, p2(4)]);
            end
            break;
        end
    end
    
end

if ~ishandles(h)
    h = waitbar(X, sprintf_waitbar(msg));
else
    waitbar(X, h, sprintf_waitbar(msg));
end


