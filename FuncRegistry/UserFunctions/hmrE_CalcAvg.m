function outputVars = hmrE_CalcAvg(inputVars)
outputVars = [];

fields = fieldnames(inputVars);
nParams = length(fields);
N = cell(nParams,1);
for iParam = 1:nParams
    eval( sprintf('outputVars.%s = [];', fields{iParam}) );
    if eval( sprintf('iscell(inputVars.%s) && ~isempty(inputVars.%s)', fields{iParam}, fields{iParam}) )
                
        if eval( sprintf('isa(inputVars.%s{1}, ''DataClass'')', fields{iParam}) )

            if eval( sprintf('isempty(outputVars.%s)', fields{iParam}) )
                eval( sprintf('outputVars.%s = DataClass();', fields{iParam}) );
                eval( sprintf('outputVars.%s.Copy(inputVars.%s{1});', fields{iParam}, fields{iParam}) );
            end
            
            nRuns = eval( sprintf('length(inputVars.%s)', fields{iParam}) );
            nMeas = eval( sprintf('size(inputVars.%s{1}.dataTimeSeries,2)', fields{iParam}) );
            N{iParam} = zeros(nMeas,1);
            for iMeas = 1:nMeas

                for iRun = 2:nRuns

                    % Add each run's data vectors one measurement column at a time
                    if eval( sprintf('any(isnan(inputVars.%s{iRun}.dataTimeSeries(:,iMeas)))', fields{iParam}) )
                        N{iParam}(iMeas) = 0;
                        continue;
                    elseif eval( sprintf('any(isnan(outputVars.%s.dataTimeSeries(:,iMeas)))', fields{iParam}) )
                        eval( sprintf('outputVars.%s.dataTimeSeries(:,iMeas) = inputVars.%s{iRun}.dataTimeSeries(:,iMeas);', fields{iParam}, fields{iParam}) );
                    else
                        eval( sprintf('outputVars.%s.dataTimeSeries(:,iMeas) = outputVars.%s.dataTimeSeries(:,iMeas) + inputVars.%s{iRun}.dataTimeSeries(:,iMeas);', fields{iParam}, fields{iParam}, fields{iParam}) );
                        N{iParam}(iMeas) = N{iParam}(iMeas)+1;
                    end
                    
                end
                
            end
            
        else
            
            eval( sprintf('outputVars.%s = inputVars.%s{1};', fields{iParam}, fields{iParam}) );

        end
        
    end
end

for iParam = 1:length(N)
    for iMeas = 1:length(N{iParam})
        if N{iParam}(iMeas) > 0
            eval( sprintf('outputVars.%s.dataTimeSeries(:,iMeas) = outputVars.%s.dataTimeSeries(:,iMeas) / N{iParam}(iMeas);', fields{iParam}, fields{iParam}) );
        end
    end
end


