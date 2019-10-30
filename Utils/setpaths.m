function setpaths(options)

%
% USAGE: 
%
%   setpaths
%   setpaths(1)
%   setpaths(0)
%

currpaths = regexp(path, pathsep, 'split');

p = genpath('.');
newpaths = regexp(p, pathsep, 'split');

% Parse arguments
if ~exist('options','var')
    options = 1;
end



for ii=1:length(newpaths)
    if isempty(newpaths{ii})
        continue;
    end
    
    p = fullpath(newpaths{ii}, 'native');
    if p(end)==filesep
        p(end)='';
    end
    
    if exist(p, 'dir') ~= 7
        continue;
    end
    
    if options
        if ismember(p, currpaths)
            continue;
        end
        addpath(p, '-end')
    else
        if ~ismember(p, currpaths)
            continue;
        end
        rmpath(p)
    end
end


