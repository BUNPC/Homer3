function [data_dcAvg, data_dc, data_dod, snirf] = unitTest_SnirfBasicProcStream(filename)

% Example:
%
%   unitTest_SnirfBasicProcStream('./Simple_Probe1_run04.snirf');
%   [data_dcAvg, data_dc, data_dod, snirf] = unitTest_SnirfBasicProcStream('./Simple_Probe1_run04.snirf')
%

snirf = SnirfClass(filename);
data_dod = hmrR_Intensity2OD(snirf.data);
data_dod = hmrR_BandpassFilt(data_dod, .01, .5);
data_dc = hmrR_OD2Conc(data_dod, snirf.sd, [6,6]);
[data_dcAvg, data_dcAvgStd, nTrials, data_dcSum2] = hmrR_BlockAvg( data_dc, snirf.stim, [-2.0, 20.0]);

% Plot channels with dataTypeLabel=HbO and condition=1
figure; hold on

d             = data_dcAvg.GetD();
t             = data_dcAvg.GetT();
dataTypeLabel = data_dcAvg.GetDataTypeLabel();
condition     = data_dcAvg.GetCondition();
for ii=1:size(d,2) 
    if dataTypeLabel(ii)==6 && condition(ii)==1
        plot(t, d(:,ii));
    end
end

