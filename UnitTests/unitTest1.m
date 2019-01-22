function status = unitTest1()

DEBUG1 = 0;
prec = 10;

rootpath = fileparts(which('homer3.m'));

currpath = pwd;
cd([rootpath, '/UnitTests/Example9_SessRuns']);
status = 0;
resetGroupFolder();
calcProcStream();

% Load results from homer2 and homer3 
group_h2 = load('./groupResults_homer2.mat');
group_h3 = load('./groupResults.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare results: Here are the tests we must pass to get clean bill of health
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Compare dcAvg
dcAvg_h2  = group_h2.group.procResult.dcAvg;
dcAvg_h3  = group_h3.group.procStream.output.dcAvg;
dcAvg_erridxs = [];
idx=1;
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
                
                fprintf('DC avg data for Hb type %d, Ch %d, Cond %d does not match\n', ii, jj, kk);
                status=1;
            end
            
        end
    end
end

% Compare dodAvg
dodAvg_h2 = group_h2.group.procResult.dodAvg;
dodAvg_h3 = group_h3.group.procStream.output.dodAvg;
dodAvg_erridxs = [];
idx=1;
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
                fprintf('DOD avg data for Wavelength %d, Ch %d, Cond %d does not match\n', ii, jj, kk);
                status=1;
            end
            
        end
    end
end


if ~isempty(dcAvg_erridxs)
    if DEBUG1
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

if status==0
    fprintf('Output matches homer2 output for this data\n');
else
    fprintf('Output does NOT match homer2 output for this data\n');    
end

cd(currpath);

