function crit = infocrit( LogL , num_obs , num_param , criterion )
% Calculate information criterion from Log-Likelihood (BIC, AIC, AICc, CAIC, MAX)
% crit = infocrit( LogL , num_obs , num_param , criterion )
if nargin<4
    criterion = 'BIC';
end

switch upper(criterion)
    case 'BIC'
        crit = -2*LogL + num_param .* log(num_obs);
    case 'AIC'
        crit = -2*LogL + 2*num_param;
    case 'AICC'
        crit = -2*LogL + 2*num_param + 2*num_param.*(num_param+1)./(num_obs-num_param-1);
        crit((num_obs-num_param-1) <= 0) = nan;
    case 'CAIC'
        crit = -2*LogL + num_param .* (1+log(num_obs));
    otherwise
        error('Unknown model selection criterion: %s',criterion);
end
end