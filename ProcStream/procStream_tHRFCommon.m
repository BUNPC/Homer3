function procResult = procStream_tHRFCommon(procResult, tHRF_common, name, type)

if size(tHRF_common,2)<size(tHRF_common,1)
    tHRF_common = tHRF_common';
end
tHRF = procResult.tHRF;
n = length(tHRF_common);
m = length(tHRF);
d = n-m;
if d<0

    disp(sprintf('WARNING: tHRF for %s %s is larger than the common tHRF.',type, name));
    if ~isempty(procResult.dodAvg)
        procResult.dodAvg(n+1:m,:,:)=[];
        if strcmp(type,'run')
            procResult.dodSum2(n+1:m,:,:)=[];
        end
    end
    if ~isempty(procResult.dcAvg) 
        procResult.dcAvg(n+1:m,:,:,:)=[];
        if strcmp(type,'run')
            procResult.dcSum2(n+1:m,:,:,:)=[];
        end
    end

elseif d>0

    disp(sprintf('WARNING: tHRF for %s %s is smaller than the common tHRF.',type, name));
    if ~isempty(procResult.dodAvg)
        procResult.dodAvg(m:n,:,:)=zeros(d,size(procResult.dodAvg,2),size(procResult.dodAvg,3));
        if strcmp(type,'run')
            procResult.dodSum2(m:n,:,:)=zeros(d,size(procResult.dodSum2,2),size(procResult.dodSum2,3));
        end
    end
    if ~isempty(procResult.dcAvg) 
        procResult.dcAvg(m:n,:,:,:)=zeros(d,size(procResult.dcAvg,2),size(procResult.dcAvg,3),size(procResult.dcAvg,4));
        if strcmp(type,'run')
            procResult.dcSum2(m:m+d,:,:,:)=zeros(d,size(procResult.dcSum2,2),size(procResult.dcSum2,3),size(procResult.dcSum2,4));
        end
    end

end
procResult.tHRF = tHRF_common;

