function [nSubjs, nRuns] = GenerateGroupDisplayLists()
global maingui

list = maingui.dataTree.DepthFirstTraversalList();
views = maingui.listboxGroupTreeParams.views;
jj=0; kk=0;
nSubjs = 0;
nRuns = 0;
for ii=1:length(list)
    % Add group level nodes only to whole-tree list
    if list{ii}.IsGroup()
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1} = list{ii}.GetName;
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
    
    % Add subject level nodes to whole-tree and subject lists
    elseif list{ii}.IsSubj()
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1}   = ['    ', list{ii}.GetName];
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
        
        jj=jj+1;
        maingui.listboxGroupTreeParams.listMaps(views.SUBJS).names{jj,1} = list{ii}.GetName;
        maingui.listboxGroupTreeParams.listMaps(views.SUBJS).idxs(jj,:)  = list{ii}.GetIndexID;
    
        nSubjs = nSubjs+1;
        
    % Add run level nodes to ALL lists 
    elseif list{ii}.IsRun()
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1}   = ['        ', list{ii}.GetFileName];
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
            
        jj=jj+1;
        maingui.listboxGroupTreeParams.listMaps(views.SUBJS).names{jj,1} = ['    ', list{ii}.GetFileName];
        maingui.listboxGroupTreeParams.listMaps(views.SUBJS).idxs(jj,:)  = list{ii}.GetIndexID;

        kk=kk+1;
        maingui.listboxGroupTreeParams.listMaps(views.RUNS).names{kk,1}  = list{ii}.GetFileName;
        maingui.listboxGroupTreeParams.listMaps(views.RUNS).idxs(kk,:)   = list{ii}.GetIndexID;

        nRuns = nRuns+1;
        
    end
end
