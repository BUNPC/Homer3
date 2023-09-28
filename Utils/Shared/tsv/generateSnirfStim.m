function [s, interval, idxs] = generateSnirfStim(obj, CondNames, nStim)
if ischar(obj)
    s = SnirfClass(obj);
    s.stim = StimClass.empty();
end
if ~exist('CondNames','var')
    CondNames = {1};
end
if ~exist('nStim','var')
    nStim = zeros(length(CondNames),1);
end
if length(nStim) < length(CondNames)
    nStim = repmat(nStim, 1, length(CondNames));
end

fprintf('\n');
n = length(s.data(1).time);
[~, k] = nearest_point(s.data(1).time, 10);
for iC = 1:length(CondNames)
    s.stim(iC) = StimClass(CondNames{iC});
    if nStim == 0
        continue;
    end
    interval = round(n/nStim(iC) + 10*rand());
    c = round(n/(30*rand())*rand());
    offset = k+c;
    fprintf('Cond %s offset: %d, t=%0.2f\n', CondNames{iC}, offset, s.data(1).time(offset))
    idxs = offset:interval:length(s.data(1).time);
    s.stim(iC).data = [s.data(1).time(idxs), 5*ones(length(idxs),1), ones(length(idxs),1)];
end
fprintf('\n');
s.Save();

