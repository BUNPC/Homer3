% SYNTAX:
% [dcAvg, dcAvgStd, nTrials] = hmrR_TaskNorm(dc, stim, deltat, show )
%
% UI NAME:
% Task_Normalization
%
% DESCRIPTION:
% Calculate the average of the HRF over the duration of the task.
% copyright  � 2023, Medea.
% Authors: Anna Falivene, Charlotte Johnson

%
% INPUT:
% dc: SNIRF.data container with the concentration data
% stim: SNIRF.stim container with the stimulus condition data
% deltat: defines the range before the onset and after the duration
% [tPre_onset tPost_duration]. Both positive (or null) values
% show: parameter to able/disable figure(). if show=0 no figure will
% appear, if =1 figures with the HBO and HBR concentration for each
% channel will appear
%
% OUTPUT:
% dcAvg: averaged results
% dcAvgStd: standard deviation across trials
% nTrials: the number of trials averaged
%
% USAGE OPTIONS:
% Task_Normalization_on_Concentration_Data: [dcAvg, dcAvgStd, nTrials] = hmrR_TaskNorm(dc, stim, deltat, show )
%
% PARAMETERS:
% deltat: [0, 0]
% show: 1
%
% PREREQUISITES:
% Delta_OD_to_Conc: dc = hmrR_OD2Conc( dod, probe, ppf )
%
function [dcAvg, dcAvgStd, nTrials] = hmrR_TaskNorm(dc, stim, deltat, show )

snirf = SnirfClass(dc, stim); %read the concentration data

delta1=deltat(1); %baseline duration
delta2=deltat(2); %post task duration
dcAvg= DataClass();
dcAvgStd = DataClass();
d = dc.GetDataTimeSeries();

%to compute the mean duration of the stimuli/tasks considered
m_durations1=[];
for ic=1:size(stim,2)
    if size(stim(1, ic).data) ~=0

        s1= stim(:,ic).GetData();
        m_durations1=[m_durations1;mean(s1(:,2),1)];
    end
end

for ic=1:size(stim,2)
    if size(stim(1, ic).data) ~=0

        s1= stim(:,ic).GetData();
    else
        continue
    end
    t = snirf.GetTimeCombined();
    Fs=1/(t(2)-t(1)); %sampling rate
    nTrials=size(s1,1);
    namestr=[];
   

    for i=1:nTrials
        my_field = string(['Repetition',num2str(i)]);
         namestr=[namestr;my_field];
        str.(my_field) = [];

%data segmentation of each repetition
        T1=find(t>=s1(i,1),1,'first');%finding onset
        T2=find(t<=s1(i,1)+s1(i,2),1,'last');%finding end of trial (onset+dur)
        newtime=t(T1:T2);
        newdata=d(T1:T2,:); 
        rsdata=(round(mean(m_durations1)))*50;%number of samples you want to have when interpolating/normalizing 
        normtime=linspace(newtime(1),newtime(end),rsdata);
        %data interpolation for the task execution phase of the trial
        norm_data=interp1(newtime, newdata, normtime, 'spline');
%data interpolation for the baseline and post-task phases of the trial
        if delta1~=0 | delta2~=0

            %data segmentation of baseline and post task phases
            T1d=T1-round(delta1*Fs);
            T2d=T2+round(delta2*Fs);
            
            rs1=(delta1*50);%defines numer of samples of delta1
            rs2=(delta2*50);%defines numer of samples of delta2
            n1=linspace(t(T1d),t(T1),rs1);%=Generate linearly spaced vector.
            n2=linspace(t(T2),t(T2d),rs2);% =Generate linearly spaced vector.
            if delta1~=0
                d1=interp1(t(T1d:T1), d(T1d:T1,:), n1, 'spline');% interpolation of data in delta1
            else
                d1=[];
            end
            if delta2~=0
                d2=interp1(t(T2:T2d), d(T2:T2d,:), n2, 'spline');% interpolation of data in delta2
            else
                d2=[];
            end

            norm_data=[ d1(1:end-1,:); norm_data; d2(2:end,:)];

        end

        str.(namestr(i,:))=norm_data;%saves new data in a structure
    end

    meanvalues=[]; stdvalues=[]; %forming a matrix where the MEAN and STD values are stored

    ml = dc.GetMeasListSrcDetPairs('reshape'); %opening the measlist useful to calculate mean and stds 

    %compute mean and std over the trials
    for k=1:(3*size(ml,1))
        ALLM=[];

        for nt=1:nTrials
            ALLM=[ALLM str.(namestr(nt,:))(:,k)];
        end
        meanvalues=[meanvalues mean(ALLM,2)];
        stdvalues=[stdvalues std(ALLM,1,2)];

    end

    % '%cycle' vector
    if delta1~=0 & delta2~=0
        x1=linspace(0,100,rsdata+rs1+rs2-2);%=Generate linearly spaced vector from 0-100%.
        disp (['onset: ', num2str(x1(rs1-1)), '%', ' - ', 'end of stimulus: ' ,num2str(x1(rs1-1+rsdata)), '%'])
    elseif delta1~=0 & delta2==0 %only baseline
        x1=linspace(0,100,rsdata+rs1-1);
        disp (['onset: ', num2str(x1(rs1-1)), '%'])
    elseif delta1==0 & delta2~=0 %no baseline but only resting period after the stim
        x1=linspace(0,100,rsdata+rs2-1);
        disp (['end of stimulus: ' ,num2str(x1(rs1-1+rsdata)), '%'])
    else
        x1=linspace(0,100,rsdata); %only exercise task
    end

    avghrf=[]; figs=[];
    tot_avg=[];

    %based on BlockAVG, Computing mean and std per channel in the different tasks.
    for ll=1:3:size(meanvalues,2)-2

        yHBO=meanvalues(:,ll); %HbO
        yHBR=meanvalues(:,ll+1); %hbR
        yHBT=meanvalues(:,ll+2); %hbt
        sdHBO=stdvalues(:,ll);
        sdHBR=stdvalues(:,ll+1);


        ALLHBO=[];ALLHBR=[];%creating a matrix for All HbO and HbR data

        for nt=1:nTrials
%data concentration of each trial
            ALLHBO=[ALLHBO str.(namestr(nt,:))(:,ll)];
            ALLHBR=[ALLHBR str.(namestr(nt,:))(:,ll+1)];
        end

%baseline correction (as in Homer BlockAvg function) can be performed only if delta1 is different from 0
        if delta1~=0
            foomHBO = ones(size(yHBO,1),1)*mean(yHBO(1:rs1-1),1);
            foomHBR = ones(size(yHBR,1),1)*mean(yHBR(1:rs1-1),1);
            foomHBT = ones(size(yHBT,1),1)*mean(yHBT(1:rs1-1),1);
            avghrf(:,ll)=yHBO-foomHBO;
            avghrf(:,ll+1)=yHBR-foomHBR;
            avghrf(:,ll+2)=yHBT-foomHBT;

        else
            %no correction
            avghrf(:,ll)=yHBO;
            avghrf(:,ll+1)=yHBR;
            avghrf(:,ll+2)=yHBT;
        end

%%% Plot section 
        f=figure();
        ax1=subplot('Position',[0.35 0.58 0.33 0.34 ]);
        txt=['Source ',num2str(dc.measurementList(1,ll).sourceIndex),' detector ', num2str(dc.measurementList(1,ll).detectorIndex)];

        patch([x1 fliplr(x1)], [avghrf(:,ll)-sdHBO ;flipud(avghrf(:,ll)+sdHBO)], [0.6350 0.0780 0.1840] , 'FaceAlpha', 0.5 )
        hold on
        plot(x1,avghrf(:,ll),'r', 'LineWidth',2)

        patch([x1 fliplr(x1)], [avghrf(:,ll+1)-sdHBR ;flipud(avghrf(:,ll+1)+sdHBR)], [0.3 0.75 0.9], 'FaceAlpha', 0.5)
        plot(x1,avghrf(:,ll+1),'Color', '#0072BD', 'LineWidth',2)

        hold off
        lgd=legend('HbO','', 'HbR','');
        title(txt )

        ax2=subplot(223);
        plot(x1,ALLHBO, 'LineWidth',1)
        legend(namestr(:,:))
        title('HbO_2 in each repetition')


        ax3=subplot(224);
        plot(x1,ALLHBR, 'LineWidth',1)
        legend(namestr(:,:))
        title('HbR in each repetition')

        axx=[ax1 ax2 ax3];
        grid (axx, 'on' )
        ax1.YGrid='off';
        xlabel(axx,'% of trial')
        % ylabel(axx, '[M]')
    
        ax1.GridAlpha=0.5;
        xtickangle([ax1 ax2 ax3],0)
        
        if delta1~=0 & delta2~=0
            xticks([ax1 ax2 ax3],[0 x1(rs1-1) x1(rs1-1+rsdata) 100])
            xticklabels([ax1 ax2 ax3],{'0','onset', 'end of the stimulus', '100'})


        elseif delta1~=0 & delta2==0 %only baseline
            xticks([ax1 ax2 ax3],[0 x1(rs1-1) 100])
            xticklabels([ax1 ax2 ax3],{'0','onset', '100'})

        elseif delta1==0 & delta2~=0 %no baseline but only resting period after the stim
            xticks([ax1 ax2 ax3],[0  x1(end-(rs2-1)) 100])
            xticklabels([ax1 ax2 ax3],{'0', 'end of the stimulus', '100'})

        else %only exercises
            xticks([ax1 ax2 ax3],[0  100])
            xticklabels([ax1 ax2 ax3],{'0','100'})

        end
     
        hlink = linkprop([ax1 ax2 ax3],{'YGrid','GridAlpha'});
     

        figs=[figs; f];
    end
    figs=(find(figs~=0));

%saving figures
    global maingui
    folder=uigetdir();%decide where figures are stored.
    namefig=maingui.dataTree.currElem.name; %can be modified according to how the .snirf file were named
    namefig=namefig(1:end-6);
    namefig=[namefig, '.fig'];
    HRF=fullfile(folder,namefig);

    savefig(figs,HRF,'compact');

%add the data into the dcAvg and dcAvgStd Dataclasses
  
    for nn=1:size(ml,1)
        dcAvg.AddChannelHbO(ml(nn,1), ml(nn,2), ic);
        dcAvg.AddChannelHbR(ml(nn,1), ml(nn,2), ic);
        dcAvg.AddChannelHbT(ml(nn,1), ml(nn,2), ic);
        dcAvgStd.AddChannelHbO(ml(nn,1), ml(nn,2), ic);
        dcAvgStd.AddChannelHbR(ml(nn,1), ml(nn,2), ic);
        dcAvgStd.AddChannelHbT(ml(nn,1), ml(nn,2), ic);
        
    end
   
    dcAvg.AppendDataTimeSeries(avghrf);
    dcAvgStd.AppendDataTimeSeries(stdvalues);
    dcAvg.SetTime(x1, true);
    dcAvgStd.SetTime(x1, true);
end




