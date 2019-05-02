% SYNTAX:
% data_dod = hmrR_MotionCorrectSpline(data_dod, mlAct, tIncCh, p, turnon)
%
% UI NAME:
% Spline_Motion_Correction
%
% DESCRIPTION:
% Perform a cubic spline correction of the motion artifacts identified in
% tIncCh. The algorithm follows the procedure describe by
% Scholkmann et al., Physiol. Meas. 31, 649-662 (2010). Set p = -1 to skip
% this function.
%
% INPUTS:
% data_dod: SNIRF data structure containing delta_OD 
% mlAct:
% tIncCh:   Matrix of included time points (1=included; 0=not included (movement)
%           The matrix is #time points x #channels and usually comes from
%           hmrR_MotionArtifactByChannel()
% p:        Parameter p used in the spline interpolation. The value
%           recommended in the literature is 0.99. Use -1 if you want to skip this
%           motion correction.
% turnon:   Optional argument to enable/disable this function in a processing stream chain
%
% OUTPUTS:
% dod:   SNIRF data structure containing delta_OD after spline interpolation correction, 
%        same size as dod (Channels that are not in the active ml remain unchanged)
%
% USAGE OPTIONS:
% Spline_Motion_Correction: dod = hmrR_MotionCorrectSpline(dod, mlActAuto, tIncAutoCh, p, turnon)
%
% PARAMETERS:
% p: 0.99
% turnon: 1
%
% 
% LOG:
% created 01-26-2012, J. Selb
% modified 03/27/2019 by J. Dubb
%
% TO DO:
%
function data_dod = hmrR_MotionCorrectSpline(data_dod, mlAct, tIncCh, p, turnon)

if ~exist('turnon','var')
    turnon = 1;
end
if turnon==0
    return;
end

% Check input args
if isempty(mlAct)
    mlAct = cell(length(data_dod),1);
end
if isempty(tIncCh)
    tIncCh = cell(length(data_dod),1);
end
if p>1 || p<0    % if p outside its authorized range, exit with warning
    display('Parameter has to be between 0 and 1. Returning with no correction');
    return;
end

for iBlk=1:length(data_dod)
    
    dod         = data_dod(iBlk).GetDataTimeSeries();
    t           = data_dod(iBlk).GetTime();
    MeasList    = data_dod(iBlk).GetMeasList();
    if isempty(mlAct{iBlk})
        mlAct{iBlk} = ones(size(MeasList,1),1);
    end
    MeasListAct = mlAct{iBlk};
    if isempty(tIncCh{iBlk})
        tIncCh{iBlk} = ones(size(dod,1),1);
    end
    
    lstAct = find(MeasListAct==1);
    
    fs = 1/mean(t(2:end)-t(1:end-1));
    
    % window widths limits for computing the mean in the segment shifts
    dtShort = 0.3;  % seconds
    dtLong  = 3;    % seconds
            
    lstAct = find(MeasListAct==1);
    dodSpline = dod;
    t = t(:);  % needs to be a column vector
    
    for ii = 1:length(lstAct)
        
        idx_ch = lstAct(ii);
        
        lstMA = find(tIncCh{iBlk}(:,idx_ch)==0);   % sublist of motion artifact segments
        
        if ~isempty(lstMA)
            
            % Find indexes of starts and ends of MA segments
            lstMs = find(diff(tIncCh{iBlk}(:,idx_ch))==-1);   % starting indexes of mvt segments
            lstMf = find(diff(tIncCh{iBlk}(:,idx_ch))==1);    % ending indexes of mvt segments
            
            % Case where there's a single MA segment, that either starts at the
            % beginning or ends at the end of the total time duration
            if isempty(lstMf)
                lstMf = size(tIncCh{iBlk},1);
            end
            if isempty(lstMs)
                lstMs = 1;
            end
            % If any MA segment either starts at the beginning or
            % ends at the end of the total time duration
            if lstMs(1)>lstMf(1)
                lstMs = [1;lstMs];
            end
            if lstMs(end)>lstMf(end)
                lstMf(end+1,1) = size(tIncCh{iBlk},1);
            end
            
            lstMl = lstMf-lstMs;    % lengths of MA segments
            nbMA = length(lstMl);   % number of MA segments
            
            % Do the spline interpolation on each MA segment
            % only include channels in the active meas list
            
            for jj = 1:nbMA
                lst = lstMs(jj):(lstMf(jj)-1);
                % spline interp
                SplInterp = csaps(t(lst)', dod(lst,idx_ch)', p, t(lst)')';
                % corrected signal = original signal - spline interpolation
                dodSpline(lst,idx_ch) = dod(lst,idx_ch) - SplInterp;
            end
            
            
            % Reconstruction of the whole time series (shift each segment)
            
            % First MA segment: shift to the previous noMA segment if it exists,
            % to the next noMA segment otherwise
            lst = (lstMs(1)):(lstMf(1)-1);
            SegCurrLength = lstMl(1);
            if SegCurrLength < dtShort*fs
                windCurr = SegCurrLength;
            elseif SegCurrLength < dtLong*fs
                windCurr = floor(dtShort*fs);
            else
                windCurr = floor(SegCurrLength/10);
            end
            
            if lstMs(1)>1
                SegPrevLength = length(1:(lstMs(1)-1));
                if SegPrevLength < dtShort*fs
                    windPrev = SegPrevLength;
                elseif SegPrevLength < dtLong*fs
                    windPrev = floor(dtShort*fs);
                else
                    windPrev = floor(SegPrevLength/10);
                end
                meanPrev = mean(dodSpline(lst(1)-windPrev:(lst(1)-1), idx_ch));
                meanCurr = mean(dodSpline(lst(1):(lst(1)+windCurr-1), idx_ch));
                dodSpline(lst,idx_ch) = dodSpline(lst,idx_ch) - meanCurr + meanPrev;
                
            else
                if length(lstMs)>1
                    SegNextLength = length(lstMf(1):(lstMs(2)));
                else
                    SegNextLength = length(lstMf(1):size(tIncCh{iBlk},1));
                end
                if SegNextLength < dtShort*fs
                    windNext = SegNextLength;
                elseif SegNextLength < dtLong*fs
                    windNext = floor(dtShort*fs);
                else
                    windNext = floor(SegNextLength/10);
                end
                meanCurr = mean(dodSpline((lst(end)-windCurr):(lst(end)-1),  idx_ch));
                meanNext = mean(dodSpline((lst(end)+1):(lst(end)+windNext), idx_ch));
                dodSpline(lst,idx_ch) = dodSpline(lst,idx_ch) - meanCurr + meanNext;
            end
            
            
            % Intermediate segments
            for kk=1:(nbMA-1)
                % no motion
                lst = lstMf(kk):(lstMs(kk+1)-1);
                SegPrevLength = lstMl(kk);
                SegCurrLength = length(lst);
                if SegPrevLength < dtShort*fs
                    windPrev = SegPrevLength;
                elseif SegPrevLength < dtLong*fs
                    windPrev = floor(dtShort*fs);
                else
                    windPrev = floor(SegPrevLength/10);
                end
                if SegCurrLength < dtShort*fs
                    windCurr = SegCurrLength;
                elseif SegCurrLength < dtLong*fs
                    windCurr = floor(dtShort*fs);
                else
                    windCurr = floor(SegCurrLength/10);
                end
                meanPrev = mean(dodSpline((lst(1)-windPrev):(lst(1)-1), idx_ch));
                meanCurr = mean(dod(lst(1):(lst(1)+windCurr-1), idx_ch));
                
                dodSpline(lst,idx_ch) = dod(lst,idx_ch) - meanCurr + meanPrev;
                
                % motion
                lst = (lstMs(kk+1)):(lstMf(kk+1)-1);
                SegPrevLength = SegCurrLength;
                SegCurrLength = lstMl(kk+1);
                if SegPrevLength < dtShort*fs
                    windPrev = SegPrevLength;
                elseif SegPrevLength < dtLong*fs
                    windPrev = floor(dtShort*fs);
                else
                    windPrev = floor(SegPrevLength/10);
                end
                if SegCurrLength < dtShort*fs
                    windCurr = SegCurrLength;
                elseif SegCurrLength < dtLong*fs
                    windCurr = floor(dtShort*fs);
                else
                    windCurr = floor(SegCurrLength/10);
                end
                meanPrev = mean(dodSpline((lst(1)-windPrev):(lst(1)-1), idx_ch));
                meanCurr = mean(dodSpline(lst(1):(lst(1)+windCurr-1), idx_ch));
                
                dodSpline(lst,idx_ch) = dodSpline(lst,idx_ch) - meanCurr + meanPrev;
            end
            
            % Last not MA segment
            if lstMf(end)<length(t)
                lst = (lstMf(end)-1):length(t);
                SegPrevLength = lstMl(end);
                SegCurrLength = length(lst);
                if SegPrevLength < dtShort*fs
                    windPrev = SegPrevLength;
                elseif SegPrevLength < dtLong*fs
                    windPrev = floor(dtShort*fs);
                else
                    windPrev = floor(SegPrevLength/10);
                end
                if SegCurrLength < dtShort*fs
                    windCurr = SegCurrLength;
                elseif SegCurrLength < dtLong*fs
                    windCurr = floor(dtShort*fs);
                else
                    windCurr = floor(SegCurrLength/10);
                end
                meanPrev = mean(dodSpline((lst(1)-windPrev):(lst(1)-1), idx_ch));
                meanCurr = mean(dod(lst(1):(lst(1)+windCurr-1), idx_ch));
                
                dodSpline(lst,idx_ch) = dod(lst,idx_ch) - meanCurr + meanPrev;
            end
            
            %else
            %   dodSpline(:,i_ch) = dod;
        end
    end
    data_dod(iBlk).SetDataTimeSeries(dodSpline);
end
