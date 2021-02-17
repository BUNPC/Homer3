% PARAMETERS:
% trange: [-2.0, 20.0]
% glmSolveMethod: 1
% idxBasis: 2
% paramsBasis: [0.1 3.0 10.0 1.8 3.0 10.0], maxnum: 6
% rhoSD_ssThresh: 15.0
% flagNuisanceRMethod: 1
% driftOrder: 3
function errmsg = hmrR_GLM_errchk(trange, glmSolveMethod, idxBasis, paramsBasis, rhoSD_ssThresh, flagNuisanceRMethod, driftOrder)
    errmsg = '';
    % Define parameter error cases below and return an informative message
    if idxBasis > 4 || idxBasis < 1
       errmsg = 'Select a valid basis function (0-4)';
       return
    elseif glmSolveMethod > 2 || glmSolveMethod < 1
       errmsg = 'Select a valid solve method (1-2)'
       return
    end
end