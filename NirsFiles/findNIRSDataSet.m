function files = findNIRSDataSet()

files = mydir('*.nirs');
if isempty( files )
    
    % If there are no .nirs files in current dir, don't give up yet - check
    % the subdirs for .nirs files. 
    dirs = mydir();
    for ii=1:length(dirs) 
        if dirs(ii).isdir && ...
           ~strcmp(dirs(ii).name,'.') && ...
           ~strcmp(dirs(ii).name,'..') && ...
           ~strcmp(dirs(ii).name,'hide')

            dirs(ii).idx = length(files)+1;
            cd(dirs(ii).name);
            foos = mydir('*.nirs');
            nfoos = length(foos);
            if nfoos>0
                for jj=1:nfoos
                    foos(jj).subjdir      = dirs(ii).name;
                    foos(jj).subjdiridx   = dirs(ii).idx;
                    foos(jj).idx          = dirs(ii).idx+jj;
                    foos(jj).filename     = foos(jj).name;
                    foos(jj).name         = [dirs(ii).name '/' foos(jj).name];
                    foos(jj).map2group    = struct('iSubj',0,'iRun',0);
                end
            
                % Add .nirs file from current subdir to files struct
                if isempty(files)
                    files = dirs(ii);
                else
                    files(end+1) = dirs(ii);
                end
                files(end+1:end+nfoos) = foos;
            end
            cd('../');
            
        end 
    end
end
