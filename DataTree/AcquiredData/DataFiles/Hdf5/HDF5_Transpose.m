function val = HDF5_Transpose(val, option)

if ~exist('option','var')
    option = '';
end

% Matlab stores contiguous muti-dimensional arrays in column-major order.
% HDF5 stores them in row-major order. We want to transpose the data to agree
% with the file format's storage order.
if (~isrow(val) && ~iscolumn(val))              || ...      % Matrices
     ~isempty(findstr('multidim', option))     || ...      % Force multi-dimensional even if vector
     ~isempty(findstr('2D', option))           || ...      % Force 2D even if vector
     ~isempty(findstr('3D', option))                       % Force 3D even if vector
    
    val = permute(val, ndims(val):-1:1);
    
elseif iscolumn(val) && ischar(val)
    
    val = permute(val, ndims(val):-1:1);
    
end

