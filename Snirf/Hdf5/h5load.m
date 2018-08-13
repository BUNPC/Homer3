function varval = h5load(fname, varval, varname)

if nargin==1
    varname = '';
end
varval = h5loadvar(fname, varval, varname);



% ---------------------------------------------------------------------------
function varval = h5loadvar(fname, varval, varname)

% Simple matrices: uint, int, double, char, etc
if ~isstruct(varval) && ~isobject(varval)
    
    % Create new leaf variable if it doesn't exist. 
    if exist(fname, 'file') && h5exist(h5info(fname), varname)
        cmdstr = sprintf('varval = h5read(fname, ''%s'');', varname);
        fprintf('%s\n', cmdstr);
        try
            eval( cmdstr );
        catch
            dbg=1;
        end
    elseif exist(fname, 'file') && h5exist(h5info(fname), [varname, '_0'])
        switch(class(varval))
            case 'char'
                varval = '';
            case 'cell'
                varval = {};
            otherwise
                varval = [];                
        end
    end
    
% Structs and Classes
else
    
    props = propnames(varval(1));
    jj=1;
    while 1
        
        % Construct varname as it would appear in HDF5 file
        if isempty(varname) || varname(1)=='/'
            varname_jj = sprintf('%s_%d', varname, jj);
        else
            varname_jj = sprintf('/%s_%d', varname, jj);
        end
        
        % Check if next struct or class element exists in HDF5 file
        if ~h5exist(h5info(fname), varname_jj);
            break;
        end
        
        % Get values for all class/struct properties or fields
        for ii=1:length(props)
            subvarname = sprintf('%s/%s', varname_jj, props{ii});
            if jj>length(varval)
                if isstruct(varval)
                    varval(jj) = varval(1);
                else
                    eval( sprintf('varval(jj) = %s();', class(varval(1))) );
                end
            end
            eval( sprintf('varval(jj).%s = h5loadvar(fname, varval(jj).%s, subvarname);', props{ii}, props{ii}) );
        end
        jj=jj+1;
    end
    
end


