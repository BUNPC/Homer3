% SYNTAX:
% data_dod = hmrR_MotionCorrectTDDR(data_dod, mlActAuto, mlActMan)
%
% UI NAME:
% Motion_Correct_TDDR
%
% DESCRIPTION:
% Corrects motion artifacts by computing the temporal derivative of the dod signal, 
% applying robust regression to reduce magnitude of outlying fluctuations, then 
% integrating to get the corrected signal. This function follows the procedure described in:
% Fishburn, F. A. et al. (2019). Temporal Derivative Distribution Repair (TDDR): A motion correction method for fNIRS. NeuroImage, 184, 171-179.
%
%
% INPUTS:
% data_dod: SNIRF data structure containing delta_OD 
% mlActAuto:
% mlActMan:
%
% OUTPUTS:
% data_dod:   SNIRF data structure containing delta_OD after motion correction, 
%        same size as dod (Channels that are not in the active ml remain unchanged)
%
% USAGE OPTIONS:
% Motion_Correct_TDDR: dod = hmrR_MotionCorrectTDDR(dod, mlActAuto, mlActMan)
%
% PARAMETERS:
%
% PREREQUISITES:
% Intensity_to_Delta_OD: dod = hmrR_Intensity2OD( intensity )
% 
% LOG:
% Script by Frank Fishburn (fishburnf@upmc.edu) 10/03/2018
% Modified by Giulia Rocco (giulia.rocco@i3s.unice.fr) 20/02/2023

function data_dod = hmrR_MotionCorrectTDDR(data_dod, mlActAuto, mlActMan)

% mlAct = SD.MeasListAct; % prune bad channels
t = data_dod.time;
sample_rate = abs(1/(t(1)-t(2)));

if isempty(mlActMan)
    mlActMan = cell(length(data_dod),1);
end
if isempty(mlActAuto)
    mlActAuto = cell(length(data_dod),1);
end

for kk = 1:length(data_dod)
    
    dod         = data_dod(kk).GetDataTimeSeries();
    MeasList    = data_dod(kk).GetMeasList();  
    
    if isempty(mlActMan{kk})
        mlActMan{kk} = ones(size(MeasList,1),1);
    end
    if isempty(mlActAuto{kk})
        mlActAuto{kk} = ones(size(MeasList,1),1);
    end
    
    MeasListAct = mlActMan{kk} & mlActAuto{kk};
    
    lstAct = find(MeasListAct==1);

    for ii=1:length(lstAct)

        idx_ch = lstAct(ii);

        %% Preprocess: Separate high and low frequencies
        filter_cutoff = .5;
        filter_order = 3;
        Fc = filter_cutoff * 2/sample_rate;
        if Fc<1
            [fb,fa] = butter(filter_order,Fc);
            signal_low = filtfilt(fb,fa,dod(:,idx_ch));
        else
            signal_low = dod(:,idx_ch);
        end
        signal_high = dod(:,idx_ch) - signal_low;

        %% Initialize
        tune = 4.685;
        D = sqrt(eps(class(dod)));
        mu = inf;
        iter = 0;

        %% Step 1. Compute temporal derivative of the signal
        deriv = diff(signal_low);

        %% Step 2. Initialize observation weights
        w = ones(size(deriv));

        %% Step 3. Iterative estimation of robust weights
        while iter < 50

            iter = iter + 1;
            mu0 = mu;

            % Step 3a. Estimate weighted mean
            mu = sum( w .* deriv ) / sum( w );

            % Step 3b. Calculate absolute residuals of estimate
            dev = abs(deriv - mu);

            % Step 3c. Robust estimate of standard deviation of the residuals
            sigma = 1.4826 * median(dev);

            % Step 3d. Scale deviations by standard deviation and tuning parameter
            r = dev / (sigma * tune);

            % Step 3e. Calculate new weights accoring to Tukey's biweight function
            w = ((1 - r.^2) .* (r < 1)) .^ 2;

            % Step 3f. Terminate if new estimate is within machine-precision of old estimate
            if abs(mu-mu0) < D*max(abs(mu),abs(mu0))
                break;
            end

        end

        %% Step 4. Apply robust weights to centered derivative
        new_deriv = w .* (deriv-mu);

        %% Step 5. Integrate corrected derivative
        signal_low_corrected = cumsum([0; new_deriv]);

        %% Postprocess: Center the corrected signal
        signal_low_corrected = signal_low_corrected - mean(signal_low_corrected);

        %% Postprocess: Merge back with uncorrected high frequency component
        dod(:,idx_ch) = signal_low_corrected + signal_high;

    end
    
    data_dod(kk).SetDataTimeSeries(dod);
end

end
