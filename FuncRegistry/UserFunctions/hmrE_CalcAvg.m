function outputVars = hmrE_CalcAvg(inputVars)
outputVars = [];

fields = fieldnames(inputVars);
nParams = length(fields);
N = cell(nParams,1);
for iParam = 1:nParams
    eval( sprintf('outputVars.%s = [];', fields{iParam}) );
    if eval( sprintf('iscell(inputVars.%s) && ~isempty(inputVars.%s)', fields{iParam}, fields{iParam}) )
                
        if eval( sprintf('isa(inputVars.%s{1}, ''DataClass'')', fields{iParam}) )

            eval( sprintf('outputVars.%s = DataClass();', fields{iParam}) );            
            nRuns = eval( sprintf('length(inputVars.%s)', fields{iParam}) );
            for iRun = 1:nRuns

                % If outputVar DataClass object is empty then inititalize
                % it with the current run's data
                if eval( sprintf('~outputVars.%s.IsDataValid()', fields{iParam}) )
                    
                    eval( sprintf('outputVars.%s.Copy(inputVars.%s{iRun});', fields{iParam}, fields{iParam}) );
                    nMeas = eval( sprintf('length(outputVars.%s.measurementList)', fields{iParam}) );
                    N{iParam} = ones(nMeas,1);
                    
                % Otherwise add current run's data to existing output DataClass
                % object
                else
                
                    for iMeas = 1:nMeas
                        if eval( sprintf('~inputVars.%s{iRun}.IsDataValid(iMeas)', fields{iParam}) )
                            continue;
                        end
                            
                        % Add each run's data vectors one measurement column at a time
                        if eval( sprintf('~inputVars.%s{iRun}.IsEmpty() && ~outputVars.%s.IsEmpty()', fields{iParam}, fields{iParam}) )
                            eval( sprintf('outputVars.%s.dataTimeSeries(:,iMeas) = outputVars.%s.dataTimeSeries(:,iMeas) + inputVars.%s{iRun}.dataTimeSeries(:,iMeas);', fields{iParam}, fields{iParam}, fields{iParam}) );
                            N{iParam}(iMeas) = N{iParam}(iMeas)+1;
                        end                        
                    end
                
                end
                
            end
            
        elseif strcmp(fields{iParam}, 'nTrials')
            
            for ii = 1:length(inputVars.nTrials)
                if isempty(inputVars.nTrials{ii}{1})
                    continue;
                end
                if isempty(outputVars.nTrials)
                    outputVars.nTrials{1} = zeros(1,length(inputVars.nTrials{ii}{1}));
                end
                if isempty(outputVars.nTrials{1})
                    outputVars.nTrials{1} = zeros(1,length(inputVars.nTrials{ii}{1}));
                end
                outputVars.nTrials{1} = outputVars.nTrials{1} + inputVars.nTrials{ii}{1};
            end
            
        else
            
            eval( sprintf('outputVars.%s = inputVars.%s{1};', fields{iParam}, fields{iParam}) );

        end
        
    end
end

% Get averages by dividing the sums by N
for iParam = 1:length(N)
    for iMeas = 1:length(N{iParam})
        if isempty(iMeas)
            continue
        end
        if N{iParam}(iMeas) > 0
            eval( sprintf('outputVars.%s.dataTimeSeries(:,iMeas) = outputVars.%s.dataTimeSeries(:,iMeas) / N{iParam}(iMeas);', fields{iParam}, fields{iParam}) );
        end
    end
end



