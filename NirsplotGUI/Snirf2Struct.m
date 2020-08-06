% nirsData = NirsClass('C:\Users\Peter.W\Desktop\Research\Ex1_Basic_data_analysis\2-group-averaging\SubjB\subjB_run01.nirs')
% snirfData = SnirfClass(nirsData);
% testStruct = Nirs2Snirf(snirfData);
% The input should be a snirfClass data
% dirname = 'C:\Users\Peter.W\Desktop\Research\Ex1_Basic_data_analysis\2-group-averaging\SubjB\subjB_test.nirs'
% struct = Snirf2Struct(snirfData, 'test11.nirs')
function struct = Snirf2Struct(snirfData, dirname)
%
% Syntax:
%   struct = Snirf2Struct(snirfData)
%   struct = Snirf2Struct(snirfData, dirname)
%
% Description:
%   -Convert snirf data into Struct OR save as a nirsClass Data
%
%   -'struct' containing the following fields: 
%             d (required)
%             t (required)
%             s (required)
%             SD (required)
%             ml
%             aux
%             filename
%             supportedFomats
%             fileformat
%             CondNames
% Example 1:  
%           % Save .Snirf file in struct format
%           nirsData = NirsClass('...\SubjB\subjB_run01.nirs')
%           snirfData = SnirfClass(nirsData);
%           struct = Snirf2Struct(snirfData)
% 
% Example2: 
%           % Save .Snirf file as .nirs file in the same directory
%           struct = Snirf2Struct(snirfData, 'convertedNirs.nirs')
% 

    if ~exist('dirname','var')
        % if not given a path, set it to snirf path
        dirname = snirfData.filename;
    else
        if ~endsWith(dirname,'.nirs') && isempty(snirfData.filename)
            disp('please enter a dirname for your .nirs file to continue')
        end
    end
    
    struct.t = snirfData.data.time;
    struct.d = snirfData.data.dataTimeSeries;
    
%   following fields for stimData(SD)
    SDtest.Lambda = snirfData.probe.wavelengths;
    SDtest.SrcPos = snirfData.probe.sourcePos2D;
    SDtest.DetPos = snirfData.probe.detectorPos2D;
    SDtest.NSrcs = snirfData.data.measurementList(length(snirfData.data.measurementList)).sourceIndex;
    SDtest.NDets = snirfData.data.measurementList(length(snirfData.data.measurementList)).detectorIndex; 
    
    %     need further testing on this two
    SDtest.MeasListAct = ones(length(snirfData.data.measurementList),1);
    SDtest.MeasListVis = ones(length(snirfData.data.measurementList),1);
    if isfield(snirfData.metaDataTags.tags,'LengthUnit')
        SDtest.SpatialUnit = snirfData.metaDataTags.tags.LengthUnit;
    end
%   measList build    
    TempMeasList = zeros(length(snirfData.data.measurementList),4);
    TempMeasList(:,3) = 1;
    for i = 1:length(snirfData.data.measurementList)
        TempMeasList(i,1) = snirfData.data.measurementList(i).sourceIndex;
        TempMeasList(i,2) = snirfData.data.measurementList(i).detectorIndex;
        TempMeasList(i,4) = snirfData.data.measurementList(i).wavelengthIndex;
    end
    SDtest.MeasList = TempMeasList;
    struct.ml = TempMeasList;
    struct.SD = SDtest;
    
%     following for constructing Stim(S) field 
    Stemp = zeros(length(snirfData.data.time),1);
    for i = 1:size(snirfData.stim.data,1)
        index = round(snirfData.stim.data(i,1)*snirfData.stim.data(i,2));
        Stemp(index,1) = 1;
        
    end
    struct.s = Stemp;
    
%   AUX
    AuxTemp = zeros(length(snirfData.data.time),size(snirfData.aux,2));
    for i = 1:size(snirfData.aux,2)
        AuxTemp(:,i) = snirfData.aux(i).dataTimeSeries;
        
        
    end
    struct.aux = AuxTemp;
    
    
%   filenames
    struct.filename = dirname;
        
    
    struct.supportedFomats = snirfData.supportedFomats;
    struct.fileformat = 'mat';
    
%   CondNames
    struct.CondNames={};
    for ii = 1:length(snirfData.stim.name)
        struct.CondNames{ii} =  snirfData.stim.name;
        
    end
    
%     save struct as nirs file

    SaveMat(struct, dirname)
end


function SaveMat(obj, fname, ~)
if ~exist('fname','var') || isempty(fname)
    fname = '';
end
if isempty(fname)
    fname = obj.filename;
end

SD        = obj.SD;
t         = obj.t;
s         = obj.s;
d         = obj.d;
aux       = obj.aux;
CondNames = obj.CondNames;
filename  = obj.filename;
fileformat = obj.fileformat;
supportedFomats = obj.supportedFomats;
err = 0;
if isempty(fname)
    err = -1;
    return;
end
disp('-------Cconverting Snirf to Nirs------')
save(fname, '-mat', 'SD', 't' ,'s', 'd', 'aux', 'CondNames', 'filename', 'fileformat', 'supportedFomats', 'err');
end