function condition = GetCondition(handles)

condition = 0;

if nargin==0
    return
end
if isempty(handles)
    return
end
condition = get(handles.popupmenuConditions, 'value');

