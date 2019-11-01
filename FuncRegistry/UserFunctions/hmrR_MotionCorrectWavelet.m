% SYNTAX:
% data_dod = hmrR_MotionCorrectWavelet(data_dod, mlAct, iqr, turnon)
%
% UI NAME:
% Wavelet_Motion_Correction
%
% DESCRIPTION:
% Perform a wavelet transformation of the dod data and computes the
% distribution of the wavelet coefficients. It sets the coefficient
% exceeding iqr times the interquartile range to zero, because these are probably due
% to motion artifacts. set iqr<0 to skip this function.
% 
% The algorithm follows in part the procedure described by
% Molavi et al.,Physiol Meas, 33, 259-270 (2012).
%
% INPUTS:
% data_dod - SNIRF data structure data, containing delta_OD data
% mlAct - Cell array of vectors, one for each time base in data_dod, specifying 
%            active/inactive channels with 1 meaning active, 0 meaning inactive.
% iqr -      parameter used to compute the statistics (iqr = 1.5 is 1.5 times the
%            interquartile range and is usually used to detect outliers). 
%            Increasing it, it will delete fewer coefficients.
%            If iqr<0 then this function is skipped. 
% turnon -   Optional argument to enable/disable this function in a processing stream chain
%
% OUTPUTS:
% data_dod - SNIRF data structure containing modified delta_OD data
%            size as dod (Channels that are not in the active ml remain unchanged)
%
% USAGE OPTIONS:
% Wavelet_Motion_Correction:  dod = hmrR_MotionCorrectWavelet(dod, mlAct, iqr, turnon)
%
% PARAMETERS:
% iqr: 1.50
% turnon: 1
%
% LOG:
% Script by Behnam Molavi bmolavi@ece.ubc.ca adapted for Homer2 by RJC
% modified 10/17/2012 by S. Brigadoi
% modified 03/27/2019 by J. Dubb
%
function data_dod = hmrR_MotionCorrectWavelet(data_dod, mlAct, iqr, turnon)

if ~exist('turnon','var')
   turnon = 1;
end
if iqr<0
    return;
end
if turnon==0
    return;
end
if isempty(mlAct)
    mlAct = cell(length(data_dod),1);
end

for kk=1:length(data_dod)

    dod         = data_dod(kk).GetDataTimeSeries();
    dodWavelet  = dod;
    MeasList    = data_dod(kk).GetMeasList();   
    if isempty(mlAct{kk})
        mlAct{kk} = ones(size(MeasList,1),1);
    end
    MeasListAct = mlAct{kk};
    
    lstAct = find(MeasListAct==1);
    SignalLength = size(dod,1); % #time points of original signal
    N = ceil(log2(SignalLength)); % #of levels for the wavelet decomposition
    DataPadded = zeros(2^N,1); % data length should be power of 2
    p = ffpath2('db2.mat');
    fprintf('Loading %s\n', [p, '/db2.mat']);
    load([p, '/db2.mat']);  % Load a wavelet (db2 in this case)
    qmfilter = qmf(db2,4); % Quadrature mirror filter used for analysis
    L = 4;  % Lowest wavelet scale used in the analysis
    for ii = 1:length(lstAct)
        idx_ch = lstAct(ii);
        
        DataPadded(1:SignalLength) = dod(:,idx_ch);  % zeros pad data to have length of power of 2
        DataPadded(SignalLength+1:end) = 0;
        
        DCVal = mean(DataPadded);
        DataPadded = DataPadded-DCVal;    % removing mean value
        
        [yn, NormCoef] = NormalizationNoise(DataPadded',qmfilter);
        
        StatWT = WT_inv(yn,L,N,'db2'); % discrete wavelet transform shift invariant
        
        ARSignal = WaveletAnalysis(StatWT,L,'db2',iqr,SignalLength);  % Apply artifact removal
        ARSignal = ARSignal/NormCoef+DCVal;
        
        dodWavelet(:,idx_ch) = ARSignal(1:length(dod));
    end
    data_dod(kk).SetDataTimeSeries(dodWavelet);
    
end




% ---------------------------------------------------------------------

function pth = ffpath2(fname)
%   FFPATH    Find file path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function browses very fast current directory and directories known in 
% 'matlabpath' and the system variable 'path'. It searches for the file,
% name of which is in the input argument 'fname'. If a directory is found, 
% the output argument pth is filled by path to the file name from the input
% argument, otherwise pth is empty.
% File names should have their extensions, but MATLAB m-files.
% 
% Arguments:
%   fname   file name 
%   pth     path to the fname
%
% Examples:
%   pth = ffpath('gswin32c.exe')
%   pth =
%   c:\Program Files\gs\gs8.60\bin\
%
%   pth = ffpath('hgrc')
%   pth =
%   C:\PROGRA~1\MATLAB\R2006b\toolbox\local

% Miroslav Balda
% miroslav AT balda DOT cz
% 2008-12-15    v 0.1   only for system variable 'path'
% 2008-12-20    v 1.0   for both 'path' and 'matlabpath'

% Brought here by Jay Dubb. In order to keep hmrR_MotionCorrectWavelet
% self-contained, copied ffpath to here. 

if nargin<1
    error('The function requires one input argument (file name)')
end
pth = pwd;
if exist([pth '/' fname],'file')
    return
end % fname found in current dir

tp = matlabpath;
t  = 0;
if isunix() | ismac()
    I = [t, findstr(tp,':'), length(tp)+1];
elseif ispc()
    I = [t, findstr(tp,';'), length(tp)+1];
end    
for k = 1:length(I)-1               %   search in path's directories
    pth = tp(I(k)+1:I(k+1)-1);
    % fprintf('%s\n', [pth '/' fname]);
    if exist([pth '/' fname],'file')
        return;
    end
end
t = 5;
pth = '';

