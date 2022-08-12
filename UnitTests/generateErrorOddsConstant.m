function [k, nErrs] = generateErrorOddsConstant(oddsDesired, nTrials)
if nargin == 0
    oddsDesired = 10;
    nTrials = 1000;
end
if nargin == 1
    nTrials = 1000;
end

% We want to calculate k that is the number to multiply rand() by to
% achieve desired odds. This seems to be a good fomula for 
% approximating the odds for all of the various oddsDesired.
if oddsDesired == 0
    c = 0;
elseif oddsDesired < 5
    c = .02;
elseif oddsDesired > 50
    c = .3;
else
    c = .24/oddsDesired;
end
k = oddsDesired/100 + .43 + c;
nErrs = 0;
for ii = 1:nTrials
    r = round(k*rand()); 
    if r==1
        %fprintf('%d. Error!!\n', ii); 
        nErrs = nErrs+1; 
    else
        %fprintf('%d\n', ii); 
    end
    % pause(.01); 
end
fprintf('\nTotal number of errors: %d  ==>  %0.1f%%\n\n', nErrs, 100 * nErrs / nTrials);

