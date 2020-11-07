function exportProcessScript(fname, procstream)
    if isa(procstream, 'ProcStreamClass')
        
        if length(procstream.fcalls) == 0
            return;
        end
        
        fid = fopen(fname, 'wt');
        
        if fid ~= -1
            
            inputs = {};
            
            % Write the header
            fprintf(fid, '%%{\n');
            fprintf(fid, 'The following input(s) to this processing stream must be defined:\n');
            for i = procstream.GetFcallsIdxs()
                argIn = procstream.GetInputArgs(i);
                for j = 1:length(argIn)
                    if ~any(strcmp(inputs, argIn{j}))
                        if ~exist(argIn{j},'var')
                            fprintf(fid, '%s\n', argIn{j});
                            inputs{end + 1} = argIn{j};
                        end
                    end
                end
            end
            fprintf(fid, '\n');
            fprintf(fid, 'A script which loads some inputs from an acquisition file (.snirf, .nirs) at acquisition_path\n');
            fprintf(fid, 'is provided below. Consult the Homer3 wiki https://github.com/BUNPC/Homer3/wiki on the\n');
            fprintf(fid, 'specified format of other function inputs.\n');
          
            fprintf(fid, '%%}\n');
        
            fprintf(fid, '\n');
            fprintf(fid, 'acquired_path = '''';\n');
            fprintf(fid, '\n');
            fprintf(fid, 'if ~isempty(acquired_path)\n');
            fprintf(fid, '    acquired = SnirfClass(acquired_path);\n');
            for i = 1:length(inputs)
               fprintf(fid, '    %s = acquired.%s;\n', inputs{i}, inputs{i});
            end
            fprintf(fid, 'end\n');
            fprintf(fid, '\n');
            
            % Write the processing stream
            for i = procstream.GetFcallsIdxs()
                argIn = procstream.GetInputArgs(i);
                for j = 1:length(argIn)
                    if ~exist(argIn{j},'var')
                        eval(sprintf('%s = procstream.input.GetVar(''%s'');', argIn{j}, argIn{j}));
                    end
                end
                [sargin, p, sarginVal] = procstream.ParseInputParams(i);
                sargout = procstream.ParseOutputArgs(i);
                
                fprintf(fid, '%%{\n');
                fprintf(fid, procstream.fcalls(i).help);
                fprintf(fid, '%%}');
                
                fprintf(fid, '\n');
                fprintf(fid, '%s = %s%s%s);\n', sargout, procstream.GetFuncCallName(i), procstream.fcalls(i).argIn.str, sarginVal);
                fprintf(fid, '\n');
            end
            
            fprintf(fid, '\n');
            fclose(fid);
            
        else
            return;
        end
        
    else
       return; 
    end
    
end