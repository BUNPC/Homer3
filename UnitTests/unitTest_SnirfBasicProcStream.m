function [data_dcAvg, data_dc, data_dod, snirf, procElem] = unitTest_SnirfBasicProcStream(filename)

% Syntax:
%   [data_dcAvg, data_dc, data_dod, snirf, procResult] = unitTest_SnirfBasicProcStream(filename)
%
% Example1:
%   cd([fileparts(which('Homer3.m')), '/UnitTests/Example9_SessRuns'])
%   filename = './Simple_Probe1_run04';
%   Nirs2Snirf([filename, '.nirs']);
%   [data_dcAvg, data_dc, data_dod, snirf, procResult] = unitTest_SnirfBasicProcStream([filename, '.snirf'])
%
% Example2:
%   cd([fileparts(which('Homer3.m')), '/UnitTests/Example6_GrpTap'])
%   filename = './subj1/Fingertapping_08192013';
%   Nirs2Snirf([filename, '.nirs']);
%   [data_dcAvg, data_dc, data_dod, snirf, procResult] = unitTest_SnirfBasicProcStream([filename, '.snirf'])
%

% Initialize output params
data_dcAvg = DataClass().empty();
data_dc    = DataClass().empty();
data_dod   = DataClass().empty();
snirf      = SnirfClass(filename);
procElem   = TreeNodeClass();


% Initial error check
if snirf.IsEmpty()
    fprintf('ERROR: Snirf container is empty() - file %s may not exist\n', filename);
    return;
end

% Process data through SNIRF-style procStream
data_dod = hmrR_Intensity2OD(snirf.data);
data_dod = hmrR_BandpassFilt(data_dod, .01, .5);
data_dc = hmrR_OD2Conc(data_dod, snirf.probe, [6,6]);
[data_dcAvg, data_dcAvgStd, nTrials, data_dcSum2] = hmrR_BlockAvg(data_dc, snirf.stim, [-2.0, 20.0]);


linecolor = rand(20,3);

% Plot SNIRF data directly. Plot channels with dataTypeLabel=HbO and condition=1 and 
% for channels with sourceIndex==1
figure; hold on
d             = data_dcAvg.GetDataTimeSeries();
t             = data_dcAvg.GetTime();
dataTypeLabel = data_dcAvg.GetDataTypeLabel();
condition     = data_dcAvg.GetCondition();
srcdetpairs   = data_dcAvg.GetMeasList();
for ii=1:size(d,2) 
    if dataTypeLabel(ii)==6 && condition(ii)==1 && srcdetpairs(ii,1)==1
        plot(t, d(:,ii), 'color',linecolor(ii,:), 'linewidth',2);
    end
end
hold off


% Test TreeNodeClass procElem methods for retrieving and plotting data from SNIRF data
procElem.procStream.output.SetTHRF(data_dcAvg.GetTime());
procElem.procStream.output.SetNtrials(nTrials);
procElem.procStream.output.SetDc(data_dc);
procElem.procStream.output.SetDcAvg(data_dcAvg);
procElem.procStream.output.SetDcAvgStd(data_dcAvgStd);
procElem.procStream.output.SetDcSum2(data_dcSum2);

d         = procElem.GetDcAvg();
dStd      = procElem.GetDcAvgStd();
t         = procElem.GetTHRF();
nTrials   = procElem.GetNtrials();
condition = 1;
hbType    = 1;
ch        = [1,2];
chLst     = [1,2];
d         = d(:,:,:,condition);

figure; hold on
DisplayDataConc(t, d, [], hbType, ch, chLst, nTrials, condition, linecolor);
hold off

figure; hold on
DisplayDataConc(t, d, dStd, hbType, ch, chLst, nTrials, condition, linecolor);
hold off

