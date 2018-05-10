% function dodKWavelet = hmrMotionCorrectKurtosisWavelet(dod,SD,kurt)
%
% UI NAME:
% Wavelet_Motion_Correction
%
% Performs a wavelet transformation of the dod data and computes the
% distribution of the wavelet coefficients. It iteratively eliminates the
% biggest (as absolute value) wavelet coefficient until the kurtosis (the
% kurt parameter), of the wavelet coefficients is below a certain
% threshold. It does so for each level of the wavelet decomposition.
% 
% The algorithm follows the procedure described by
% Chiarelli, A. M. et al. (2015). A kurtosis-based wavelet algorithm for motion artifact correction of fNIRS data. Neuroimage, 112, 128-137.
%
% INPUTS:
% dod:   delta_OD 
% SD:    SD structure
% kurt    kurtosis threshold of the wavelet coefficients.
%         the kurtosis level is selected to test the gaussianity of the wavelet coefficients.
%         lower level of the kurtosis reflects in stricter gaussianity
%         assumption about the signal. Kurtosis needs to me strictly above
%         3
%        If kurt<=3 then this function is skipped.
%        SUGGESTED KURTOSIS LEVEL: 3.3
% 
%
% OUTPUTS:
% dodKWavelet:  dod after wavelet motion correction, same
%              size as dod (Channels that are not in the active ml remain unchanged)
%
% LOG:
% Script by Antonio Maria Chiarelli chiarell@illinois.edu adapted for Homer2 by
% Antonio Maria Chiarelli the 10/18/2016
%


function [dodKWavelet] = hmrMotionCorrectKurtosisWavelet(dod,SD,kurt)

if kurt<=3
    dodKWavelet = dod;
    return;
end

mlAct = SD.MeasListAct; % prune bad channels

lstAct = find(mlAct==1);
dodKWavelet = dod;

minlvl=4;  % minimum decomposition level 
qmf = MakeONFilter('Daubechies',12);    % db6 wavelet (db6 wavelet provided best results during simulations)


for ii=1:length(lstAct)   %%% apply for all the good channels
    idx_ch = lstAct(ii);
    
    L=nextpow2(size(dod,1));
    y=zeros(2^L,1);                             %data zero padding 
    y(1:size(dod,1))=dod(:,idx_ch);
    wc = FWT_PO(y,1,qmf);                       % DWT
    wck=wc;
    for i=minlvl:L-1                             % apply algorithm from level 'minlvl' to end -1 (-1 for sampling purposes)
        
        values=wc(2^i+1:2^(i+1));
        valuesk=values;
        valuesk(values==0)=[];
        KURT=kurtosis(valuesk);                 % estimate kurtosis of the coefficient distribution
        
        while KURT>kurt && isempty(KURT)==0      % set to zero the highest coefficient until kurtosis is above threshold or not defined
            values(abs(values)==max(abs(values)))=0;
            valuesk=values;
            valuesk(values==0)=[];
            KURT=kurtosis(valuesk);
        end
        
        wck(2^i+1:2^(i+1)) =values;
    end
    xc1 = IWT_PO(wck,1,qmf);                        % apply IDWT
    dodKWavelet(:,idx_ch)=xc1(1:size(dod,1));
    
end





 