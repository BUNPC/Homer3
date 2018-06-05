function SD = SetSDRun(SD)

% calculate dimensions of SDG axes
distances=[];
lst=find(SD.MeasList(:,1)>0);
ml=SD.MeasList(lst,:);
lst=find(ml(:,4)==1);

for idx=1:length(lst)
    SrcPos=SD.SrcPos(ml(lst(idx),1),:);
    DetPos=SD.DetPos(ml(lst(idx),2),:);

    dist=norm(SrcPos-DetPos);
    distances=[distances; dist];
end

meanSD=mean(distances);

SD.xmin = min( [SD.SrcPos(:,1); SD.DetPos(:,1)] -1/2*meanSD);
SD.xmax = max( [SD.SrcPos(:,1); SD.DetPos(:,1)] +1/2*meanSD);
SD.ymin = min( [SD.SrcPos(:,2); SD.DetPos(:,2)] -1/2*meanSD);
SD.ymax = max( [SD.SrcPos(:,2); SD.DetPos(:,2)] +1/2*meanSD);

SD.nSrcs = size(SD.SrcPos,1);
SD.nDets = size(SD.DetPos,1);

if ~isproperty(SD,'MeasListAct')
    SD.MeasListAct = ones(size(SD.MeasList,1),1);
end
if ~isproperty(SD,'MeasListVis')
    SD.MeasListVis = ones(size(SD.MeasList,1),1);
end
