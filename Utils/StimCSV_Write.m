function StimCSV_Write(conds,stimLabels,stimData)
%     filename = 'test.csv';
%     stimvar = importStim;
    [file,path,~] = uiputfile({'*.csv','CSV File (*.csv)'});
    filename = [path file];
    
    fid = fopen(filename,'w');
    
    for i = 1:length(conds)
        for j = 1:size(stimData{i},1)+2
            linestr = [];
            for k = 1:size(stimLabels{i},2)
                if j == 1
                    if k == 1
                        linestr = sprintf('%s,', conds{i});
                        linediv = sprintf(',');
                    elseif k == size(stimLabels{i},2)
                        % Done
                        linediv = sprintf('%s\n', linediv);
                    else
                        linestr = sprintf('%s,', linestr);
                        linediv = sprintf('%s,', linediv);
                    end
                elseif j == 2
                    if k == size(stimLabels{i},2)
                        linestr = sprintf('%s%s', linestr, stimLabels{i}{k});
                    else
                        linestr = sprintf('%s%s,', linestr, stimLabels{i}{k});
                    end
                else
                    if k == size(stimLabels{i},2)
                        linestr = sprintf('%s%f', linestr, stimData{i}(j-2,k));
                    else
                        linestr = sprintf('%s%f,', linestr, stimData{i}(j-2,k));
                    end
                end
            end
            linestr = sprintf('%s\n', linestr);
            fprintf(fid,linestr);
        end
        fprintf(fid,linediv);
    end
    
    fclose(fid);

end
