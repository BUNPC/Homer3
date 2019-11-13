function status = compareProcStreams(dataTree, groupFile_h2)

load(groupFile_h2.name);
procStream_h2 = group(1).subjs(1).runs(1).procInput;
procStream_h3 = dataTree.groups(1).subjs(1).runs(1).procStream;

b = procStream_h3 == procStream_h2;

if b==1
    status=0;
elseif b<0
    status = 4;
elseif b==0
    status = 8;
end

