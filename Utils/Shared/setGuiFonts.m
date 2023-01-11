function setGuiFonts(inp1, inp2)
ns = getNamespace();
if isempty(ns)
    return;
end
if strcmp(ns, 'AtlasViewerGUI')
    if nargin == 0
        setGuiFonts_AtlasViewerGUI();
    elseif nargin == 1
        setGuiFonts_AtlasViewerGUI(inp1);
    elseif nargin == 2
        setGuiFonts_AtlasViewerGUI(inp1, inp2);
    end
elseif strcmp(ns, 'Homer3') || strcmp(ns, 'DataTreeClass') 
    if nargin == 0
        setGuiFonts_Homer3();
    elseif nargin == 1
        setGuiFonts_Homer3(inp1);
    elseif nargin == 2
        setGuiFonts_Homer3(inp1, inp2);
    end
end


% ---------------------------------------------------------
function setGuiFonts_AtlasViewerGUI(h, varargin)

%
%   setGuiFonts_AtlasViewerGUI(h, varargin)
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
FONT_SMALLER    = 16;

if ismac()
    fs_def = 13.0;
elseif ispc()
    fs_def = 10.0;
else
    fs_def = 11.0;
end

if nargin==0
    return;
end

if ~ishandles(h)
    return;
end

% Defaults for different graphics object types
font_uicontrol = initFont_AtlasViewerGUI(fs_def,'bold',[]);
if nargin==2
    font_uicontrol.size = varargin{1};
    font_uicontrol.weight = 'bold';
elseif nargin==3
    font_uicontrol.size = varargin{1};
    font_uicontrol.weight = varargin{2};
end

fc = [0.50, 0.21, 0.11];

font_uipanel   = initFont_AtlasViewerGUI(font_uicontrol.size-1,'bold',fc);
font_uibttngrp = font_uipanel;
font_axes      = initFont_AtlasViewerGUI(font_uicontrol.size+4,'normal',[]);
if ispc()
    font_listbox   = initFont_AtlasViewerGUI(font_uicontrol.size,'normal',[]);
elseif ismac()
    font_listbox   = initFont_AtlasViewerGUI(font_uicontrol.size+1,'normal',[]);
end


hc = get(h, 'children');
for ii=1:length(hc)
    
    if isempty(get(hc(ii),'userdata'))
        userdata = 0;
    else
        userdata = get(hc(ii),'userdata');
        if isstruct(userdata)
            userdata = 0;
        end
    end
    
    if userdata==KEEP_AS_IS
        continue;
    end
    
    if userdata==FONT_BIGGER
        set(hc(ii), 'fontsize',font_uipanel.size);
        set(hc(ii), 'fontweight',font_uipanel.weight);
    elseif strcmp(get(hc(ii), 'type'), 'uicontrol')
        if strcmp(get(hc(ii), 'style'), 'listbox')
            set(hc(ii), 'fontsize',font_listbox.size);
            set(hc(ii), 'fontweight','normal');        
        else
            if userdata==FONT_SMALLER
                set(hc(ii), 'fontsize',font_uicontrol.size-1);
            elseif userdata~=KEEP_FONTSIZE
                if isalphaNumeric(hc(ii).String)
                    set(hc(ii), 'fontsize',font_uicontrol.size);
                else
                    set(hc(ii), 'fontsize',font_uicontrol.size+3);
                end
            end
            if userdata~=KEEP_FONTWEIGHT
                set(hc(ii), 'fontweight',font_uicontrol.weight);
            end
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
        set(hc(ii), 'foregroundcolor',font_uipanel.color);
    elseif strcmp(get(hc(ii), 'type'), 'uibuttongroup')
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_uibttngrp.size);            
        end
        if userdata~=KEEP_FONTWEIGHT
            set(hc(ii), 'fontweight',font_uibttngrp.weight);
        end
        set(hc(ii), 'foregroundcolor',font_uibttngrp.color);
    elseif strcmp(get(hc(ii), 'type'), 'uitable')
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_uicontrol.size);
        end
        if userdata~=KEEP_FONTWEIGHT
            set(hc(ii), 'fontweight',font_uicontrol.weight);
        end
    elseif strcmp(get(hc(ii), 'type'), 'uilistbox')
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_listbox.size);
        end
        set(hc(ii), 'fontweight','normal');
    end
    setGuiFonts_AtlasViewerGUI(hc(ii), font_uicontrol.size, font_uicontrol.weight);
end



% --------------------------------------------------------
function [font] = initFont_AtlasViewerGUI(fs, fw, fc)
if ~exist('fc','var') || isempty(fc)
    fc = [0, 0, 0];
end
font = struct('size',fs,'weight',fw, 'color',fc);





% ---------------------------------------------------------
function setGuiFonts_Homer3(h, varargin)

%
%   setGuiFonts_Homer3(h, varargin)
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
FONT_SMALLER    = 16;

if ismac()
    fs_def = 12.0;
elseif ispc()
    fs_def = 9.0;
else
    fs_def = 11.0;
end

if nargin==0
    return;
end

if ~ishandles(h)
    return;
end

% Defaults for different graphics object types
font_uicontrol = initFont_Homer3(fs_def,'bold',[]);
if nargin==2
    font_uicontrol.size = varargin{1};
    font_uicontrol.weight = 'bold';
elseif nargin==3
    font_uicontrol.size = varargin{1};
    font_uicontrol.weight = varargin{2};
end

fc = [0.50, 0.21, 0.11];

font_uipanel   = initFont_Homer3(font_uicontrol.size-1,'bold',fc);
font_uibttngrp = font_uipanel;
font_axes      = initFont_Homer3(font_uicontrol.size+4,'normal',[]);
if ispc()
    font_listbox = initFont_Homer3(font_uicontrol.size,'normal',[]);
elseif ismac() || isunix()
    font_listbox = initFont_Homer3(font_uicontrol.size+1,'normal',[]);
end


hc = get(h, 'children');
for ii=1:length(hc)
    
    if isempty(get(hc(ii),'userdata'))
        userdata = 0;
    else
        userdata = get(hc(ii),'userdata');
        if isstruct(userdata)
            userdata = 0;
        end
    end
    
    if userdata==KEEP_AS_IS
        continue;
    end
    
    if userdata==FONT_BIGGER
        set(hc(ii), 'fontsize',font_uipanel.size);
        set(hc(ii), 'fontweight',font_uipanel.weight);
    elseif strcmp(get(hc(ii), 'type'), 'uicontrol')
        if strcmp(get(hc(ii), 'style'), 'listbox')
            set(hc(ii), 'fontsize',font_listbox.size);
            set(hc(ii), 'fontweight','normal');        
        else
            if userdata==FONT_SMALLER
                set(hc(ii), 'fontsize',font_uicontrol.size-1);
            elseif userdata~=KEEP_FONTSIZE
                if isalphaNumeric(hc(ii).String)
                    set(hc(ii), 'fontsize',font_uicontrol.size);
                elseif ~isempty(hc(ii).String)
                    set(hc(ii), 'fontsize',font_uicontrol.size+3);
                end
            end
            if userdata~=KEEP_FONTWEIGHT
                set(hc(ii), 'fontweight',font_uicontrol.weight);
            end
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
        set(hc(ii), 'foregroundcolor',font_uipanel.color);
    elseif strcmp(get(hc(ii), 'type'), 'uibuttongroup')
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_uibttngrp.size);            
        end
        if userdata~=KEEP_FONTWEIGHT
            set(hc(ii), 'fontweight',font_uibttngrp.weight);
        end
        set(hc(ii), 'foregroundcolor',font_uibttngrp.color);
    elseif strcmp(get(hc(ii), 'type'), 'uitable')
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_uicontrol.size);
        end
        if userdata~=KEEP_FONTWEIGHT
            set(hc(ii), 'fontweight',font_uicontrol.weight);
        end
    elseif strcmp(get(hc(ii), 'type'), 'uilistbox')
        if userdata~=KEEP_FONTSIZE
            set(hc(ii), 'fontsize',font_listbox.size);
        end
        set(hc(ii), 'fontweight','normal');
    end
    setGuiFonts_Homer3(hc(ii), font_uicontrol.size, font_uicontrol.weight);
end



% --------------------------------------------------------
function [font] = initFont_Homer3(fs, fw, fc)
if ~exist('fc','var') || isempty(fc)
    fc = [0, 0, 0];
end
font = struct('size',fs,'weight',fw, 'color',fc);




% --------------------------------------------------------
function b = isalphaNumeric(s)
b = false;
if isempty(s)
    return;
end
if ischar(s)
    s = {s};
end
for ii = 1:length(s)
    if ~any( (s{ii}>='0' & s{ii}<='9') | (s{ii}>='a' & s{ii}<='z') | (s{ii}>='A' & s{ii}<='Z') )
        return
    end
end
b = true;


