function h = getSclPanelEditHandle(hPanel)

hc=get(hPanel,'children');
k=find(strcmp(get(hc,'style'),'edit'));
h = hc(k);
