function [conds,labels,stimData] = StimCSV_Reader()
    %Open File
%     filename = "StimCSV_Sample_Error.csv";
    [file,path,~] = uigetfile({'*.csv','CSV File (*.csv)'});
    filename = [path file];
    stimFileID = fopen(filename);
    
    %Initial Variables
    i = 1;
    stimNameIndicator = true;
    stimLabelIndicator = true;
    labels = cell(1,1);
    data = [];
    stimData = cell(1,1);
    
    %Get Line
    linestr = fgetl(stimFileID);
    
    while(linestr ~= -1)
        strCell = strsplit(linestr,',');
        strCell = strCell(~cellfun(@isempty,strCell));
        if isempty(strCell) %Update Stim (Finalize)
            try
                stimData{:,i} = data;
            catch
                errordlg('Invalid Stim CSV Syntax. Please check reference file for guidance');
                return;
            end
            i = i+1;
            stimNameIndicator = true;
            stimLabelIndicator = true;
            data = [];
        elseif stimNameIndicator %Update Stim Name
            try
                conds{i} = strCell(1);
            catch
                errordlg('Invalid Stim CSV Syntax. Please check reference file for guidance');
                return;
            end
            stimNameIndicator = false;
        elseif stimLabelIndicator %Update Stim Label
            labels{i} = strCell;
            stimLabelIndicator = false;
        else %Update Stim Data
            try
                data = [data; strCell];
            catch
                errordlg('Invalid Stim CSV Syntax. Please check reference file for guidance');
                return;
            end
        end
        %Read Next Line
        linestr = fgetl(stimFileID);
    end
    
    %Final Stim Update
    stimData{:,i} = data;
    
    %Close File
    fclose(stimFileID);
end