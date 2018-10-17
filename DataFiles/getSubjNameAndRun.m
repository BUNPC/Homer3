function [sname, rnum, iext] = getSubjNameAndRun(name,rnum)

[pname, ~, ext] = fileparts(name);

% If name is the name of a subject folder
if isempty(ext)
    sname = name;
    return;
end

% If name contains subject folder in it
if ~isempty(pname)
    sname = pname;
    iext = [];
else
    iext = strfind(name, ext);
    k1=strfind(name,'_run');

    % Check if there's subject and run info in the filename 
    if(~isempty(k1))
        sname = name(1:k1-1);
        rnum = name(k1(1)+4:iext(1)-1);
        k3 = strfind(rnum,'_');
        if ~isempty(k3)
            if ~isempty(rnum)
                rnum = rnum(1:k3-1);
            end
        end
        if isempty(rnum) || ~isnumber(rnum)
            rnum = 1;
        else
            rnum = str2num(rnum);
        end
    else
        sname = pname(1:iext-1);
        rnum = 1;
    end
end
