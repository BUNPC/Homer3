function status = compareDcAvg(group_h2, dataTree, datatype)
global DEBUG1
DEBUG1=0;

status = 0;
if ~exist('datatype','var')
    datatype = 'dcAvg';
end

dataTreeFile = [dataTree.groups(1).path, dataTree.groups(1).outputDirname, dataTree.groups(1).outputFilename];

group_h3 = load(dataTreeFile);
if isempty(group_h3)
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare results: Here are the tests we must pass to get clean bill of health
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compare dcAvg
group_h3.group.Load();
if strcmp(datatype, 'dcAvg')
    yAvg_h2  = group_h2.group.procResult.dcAvg;    
    yAvg_h3  = group_h3.group.procStream.output.GetDcAvg('dcAvg');
elseif strcmp(datatype, 'dcAvgStd')
    yAvg_h2  = group_h2.group.procResult.dcAvgStd;
    yAvg_h3  = group_h3.group.procStream.output.GetDcAvg('dcAvgStd');
else
    status = -1;
    return
end

yAvg_erridxs = [];
idx=1;

% Use the assumed true values from homer2 to determine tolerance for error
if max(yAvg_h2(:))>min(yAvg_h2(:))
    prec = round(log10(  .001*(max(yAvg_h2(:))-min(yAvg_h2(:))) ));
else
    prec = 0;
end

if ndims(yAvg_h2)~=ndims(yAvg_h3) || ~all(size(yAvg_h2)==size(yAvg_h3))
    yAvg_erridxs(1)=-1;
else
    for ii=1:size(yAvg_h3,2)
        for jj=1:size(yAvg_h3,3)
            for kk=1:size(yAvg_h3,4)
                
                if ii>size(yAvg_h2,2) || jj>size(yAvg_h2,3) || kk>size(yAvg_h2,4)
                    status=1;
                    continue;
                end
                if ~isequal_prec(yAvg_h2(:,ii,jj,kk), yAvg_h3(:,ii,jj,kk), prec)
                    yAvg_erridxs(idx,:) = [ii,jj,kk];
                    idx=idx+1;
                    if DEBUG1
                        fprintf('Group: DC avg data for Hb type %d, Ch %d, Cond %d does not match\n', ii, jj, kk);
                        %compareOutputs_subjs(group_h2, group_h3, 'yAvg');
                    end
                    status=1;
                end
                
            end
        end
    end
end

if ~isempty(yAvg_erridxs)
    if yAvg_erridxs(1)<0
        ;
    elseif DEBUG1
        title = sprintf('Homer2 output: DC Avg, Cond %d', yAvg_erridxs(1,3));
        hf1 = figure('toolbar','none', 'menubar','none', 'name',title, 'numbertitle','off');
        p1 = get(hf1,'position');
        set(hf1, 'position', [p1(1)-(p1(1)*.6), p1(2), p1(3), p1(4)]);
        figure(hf1); hold on;
        for ii=1:size(yAvg_h2, 3)
            plot(yAvg_h2(:,1,ii,yAvg_erridxs(1,3)));
        end
        grid on;
        
        title = sprintf('Homer3 output: DC Avg, Cond %d', yAvg_erridxs(1,3));
        hf2 = figure('toolbar','none', 'menubar','none', 'name',title, 'numbertitle','off');
        p2 = get(hf2,'position');
        set(hf2, 'position', [p1(1)+(p1(1)*.6), p1(2), p1(3), p1(4)]);
        figure(hf2); hold on;
        for ii=1:size(yAvg_h3, 3)
            plot(yAvg_h3(:,1,ii,yAvg_erridxs(1,3)));
        end
        grid on;
    end
end

