function DisplayDataConc(hAxes, t, d, dStd, hbType, ch, nTrials, condition, linecolor, linestyle)

% Parse args
if ~exist('t','var')
    t = [];
end
if ~exist('d','var')
    d = [];
end
if ~exist('dStd','var')
    dStd = [];
end
if ~exist('hbType','var')
    hbType = 1;
end
if ~exist('ch','var')
    ch = 1;
end
if ~exist('nTrials','var')
    nTrials = [];
end
if ~exist('condition','var')
    condition = 1;
end
if ~exist('linecolor','var')
    linecolor = rand(length(ch),3);
end
if ~exist('linestyle','var')
    linestyle = {'-','--',':'};
end
linewidth = [2,2,2.5];

% Error check args
if isempty(t) || isempty(d) || isempty(hbType) || isempty(ch)
    return;
end
if ~isempty(dStd) && (isempty(nTrials) || isempty(condition))
    return;
end

for iHb=1:size(hbType, 2)
    chLstHb = ch(hbType(:, iHb));
    for i = 1:length(chLstHb)
        dHbMl = d(:,  chLstHb(i));
        h     = plot(hAxes, t, dHbMl);
        
        % fprintf('Plotting channel: %d, color: [%0.1f, %0.1f, %0.1f]\n', ch(ii), linecolor(chLst(ii),:));
        set(h, 'color', linecolor(i, :));
        set(h, 'linewidth', linewidth(iHb));
        set(h, 'linestyle', linestyle{iHb});
        
        if ~isempty(dStd)
            dHbMlStd    = dStd(:, chLstHb(i));
%             dHbMlStdErr = dHbMlStd./sqrt(nTrials(condition));
            idx         = [1:10:length(t)];
            h2          = errorbar(hAxes, t(idx), dHbMl(idx), dHbMlStd(idx),'.');
            set(h2,'color',linecolor(i, :));
        end
    end
end

