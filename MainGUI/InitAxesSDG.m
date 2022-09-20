function axesSDG = InitAxesSDG(handles)

if ~exist('handles','var')
    handles = [];
end

if isempty(handles)
    hAxes = axes();
else
    hAxes = handles.axesSDG;
end

default_colors = [...
    0.2  0.6  0.1;
    1.0  0.5  0.0;
    1.0  0.0  1.0;
    0.5  0.5  1.0;
    0.0  1.0  1.0;
    1.0  0.0  0.0;
    0.2  0.3  0.1;
    0.8  0.6  0.6;
    0.5  1.0  0.5;
    0.5  1.0  1.0;
    0.0  0.0  0.0;
    0.2  0.2  0.2;
    0.4  0.4  0.4;
    0.6  0.6  0.6;
    0.8  0.8  0.8 ...
];

p = [getAppDir(), 'SDGcolors.csv'];
try
    rgb01 = csvread(p) / 255;
    if size(rgb01, 1) < 6
        rgb01 = default_colors;
        fprintf('SDGcolors.csv is not an appropriate table of more than 6 RGB values. Using default colors.\n')
    else
        fprintf('Loaded %s colors from SDGcolors.csv.\n', num2str(size(rgb01, 1))) 
    end
catch  % File not found
    rgb01 = default_colors;
    fprintf('Failed to load SDGcolors.csv. Using default colors.\n') 
end

axesSDG = struct(...
                 'handles', struct(...
                                   'axes',hAxes, ...
                                   'SD', [], ...
                                   'ch', [] ...
                                  ), ...
                 'iCh', [], ...
                 'iSrcDet', [], ...
                 'SDPairColors', rgb01...
               );

           