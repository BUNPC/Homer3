%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract the subject name and run number from a .nirs
% filename.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sname, rnum, k2] = getSubjNameAndRun(fname,rnum)

k1=findstr(fname,'/');
k2=findstr(fname,'.nirs');
if ~isempty(k1)
    sname = fname(1:k1-1);
else
    k1=findstr(fname,'_run');
    
    % Check if there's subject and run info in the filename
    if(~isempty(k1))
        sname = fname(1:k1-1);
        rnum = [fname(k1(1)+4:k2(1)-1)];
        k3 = findstr(rnum,'_');
        if ~isempty(k3)
            if ~isempty(rnum)
                rnum = rnum(1:k3-1);
            end
        end
        if isempty(rnum) | ~isnumber(rnum)
            rnum = 1;
        else
            rnum = str2num(rnum);
        end
    else
        sname = fname(1:k2-1);
        rnum = 1;
    end
end
