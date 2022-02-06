function [nSubjs, nSess, nRuns] = GenerateGroupDisplayLists()
global maingui

list = maingui.dataTree.DepthFirstTraversalList();
views = maingui.listboxGroupTreeParams.views;
jj=0; hh=0; kk=0; mm=0;
nSubjs = 0;
nSess = 0;
nRuns = 0;
for ii = 1:length(list)
    
    % Add group level nodes only to whole-tree list
    if list{ii}.IsGroup()
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1} = list{ii}.GetName;
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
    
        kk=kk+1;
        maingui.listboxGroupTreeParams.listMaps(views.NOSESS).names{kk,1}  = list{ii}.GetFileName;
        maingui.listboxGroupTreeParams.listMaps(views.NOSESS).idxs(kk,:)   = list{ii}.GetIndexID;
    
    % Add subject level nodes to whole-tree and subject lists
    elseif list{ii}.IsSubj()
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1}   = ['    ', list{ii}.GetName];
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
        
        jj=jj+1;
        maingui.listboxGroupTreeParams.listMaps(views.SUBJS).names{jj,1} = list{ii}.GetName;
        maingui.listboxGroupTreeParams.listMaps(views.SUBJS).idxs(jj,:)  = list{ii}.GetIndexID;
    
        kk=kk+1;
        maingui.listboxGroupTreeParams.listMaps(views.NOSESS).names{kk,1}  = ['    ', list{ii}.GetFileName];
        maingui.listboxGroupTreeParams.listMaps(views.NOSESS).idxs(kk,:)   = list{ii}.GetIndexID;

        nSubjs = nSubjs+1;
        
    % Add session level nodes to whole-tree and session lists
    elseif list{ii}.IsSess()
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1} = ['        ', list{ii}.GetFileName];
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
            
        jj=jj+1;
        maingui.listboxGroupTreeParams.listMaps(views.SUBJS).names{jj,1} = ['    ', list{ii}.GetFileName];
        maingui.listboxGroupTreeParams.listMaps(views.SUBJS).idxs(jj,:)  = list{ii}.GetIndexID;

        hh=hh+1;
        maingui.listboxGroupTreeParams.listMaps(views.SESS).names{hh,1}  = list{ii}.GetFileName;
        maingui.listboxGroupTreeParams.listMaps(views.SESS).idxs(hh,:)   = list{ii}.GetIndexID;
    
        nSess = nSess+1;
        
    % Add run level nodes to ALL lists 
    elseif list{ii}.IsRun()
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1}   = ['            ', list{ii}.GetFileName];
        maingui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
            
        jj=jj+1;
        maingui.listboxGroupTreeParams.listMaps(views.SUBJS).names{jj,1} = ['        ', list{ii}.GetFileName];
        maingui.listboxGroupTreeParams.listMaps(views.SUBJS).idxs(jj,:)  = list{ii}.GetIndexID;

        hh=hh+1;
        maingui.listboxGroupTreeParams.listMaps(views.SESS).names{hh,1}  = ['    ', list{ii}.GetFileName];
        maingui.listboxGroupTreeParams.listMaps(views.SESS).idxs(hh,:)   = list{ii}.GetIndexID;

        kk=kk+1;
        maingui.listboxGroupTreeParams.listMaps(views.NOSESS).names{kk,1}  = ['            ', list{ii}.GetFileName];
        maingui.listboxGroupTreeParams.listMaps(views.NOSESS).idxs(kk,:)   = list{ii}.GetIndexID;

        mm=mm+1;
        maingui.listboxGroupTreeParams.listMaps(views.RUNS).names{mm,1}  = list{ii}.GetFileName;
        maingui.listboxGroupTreeParams.listMaps(views.RUNS).idxs(mm,:)   = list{ii}.GetIndexID;

        nRuns = nRuns+1;
        
    end
end
