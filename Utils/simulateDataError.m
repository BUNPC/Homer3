function d = simulateDataError(d)
global ERROR_ODDS_CONST
global logger

logger = InitLogger(logger);

if nargin == 0
    d = [];
    return
end
if isempty(d)
    return
end
if isempty(ERROR_ODDS_CONST)
    return
end
if ERROR_ODDS_CONST == 0
    return
end

% Set error odds in percent units
r = round(ERROR_ODDS_CONST*rand()); 
if r==1
    percentErrs = 7;
    n = length(d(:,1));
    idxs = floor(n * rand(1, uint32((n*percentErrs)/100)));
    k = find(idxs==0);
    idxs(k) = 1;
    d0 = d;
    d(idxs,1) = d(idxs,1) + d(idxs,1).*rand(length(idxs),1);
    logger.Write('\n**** Simulated %d errors:    d(%d,1) orig:  %0.4g,  d(%d,1) new:  %0.4g,  error size = %0.4g ****\n\n',  ...
          length(idxs), idxs(1), d0(idxs(1),1), idxs(1), d(idxs(1),1), abs(d0(idxs(1),1)-d(idxs(1),1)));
end

