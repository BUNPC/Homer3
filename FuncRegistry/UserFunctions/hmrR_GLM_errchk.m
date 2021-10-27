% PARAMETERS:
% trange: [-2.0, 20.0]
% glmSolveMethod: 1
% idxBasis: 1
% paramsBasis: [1.0 1.0 0.0 0.0 0.0 0.0], maxnum: 6
% rhoSD_ssThresh: 15.0
% flagNuisanceRMethod: 1
% driftOrder: 3
% c_vector: 0
function errmsg = hmrR_GLM_errchk(trange, glmSolveMethod, idxBasis, paramsBasis, rhoSD_ssThresh, flagNuisanceRMethod, driftOrder, c_vector)
    errmsg = '';
    % Define parameter error cases below and return an informative message
    if idxBasis > 4 || idxBasis < 1
       errmsg = 'Select a valid basis function (0-4)';
       return
    if length(trange) > 3 || length(trange) < 2
        errmsg = 'trange must have 2 or 3 values: [start, stop] or [start, stop, dt]';
        return
    elseif glmSolveMethod > 2 || glmSolveMethod < 1
       errmsg = 'Select a valid solve method (1-2)';
       return
    end
end