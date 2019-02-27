function status = compareOutputs1(group_h2)
global DEBUG1
DEBUG1=0;

status = 0;
group_h3 = load('./groupResults.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare results: Here are the tests we must pass to get clean bill of health
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compare dcAvg
dcAvg_h2  = group_h2.group.procResult.dcAvg;
dcAvg_h3  = group_h3.group.procStream.output.GetDcAvg();
dcAvg_erridxs = [];
idx=1;

% Use the assumed true values from homer2 to determine tolerance for error
if max(dcAvg_h2(:))>min(dcAvg_h2(:))
    prec = int32(log10(  .001*(max(dcAvg_h2(:))-min(dcAvg_h2(:))) ));
else
    prec = 0;
end

if ndims(dcAvg_h2)~=ndims(dcAvg_h3) || ~all(size(dcAvg_h2)==size(dcAvg_h3))
    dcAvg_erridxs(1)=-1;
else
    for ii=1:size(dcAvg_h3,2)
        for jj=1:size(dcAvg_h3,3)
            for kk=1:size(dcAvg_h3,4)
                
                if ii>size(dcAvg_h2,2) || jj>size(dcAvg_h2,3) || kk>size(dcAvg_h2,4)
                    status=1;
                    continue;
                end
                if ~isequal_prec(dcAvg_h2(:,ii,jj,kk), dcAvg_h3(:,ii,jj,kk), prec)
                    dcAvg_erridxs(idx,:) = [ii,jj,kk];
                    idx=idx+1;
                    if DEBUG1
                        fprintf('Group: DC avg data for Hb type %d, Ch %d, Cond %d does not match\n', ii, jj, kk);
                        %compareOutputs_subjs(group_h2, group_h3, 'dcAvg');
                    end
                    status=1;
                end
                
            end
        end
    end
end

% Compare dodAvg
dodAvg_h2 = group_h2.group.procResult.dodAvg;
dodAvg_h3 = group_h3.group.procStream.output.GetDodAvg();
dodAvg_erridxs = [];
idx=1;
if ndims(dcAvg_h2)~=ndims(dcAvg_h3) || ~all(size(dcAvg_h2)==size(dcAvg_h3))
    dodAvg_erridxs(1)=-1;
    status=-1;
else
    for ii=1:size(dodAvg_h3,2)
        for jj=1:size(dodAvg_h3,3)
            for kk=1:size(dodAvg_h3,4)
                
                if ii>size(dodAvg_h2,2) || jj>size(dodAvg_h2,3) || kk>size(dodAvg_h2,4)
                    status=1;
                    continue;
                end
                if ~isequal_prec(dodAvg_h2(:,ii,jj,kk), dodAvg_h3(:,ii,jj,kk), prec)
                    dodAvg_erridxs(idx,:) = [ii,jj,kk];
                    idx=idx+1;
                    if DEBUG1
                        fprintf('Group: DOD avg data for Wavelength %d, Ch %d, Cond %d does not match\n', ii, jj, kk);
                        %compareOutputs_subjs(group_h2, group_h3, 'dodAvg');
                    end
                    status=1;
                end
                
            end
        end
    end
end

if ~isempty(dcAvg_erridxs)
    if dcAvg_erridxs(1)<0
        ;
    elseif DEBUG1
        title = sprintf('Homer2 output: DC Avg, Cond %d', dcAvg_erridxs(1,3));
        hf1 = figure('toolbar','none', 'menubar','none', 'name',title, 'numbertitle','off');
        p1 = get(hf1,'position');
        set(hf1, 'position', [p1(1)-(p1(1)*.6), p1(2), p1(3), p1(4)]);
        figure(hf1); hold on;
        for ii=1:size(dcAvg_h2, 3)
            plot(dcAvg_h2(:,1,ii,dcAvg_erridxs(1,3)));
        end
        grid on;
        
        title = sprintf('Homer3 output: DC Avg, Cond %d', dcAvg_erridxs(1,3));
        hf2 = figure('toolbar','none', 'menubar','none', 'name',title, 'numbertitle','off');
        p2 = get(hf2,'position');
        set(hf2, 'position', [p1(1)+(p1(1)*.6), p1(2), p1(3), p1(4)]);
        figure(hf2); hold on;
        for ii=1:size(dcAvg_h3, 3)
            plot(dcAvg_h3(:,1,ii,dcAvg_erridxs(1,3)));
        end
        grid on;
    end
end

