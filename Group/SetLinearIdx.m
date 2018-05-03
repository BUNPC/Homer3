function group = SetLinearIdx(group)

linearidx = 1;

group(1).linearidx = linearidx;
linearidx=linearidx+1;
for jj=1:length(group(1).subjs)
    group(1).subjs(jj).linearidx = linearidx;
    linearidx=linearidx+1;
    for kk=1:length(group(1).subjs(jj).runs)
        group(1).subjs(jj).runs(kk).linearidx = linearidx;
	linearidx=linearidx+1;
    end
end

