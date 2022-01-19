% SnirfSave( filenm, snirf )
%
% This function will save a snirf object to file 'filenm'.
% Recall that you create a snirf object with
%   snirf = SnirfClass();
% and then populate it with the required fields indicated by the SNIRF
% specification.

function SnirfSave( filenm, snirf )

snirf.Save( filenm )

