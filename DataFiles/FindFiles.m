function files = FindFiles(handles, fmt)
global hmr

% Parse arguments
if ~exist('handles','var') || isempty(handles)
    handles = [];
end
if ~exist('fmt','var')
    if ~isempty(hmr) && isstruct(hmr) && isfield(hmr,'format')
        fmt = hmr.format;
    else
        fmt = 'nirs';
    end
end

% Check files data set for errors. If there are no valid
% nirs files don't attempt to load them.
files = -1;
while ~isobject(files) 
    switch fmt
        case {'snirf','.snirf'}
            files = SnirfFilesClass(handles).files;
        case {'nirs','.nirs'}
            files = NirsFilesClass(handles).files;
        otherwise
            q = menu('Homer3 only supports .snirf and .nirs file formats. Please choose one.', '.snirf', '.nirs', 'CANCEL');
            if q==3
                return;
            elseif q==2
                fmt = 'nirs';
            else
                fmt = 'snirf';
            end
    end
end

if isempty(files)
    files = NirsFilesClass(handles).files;
    if isempty(files)
        return;
    end
    Nirs2Snirf();
    files = SnirfFilesClass(handles).files;
end

