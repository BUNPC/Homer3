function [CondNames nTrials] = InitCondNamesSubj(runs)

if ~exist('CondNames','var')
    CondNames = repmat({''},1,size(s,2));
end

for ii=1:size(s,2)

    if isempty(CondNames{ii})
        
        % Make sure not to duplicate a condition name
        jj=0;
        kk=ii+jj;
        condName = num2str(kk);
        while ~isempty(find(strcmp(condName, CondNames)))
            jj=jj+1;
            kk=ii+jj;
            condName = num2str(kk);
        end
        CondNames{ii} = condName;

    else
                
        % Check if CondNames{ii} has a name. If not name it but 
        % make sure not to duplicate a condition name
        k = find(strcmp(CondNames{ii}, CondNames));
        if length(k)>1
            % Unname and then rename duplicate condition
            CondNames{ii} = '';
            
            jj=0;
            while find(strcmp(num2str(ii), CondNames))
                kk=ii+jj;
                CondNames{ii} = num2str(kk);
                jj=jj+1;
            end
        end
        
    end

end

nTrials = sum(s,1);
