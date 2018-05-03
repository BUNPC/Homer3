function stimGUI_DisplayData_StimCallback( )
global stim

t = stim.currElem.procElem.t;

point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2); 
p2 = max(point1,point2); 

if ~all(p1==p2)
    lst = find(t>=p1(1) & t<=p2(1));
else
    t1 = (t(end)-t(1))/length(t);
    lst = min(find(abs(t-p1(1))<t1));
end
s = sum(abs(stim.currElem.procElem.s(lst,:)),2);
lst2 = find(s>=1);

if isempty(lst2) & ~(p1(1)==p2(1))
    menu( 'Drag a box around the stim to edit.','Okay');
    return;
end

stimGUI_AddEditDelete(lst,lst2);
set(stim.handles.pushbuttonUpdate,'enable','on');
stimGUI_DisplayData();

