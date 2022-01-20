function [b,idxs]  = strcellfind(strs, s)

b = false;

r = strfind(strs, s);

idxs=[];
kk=1;
for ii=1:length(r)
    if ~isempty(r{ii})
        b = true;
        idxs(kk) = ii;
        kk=kk+1;
    end
end

