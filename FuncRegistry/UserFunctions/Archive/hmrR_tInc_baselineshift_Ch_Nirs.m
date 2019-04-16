function [tIncCh, tInc] = hmrR_tInc_baselineshift_Ch_Nirs(dod, t)

% Sahar Jahani, October 2017
iqr = 1.5;
SNR_Thre = zeros(1,size(dod,2));
fs = abs(1/(t(2)-t(1)));
for ww = 1:size(dod,2)
    clearvars -except ww tInc d ml fs t dod tMotion SD dodorg p iqr SNR_Thre SNR_Thre2 FrameSize_sec 
    s1 =  dod(:,ww) ;
    [s1,ylpf] = hmrR_BandpassFilt_Nirs( s1, fs, 0, 2);
    [s2,ylpf] = hmrR_BandpassFilt_Nirs( s1, fs, 0, 0.5);
    
    %% detecting outliers in std variations of the signal
    tMotion=1; Win_Size=round(fs*tMotion);
    for ilent=1:length(s1)-(Win_Size)
        Sigstd(ilent,1)=std(s2(ilent:ilent+(Win_Size),:));
    end
    iqr2 = 2;
    quants_std = quantile(Sigstd,[.25 .50 .75]);  % compute quantiles
    IQR_std = quants_std(3)-quants_std(1);  % compute interquartile range
    High_std = quants_std(3)+IQR_std*iqr2;
    Low_std = quants_std(1)-IQR_std*iqr2;

    %% detecting outliers in gradient of the signal
    grad = conv(s1,[-1,0,1]); % Sobel mask
    quants = quantile(grad,[.25 .50 .75]);  % compute quantiles
    IQR1 = quants(3)-quants(1);  % compute interquartile range
    High = quants(3)+IQR1*iqr;
    Low = quants(1)-IQR1*iqr;
    %% Union of all outliers
    z_std=0;
    for i=1:length(dod)-(Win_Size)
        if ((Sigstd(i)>High_std) || (Sigstd(i)<Low_std))
            z_std=z_std+1; M_std(z_std)=i;
        end
    end
    
    if exist('M_std','var')
    M_std=round(Win_Size/2)+M_std;
    end
    
    z=0;
    for i=1:length(dod)
        if ((grad(i)>High) || (grad(i)<Low))
            z=z+1; M_sobel(z)=i;
        end
    end
    if exist('M_sobel','var') && exist('M_std','var')
    M=union(M_sobel,M_std);
    else if exist('M_sobel','var')
            M=M_sobel;
        else if exist('M_std','var')
            M=M_std;
            end
        end
    end
    
% % %     if exist('M_sobel','var')
% % %         M=M_sobel;
% % %     end
    
    extend = round(12*fs);
    s11=repmat(s1(1,:),extend,1);s12=repmat(s1(end,:),extend,1);
    s1=[s11;s1;s12]; % extending signal for motion detection purpose (12 sec from each edge)
    
    fs=1/(t(2)-t(1));
    t=(0:(1/fs):(length(s1)/fs))';
    t=t(1:length(s1),1);
    
    %% Baseline shift motion detection
    
    if exist('M','var')
        M=M+extend;
        sig=ones(length(s1),1);
        for i=1:length(M)
            sig(M(i),:)=0;
        end
        
        %%% finding the location of the spikes or baseline shifts
        temp=(diff(sig));c1=0;c2=0;
        c=0;
        for i=1:length(s1)-1
            if temp(i)~=0
                c=c+1;
                pik(c)=i;
            end
        end
        temp2=diff(pik);
        
        c1=0;c2=0;
        for i=1:length(s1)-1
            if (temp(i)==1)
                c1=c1+1;
                meanpL(c1)=mean(s1(i),1);
            end
            
            if (temp(i)==-1)
                c2=c2+1;
                meanpH(c2)=mean(s1(i),1);
            end
        end
        
        motionkind=abs(meanpH-meanpL);
        
        %% finding the baseline shifts by comparing motion amplitudes with heart rate amplitude
        stemp=s1;
        [s1,ylpf] = hmrR_BandpassFilt_Nirs( stemp, fs, 0, 2 );
        snoise2=stemp;
        zz=0;tt=1;
        for i=1:length(s1)-1
            if (sig(i)==1)
                zz=zz+1;
                sigtemp{1,tt}(1,zz)=s1(i);
                sigtempnoise{1,tt}(1,zz)=snoise2(i);
                if ((sig(i)==1) && (sig(i+1)==0))
                    tt=tt+1;
                    zz=0;
                end
            end
        end
        Nthre=round(0.5*fs);ssttdd=0;
        for i=1:tt
            tempo=sigtemp{1,i};
            if length(tempo)>Nthre
                for l=1:length(tempo)-Nthre
                    tempo2(l)=(abs(tempo(l+Nthre)-tempo(l)));
                end
            end
            ssttdd=[ssttdd tempo2];
            clear tempo2
            tempo2=[];
        end
        
        thrshld=quantile(ssttdd,[0.5]);
        pointS=(find(temp<0));
        pointE=(find(temp>0));
        countnoise=0;
        for ks=1:length(sigtempnoise)
            if (length(sigtempnoise{1,ks})>3*fs)
                countnoise=countnoise+1;
                dmean = mean(sigtempnoise{1,ks},2);
                dstd = std(sigtempnoise{1,ks},[],2);
                SNR_Thresh(countnoise,1)=abs(dmean)./(dstd+eps);
            end
        end
        
        SNR_Thre(1,ww)=mean(SNR_Thresh(2:end-1,1));
        
        
        sig2=ones(length(s1),1);
        
        for i=1:length(pointS)
            if motionkind(i)>thrshld
                sig2(pointS(i):pointE(i),:)=0;
            end
            % % % % % % % % % % % % % % % % % %
            % spline on long duration spikes  %
            % % % % % % % % % % % % % % % % % %
            
            if (((pointE(i)-pointS(i))> (0.1*fs))&&((pointE(i)-pointS(i))< (0.49999*fs)));
                sig2(pointS(i):pointE(i),:)=0;
            end
            if (pointE(i)-pointS(i))> (fs);
                sig2(pointS(i):pointE(i),:)=0;
            end
        end
        clear pointS
        clear pointE
        clear sig
        clear temp
        
        tInc(:,ww)=sig2;
    else
        tInc(:,ww)=ones(length(t),1);
    end
end

%% Calculating SNR for all the channels

for w=1:(size(SNR_Thre,2))
    if isnan(SNR_Thre(1,w)) || isempty(SNR_Thre(1,w)) || (SNR_Thre(1,w)==0)
        dmean = mean(dod(:,w));
        dstd = std(dod(:,w));
        SNR_Thre(1,w)=abs(dmean)./dstd;
    end
end

%% Extracting the noisy channels from baseline-shift motion correction precedure

lent=size(SNR_Thre,2)/2;
SNRvalue=3;
for ww1=1:(size(SNR_Thre,2)/2)
    if ((SNR_Thre(1,ww1)<SNRvalue) && (SNR_Thre(1,ww1+lent)<SNRvalue))
        tInc(:,ww1+lent)=ones(length(t),1);
        tInc(:,ww1)=ones(length(t),1);
    else if ((SNR_Thre(1,ww1)>SNRvalue) && (SNR_Thre(1,ww1+lent)<SNRvalue))
            tInc(:,ww1+lent)=tInc(:,ww1);
        else if ((SNR_Thre(1,ww1)<SNRvalue) && (SNR_Thre(1,ww1+lent)>SNRvalue))
                tInc(:,ww1)=tInc(:,ww1+lent);
            end
        end
    end
% % %     if ((SNR_Thre(1,ww1)>20) && (SNR_Thre(1,ww1+lent)>20))
% % %         tInc(:,ww1+lent)=ones(length(t),1);
% % %         tInc(:,ww1)=ones(length(t),1);
% % %     end
end

tIncCh=tInc(extend+1:end-extend,:);
tInc=tInc(extend+1:end-extend,:);
tIncall=tInc(:,1);
for kk=2:size(tInc,2)
  tIncall= tIncall.*tInc(:,kk);    
end
tInc=tIncall;

