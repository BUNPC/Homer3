function lpfs = getHomer2LpfValue(files)

lpfs = zeros(1,length(files))-1;
for ii=1:length(files)
    [~,fname] = fileparts(files(ii).name);
    fname(fname=='_')='.';
    k = strfind(fname,'lpf.');
    if isempty(k)
        continue;
    end
    lpfstr = fname(k+length('lpf.'):end);
    if isempty(lpfstr)
        continue;
    end
    if ~isnumber(lpfstr)
        continue;
    end
    lpfs(ii) = str2num(lpfstr);
end

