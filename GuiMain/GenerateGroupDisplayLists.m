function [nSubjs, nRuns] = GenerateGroupDisplayLists()
global hmr

list = hmr.dataTree.DepthFirstTraversalList();
views = hmr.listboxGroupTreeParams.views;
jj=0; kk=0;
nSubjs = 0;
nRuns = 0;
for ii=1:length(list)
    % Add group level nodes only to whole-tree list
    if list{ii}.IsGroup()
        hmr.listboxGroupTreeParams.listMaps(views.ALL).names{ii,1} = list{ii}.GetName;
        hmr.listboxGroupTreeParams.listMaps(views.ALL).idxs(ii,:) = list{ii}.GetIndexID;
    
    % Add subject level nodes to whole-tree and subject lists
    elseif list{ii}.IsSubj()
        hmr.listboxGroupTreeParams.listMaps(views.ALL).names{ii,1}   = ['    ', list{ii}.GetName];
        hmr.listboxGroupTreeParams.listMaps(views.ALL).idxs(ii,:) = list{ii}.GetIndexID;
        
        jj=jj+1;
        hmr.listboxGroupTreeParams.listMaps(views.SUBJS).names{jj,1} = list{ii}.GetName;
        hmr.listboxGroupTreeParams.listMaps(views.SUBJS).idxs(jj,:)  = list{ii}.GetIndexID;
    
        nSubjs = nSubjs+1;
        
    % Add run level nodes to ALL lists 
    elseif list{ii}.IsRun()
        hmr.listboxGroupTreeParams.listMaps(views.ALL).names{ii,1}   = ['        ', list{ii}.GetFileName];
        hmr.listboxGroupTreeParams.listMaps(views.ALL).idxs(ii,:) = list{ii}.GetIndexID;
            
        jj=jj+1;
        hmr.listboxGroupTreeParams.listMaps(views.SUBJS).names{jj,1} = ['    ', list{ii}.GetFileName];
        hmr.listboxGroupTreeParams.listMaps(views.SUBJS).idxs(jj,:)  = list{ii}.GetIndexID;

        kk=kk+1;
        hmr.listboxGroupTreeParams.listMaps(views.RUNS).names{kk,1}  = list{ii}.GetName;
        hmr.listboxGroupTreeParams.listMaps(views.RUNS).idxs(kk,:)   = list{ii}.GetIndexID;

        nRuns = nRuns+1;
        
    end
end
