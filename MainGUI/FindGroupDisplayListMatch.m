function iList = FindGroupDisplayListMatch(iView)
% 
% FindGroupDisplayListMatch finds the closest match to the 
% dataTree's current processing element in the MainGUI's current 
% group listbox view.
%

global maingui

iList = [];

% Get the group index of current list selection
groupIdx = maingui.dataTree.currElem.GetIndexID();
iG = groupIdx(1); 
iS = groupIdx(2); 
iR = groupIdx(3);

% 
% 6 states, 3 transitional events
% 
% In the following specification, R means run, S means eubject, G means group . Note that 
% every group processing element is associated with a group, subject and run ID. 
% 
% 6 states are 
% 
%       Listbox Entry  |  Processing Level
%       ---------------|------------------
%    1.         R      |      R
%    2.         R      |      S
%    3.         R      |      G
%    4.         S      |      S
%    5.         S      |      G
%    6.         G      |      G
%               
% 3 transitional user actions (via View menu --> Group View Type) :  
%
%    1. Gv: Group   view 
%    2. Sv; Subject view
%    3. Rv: Runs    view
%
% 18 Possible state transitions:
%    
%    1 . RR  == Rv ==> RR
%    2 . RR  == Sv ==> RR
%    3 . RR  == Gv ==> RR
%
%    4 . RS  == Rv ==> RS
%    5 . RS  == Sv ==> SS
%    6 . RS  == Gv ==> SS
%
%    7 . RG  == Rv ==> RG
%    8 . RG  == Sv ==> SG
%    9 . RG  == Gv ==> GG
%
%    10. SS  == Rv ==> RS
%    11. SS  == Sv ==> SS
%    12. SS  == Gv ==> SS
%
%    13. SG  == Rv ==> RG
%    14. SG  == Sv ==> SG
%    15. SG  == Gv ==> GG
%
%    16. GG  == Rv ==> RG
%    17. GG  == Sv ==> SG
%    18. GG  == Gv ==> GG
% 

% This simple algorithm implements the 18 state stransitions. 
% Basically it just finds the closest match to the group index
% of the dataTree.currElem (i.e., the index of the actual current 
% group element) in the current display list (i.e. the current
% listbox entries)
listIdxs = maingui.listboxGroupTreeParams.listMaps(iView).idxs;
for ii=1:length(listIdxs)
    if listIdxs(ii,1)>=iG && listIdxs(ii,2)>=iS && listIdxs(ii,3)>=iR
        iList = ii;
        break;
    end
end

