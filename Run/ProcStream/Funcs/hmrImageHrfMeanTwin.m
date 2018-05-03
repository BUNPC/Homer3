function yavgimg = hmrImageHrfMeanTwin( yavg, tHRF, trange )

lst = find( tHRF>=trange(1) & tHRF<=trange(2) );

% return yavgimg in format of meas, conc, cond

if ndims(yavg)==4 % This is concentration with conditions
    yavgimg = squeeze(mean(yavg(lst,:,:,:),1));
elseif ndims(yavg)==3 % this is ambiguous, dod with conditions, or conc without conditions
    yavgimg = squeeze(mean(yavg(lst,:,:),1));
    % if size(yavgimg,1)==3 then assume this is conc. A problem if it is
    % really dod with only 3 meas, but that is unlikely for imaging
    if size(yavgimg,1)==3
        yavgimg = permute(yavgimg,[2 1]);
    end
elseif ndims(yavg)==2 % this is dod without conditions
    yavgimg = squeeze(mean(yavg(lst,:),1))';
end    
