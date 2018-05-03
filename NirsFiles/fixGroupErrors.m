function N = fixGroupErrors(N, type)

switch(type)
    
case {'group','grp'}

    if N.err
        N.err = 0;
    end
    for ii=1:length(N.subjs)
        N.subjs(ii) = fixGroupErrors(N.subjs(ii), 'subj');
    end

case {'subj','subject'}

    if N.err
        N.err = 0;
    end
    for ii=1:length(N.runs)
        if ~isfield(N.runs(ii), 'name')
            N.runs(ii).name = '';
        end
        N.runs(ii) = fixGroupErrors(N.runs(ii), 'run');
    end

case {'run'}

    if N.err && isfield(N, 'filename')
        N.name = N.filename;
        N.err = 0;
    end
   
end
