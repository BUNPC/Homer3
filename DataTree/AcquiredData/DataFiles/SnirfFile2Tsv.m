function tsv = SnirfFile2Tsv(src, dst, options)
tsv = {};

% Parse args
if nargin==0
    return
end
if ~isa(src, 'SnirfClass')
    s = SnirfClass(src);
else
    s = src;
end
if s.IsEmpty()
    s.LoadStim(s.GetFilename());
end
if ~exist('dst','var')
    dst = '';
end

if isempty(dst)
    dst = s.GetStimTsvFilename();
end
if ~exist('options','var')
    options = '';
end
if isempty(s.stim)
    s0 = StimClass();
else
    s0 = s.stim(1);
end
tsv = [s0.dataLabels(:)', 'trial_type'];
data = [];
for ii = 1:length(s.stim)
    iS = size(tsv,1)+1;
    iE = size(tsv,1)+size(s.stim(ii).data,1);
    tsv(iS:iE,:) = [num2cell(s.stim(ii).data), repmat({s.stim(ii).name}, size(s.stim(ii).data,1),1)]; %#ok<*AGROW>
    data = [data; s.stim(ii).data];
end
if ~isempty(data)
    [~, order] = sortrows(data,1);
    tsv(2:end,:) = tsv(order+1,:);
end
if ispathvalid(dst)
    if optionExists(options, 'regenerate')
        writeTsv(dst, tsv);
    end
else
    writeTsv(dst, tsv);
end


