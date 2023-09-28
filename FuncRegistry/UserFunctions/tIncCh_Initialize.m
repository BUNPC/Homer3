function tIncCh = tIncCh_Initialize(tIncCh, d, ml)
if isempty(tIncCh)
    tIncCh = [ones(size(d,1), size(ml,1)); ml'];
end

