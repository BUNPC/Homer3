function snirf = TsvFile2Snirf(src, dst, option)
snirf = SnirfClass();

% Parse args
if nargin==0
    return
end
if ~exist('dst','var')
    dst = '';
end
if ~exist('option','var')
    option = 'nofile';
end

if ischar(src)
    tsv = readTsv(src);
else
    tsv = src;
    src = '';
end
if isempty(tsv)
    return;
end

if isempty(dst) && ispathvalid(src)
    [pname, fname] = fileparts(src);
    k = strfind(fname, '_events');
    if isempty(k)
        k = length(fname)+1;
    end
    dst = [filesepStandard(pname), fname(1:k-1), '_nirs.snirf'];
end

snirf.SetFilename(dst);

fields = tsv(1,:);
k = find(strcmp(fields, 'trial_type'));
if isempty(k)
    return
end
for ii = 2:size(tsv,1)
    jj = findStim(snirf.stim, tsv{ii,k});
    if jj == 0
        snirf.stim(end+1) = StimClass(tsv([1,ii],:));
    else
        snirf.stim(jj).AddTsvData(tsv([1,ii],:));
    end
end
if strcmp(option,'nofile')
    return
end
snirf.Save();


% -----------------------------------------------------------
function jj = findStim(stim, tsv)
jj = 0;
for ii = 1:length(stim)
    if isnumeric(tsv)
        tsv = num2str(tsv);
    end
    if strcmp(stim(ii).name, tsv)
        jj = ii;
        break;
    end
end


