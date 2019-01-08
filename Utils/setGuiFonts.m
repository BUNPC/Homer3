function setGuiFonts(h, varargin)

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
font_axes   = initFont(font_uicontrol.size+3,'bold');

hc = get(h, 'children');
for ii=1:length(hc)
    if strcmp(get(hc(ii), 'type'), 'uicontrol')
        set(hc(ii), 'fontsize',font_uicontrol.size, 'fontweight',font_uicontrol.weight);
    elseif strcmp(get(hc(ii), 'type'), 'axes')
        set(hc(ii), 'fontunits','points', 'fontsize',font_axes.size, 'fontweight',font_axes.weight);
    elseif strcmp(get(hc(ii), 'type'), 'uipanel')
        set(hc(ii), 'fontsize',font_uipanel.size, 'fontweight',font_uipanel.weight);
    elseif strcmp(get(hc(ii), 'type'), 'uibuttongroup')
        set(hc(ii), 'fontsize',font_uicontrol.size, 'fontweight',font_uicontrol.weight);
    end
    setGuiFonts(hc(ii), font_uicontrol.size, font_uicontrol.weight);
end



% --------------------------------------------------------
function font = initFont(fs, fw)

font = struct('size',fs,'weight',fw);


