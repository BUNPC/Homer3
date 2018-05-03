function [sCondNames nTrials] = stimCondInit(s,sCondNames)

if ~exist('sCondNames','var')
    sCondNames = repmat({''},1,size(s,2));
end

for ii=1:size(s,2)

    if isempty(sCondNames{ii})
        
        % Make sure not to duplicate a condition name
        jj=0;
        kk=ii+jj;
        condName = num2str(kk);
        while ~isempty(find(strcmp(condName, sCondNames)))
            jj=jj+1;
            kk=ii+jj;
            condName = num2str(kk);
        end
        sCondNames{ii} = condName;
        %{
        if sum(s(:,ii))~=0
            sCondNames{ii} = condName;
        else
            sCondNames{ii} = [condName '$'];
        end
        %}

    else
                
        % Check if sCondNames{ii} has a name. If not name it but 
        % make sure not to duplicate a condition name
        k = find(strcmp(sCondNames{ii}, sCondNames));
        if length(k)>1
            % Unname and then rename duplicate condition
            sCondNames{ii} = '';
            
            jj=0;
            while find(strcmp(num2str(ii), sCondNames))
                kk=ii+jj;
                sCondNames{ii} = num2str(kk);
                %{
                if sum(s(:,ii))~=0
                    sCondNames{ii} = num2str(kk);
                else
                    sCondNames{ii} = [num2str(kk) '$'];
                end
                %}
                jj=jj+1;
            end
        end
        
    end

end

nTrials = sum(s,1);
