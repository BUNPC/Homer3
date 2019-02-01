function setGuiFonts(h, varargin)

%
%   setGuiFonts(h, varargin)
%
%   handle 'userdata' data settings:
%
%    0 - AUTO_SETTING
%    1 - KEEP_AS_IS
%    2 - KEEP_FONTSIZE
%    4 - KEEP_FONTWEIGHT
%    8 - FONTSIZE_BIGGER
%   16 - TBD
%   32 - TBD


AUTO_SETTING    = 0;
KEEP_AS_IS      = 1;
KEEP_FONTSIZE   = 2;
KEEP_FONTWEIGHT = 4;
FONT_BIGGER     = 8;

if ismac()
    fs_def = 11.0;
elseif ispc()
    fs_def = 9.0;
else
    fs_def = 10.0;
end

if nargin==0
    return;
end

if ~ishandles(h)
    return;
end

% Defaults for different graphics object types
font_uicontrol = initFont(fs_def,'bold');
if nargin==2
    font_uicontrol.size = varargin{1};
    font_uicontrol.weight = 'bold';
elseif nargin==3
    font_uicontrol.size = varargin{1};
    font_uicontrol.weight = varargin{2};
end
font_uipanel   = initFont(font_uicontrol.size+1,'bold');
font_axes   = initFont(font_uicontrol.size+3,'normal');


hc = get(h, 'children');
for ii=1:length(hc)
    
    if isempty(get(hc(ii),'userdata'))
        userdata = 0;
    else
        userdata = get(hc(ii),'userdata');
    end
    
    if userdata==KEEP_AS_IS
        continue;
    end
    
    if userdata==FONT_BIGGER
        set(hc(ii), 'fontsize',font_uipanel.size);
        set(hc(ii), 'fontweight',font_uipanel.weight);
    elseif strcmp(get(hc(ii), 'type'), 'uicontrol')
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_uicontrol.size);
        end
        if userdata~=KEEP_FONTWEIGHT
            set(hc(ii), 'fontweight',font_uicontrol.weight);
        end
    elseif strcmp(get(hc(ii), 'type'), 'axes')
        set(hc(ii), 'fontunits','points');
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_axes.size);
        end
        if userdata~=KEEP_FONTWEIGHT
            set(hc(ii), 'fontweight',font_axes.weight);
        end
    elseif strcmp(get(hc(ii), 'type'), 'uipanel')
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_uipanel.size);
        end
        if userdata~=KEEP_FONTWEIGHT
            set(hc(ii), 'fontweight',font_uipanel.weight);
        end
    elseif strcmp(get(hc(ii), 'type'), 'uibuttongroup')
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_uicontrol.size);
        end
        if userdata~=KEEP_FONTWEIGHT
            set(hc(ii), 'fontweight',font_uicontrol.weight);
        end
    elseif strcmp(get(hc(ii), 'type'), 'uitable')
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_uicontrol.size);
        end
        if userdata~=KEEP_FONTWEIGHT
            set(hc(ii), 'fontweight',font_uicontrol.weight);
        end
    end
    setGuiFonts(hc(ii), font_uicontrol.size, font_uicontrol.weight);
end



% --------------------------------------------------------
function font = initFont(fs, fw)

font = struct('size',fs,'weight',fw);


