% function dodSpline = hmrR_MotionCorrectSpline_Nirs(dod, t, SD, tInc, p)
%
% UI NAME:
% Spline_Motion_Correction
%
% dodSpline = hmrR_MotionCorrectSpline_Nirs(dod, t, SD, tInc, p)
% Perform a cubic spline correction of the motion artifacts identified in
% tInc. The algorithm follows the procedure describe by
% Scholkmann et al., Physiol. Meas. 31, 649-662 (2010). Set p = -1 to skip
% this function.
%
% INPUTS:
% dod:   delta_OD
% t:     time vector
% SD:    SD structure
% tInc:  Matrix of included time points (1=included; 0=not included (movement)
%        The matrix is #time points x #channels and usually comes from
%        hmrMotionArtifactByChannel()
% p:     Parameter p used in the spline interpolation. The value
%        recommended in the literature is 0.99. Use -1 if you want to skip this
%        motion correction.
%
% OUTPUTS:
% dodSpline:  dod after spline interpolation correction, same size as dod
%            (Channels that are not in the active ml remain unchanged)
%
% LOG:
% created 01-26-2012, J. Selb
%
% TO DO:
%

function dodSpline = hmrR_MotionCorrectSpline_Nirs(dod, t, SD, tInc, p, turnon)

if exist('turnon')
   if turnon==0
       dodSpline = dod;
   return;
   end
end

% if p outside its authorized range, set to 0.99
if p>1 || p<0
    display('Parameter has to be between 0 and 1. Returning with no correction');
    dodSpline = dod;
    return;
end

fs = 1/mean(t(2:end)-t(1:end-1));

% window widths limits for computing the mean in the segment shifts
dtShort = 0.3;  % seconds
dtLong  = 3;    % seconds

ml = SD.MeasList;
mlAct = SD.MeasListAct; % prune bad channels

lstAct = find(mlAct==1);
dodSpline = dod;
t = t(:);  % needs to be a column vector

for ii = 1:length(lstAct)
    
    idx_ch = lstAct(ii);
    
    lstMA = find(tInc(:,idx_ch)==0);   % sublist of motion artifact segments
    
    if ~isempty(lstMA)
        
        % Find indexes of starts and ends of MA segments
        lstMs = find(diff(tInc(:,idx_ch))==-1);   % starting indexes of mvt segments
        lstMf = find(diff(tInc(:,idx_ch))==1);    % ending indexes of mvt segments
        
        % Case where there's a single MA segment, that either starts at the
        % beginning or ends at the end of the total time duration
        if isempty(lstMf)
            lstMf = size(tInc,1);
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
            lstMf(end+1,1) = size(tInc,1);
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
        
        %% First MA segment: shift to the previous noMA segment if it exists,
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
                SegNextLength = length(lstMf(1):size(tInc,1));
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
        
        
        %% Intermediate segments
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
        
        %% Last not MA segment
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


