function [data,cnames,cwidth,ceditable] = stimGUI_updateUserData(stim,s,t)

[lstR,lstC] = find(abs(s)==1);
[lstR,k] = sort(lstR);

if(~isfield(stim,'userdata') | isempty(stim.userdata))
    data = repmat({0,''},length(lstR),1);
    for ii=1:length(lstR)
        data{ii,1} = t(lstR(ii));
    end
    cnames={'1'};
    cwidth={100};
    ceditable=logical([1]);
elseif(isfield(stim,'userdata') & isfield(stim.userdata,'data') & isempty(stim.userdata.data))
    ncols = length(stim.userdata.cnames);
    data = [repmat({0},length(lstR),1) repmat({''},length(lstR),ncols)];
    for ii=1:length(lstR)
        data{ii,1} = t(lstR(ii));
    end
    cnames    = stim.userdata.cnames;
    cwidth    = stim.userdata.cwidth;
    ceditable = stim.userdata.ceditable;
else
    data0     = stim.userdata.data;
    cnames    = stim.userdata.cnames;
    cwidth    = stim.userdata.cwidth;
    ceditable = stim.userdata.ceditable;

    ncols = size(data0,2);
    data  = cell(0,ncols);

    % Find which data to add/delete
    for ii=1:length(lstR)
        % Search for stim in current table
        data(ii,:) = [{0} repmat({''},1,ncols-1)];
        data{ii,1} = t(lstR(ii));
        for jj=1:size(data0,1)
            if (data{ii,1} == data0{jj,1})
                data(ii,:) = data0(jj,:);
            end
        end
    end
end
