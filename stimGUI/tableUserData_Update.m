function tableUserData_Update(hObject,data,cnames,cwidth,ceditable,action)
global stim

if(~exist('action','var') | isempty(action))
    action='all';
end
hObject = stim.handles.tableUserData;

userdata=struct('data','cnames','cwidth','ceditable');
switch(lower(action))
case 'all'
    if length(cnames)>0
        set(hObject,'Data',data(:,2:end),'ColumnName',cnames,'ColumnWidth',cwidth,...
            'ColumnEditable',ceditable);
    else
        set(hObject,'Data',data(:,2:end),'ColumnName',cnames);
    end
    set(hObject,'userdata',data(:,1));
    userdata.data      = data;
    userdata.cnames    = cnames;
    userdata.cwidth    = cwidth; 
    userdata.ceditable = ceditable;
    stim.userdata      = userdata;
case 'data'
    set(hObject,'userdata',data(:,1));
    stim.userdata.data = data;
case 'cnames'
    set(hObject,'ColumnName',cnames);
    stim.userdata.cnames = cnames;
case 'cwidth'
    set(hObject,'ColumnWidth',cwidth);
    stim.userdata.cwidth = cnames.cwidth;
case 'ceditable'
    set(hObject,'ColumnEditable',ceditable);
    stim.userdata.ceditable = cnames.ceditable;
end 

