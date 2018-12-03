function DisplayCurrElem(currElem, varargin)

if nargin<2
    return;
end
canvas = varargin{1};
if nargin>2
    datatype = varargin{2};
    buttonVals = varargin{3};
    condition = varargin{4};
end

if strcmp(canvas.name, 'guiMain')
    currElem.procElem.DisplayGuiMain(canvas);
elseif strcmp(canvas.name, 'plotprobe')
    currElem.procElem.DisplayPlotProbe(canvas, datatype, buttonVals, condition);
end 
