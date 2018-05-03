function [G, S, R] = procStreamPreParse(fid_or_str, procElem)

T = textscan(fid_or_str,'%s');
if isempty(T{1})
    return;
end

Sections = findSections(T{1});
if ischar(fid_or_str)
    if exist('procElem','var') && ~isempty(procElem)
        for ii=1:length(Sections)
            if ~strcmp(Sections{ii}{2}, 'group') && ~strcmp(Sections{ii}{2}, 'subj') && ~strcmp(Sections{ii}{2}, 'run')
                switch(procElem.type)
                    case 'group'
                        Sections{ii} = [{'%'}, {'group'}, Sections{ii}];
                    case 'subj'
                        Sections{ii} = [{'%'}, {'subj'}, Sections{ii}];
                    case 'run'
                        Sections{ii} = [{'%'}, {'run'}, Sections{ii}];
                end                
            end
        end
    end
end
[G, S, R] = consolidateSections(Sections);




% ---------------------------------------------------------------------
function Sections = findSections(T)

% Function to extract the 3 proc stream sections - group, subj, and run -
% from a processing stream config cell array.

n=length(T);
Sections={};
kk=1;
ii=1;
while ii<=n
    if T{ii}=='%'
        if (ii+1<=n) & (strcmp(T{ii+1},'group') | strcmp(T{ii+1},'subj') | strcmp(T{ii+1},'run') | T{ii+1}=='@')
            Sections{kk}{1} = T{ii};
            jj=2;
            for mm=ii+1:n
                Sections{kk}{jj} = T{mm};
                jj=jj+1;
                if T{mm}=='%'
                    if (mm+1<=n) & (strcmp(T{mm+1},'group') | strcmp(T{mm+1},'subj') | strcmp(T{mm+1},'run'))
                        break;
                    end
                end
            end
            kk=kk+1;
            ii=mm;
            continue;
        end
    elseif T{ii}=='@'
        Sections{kk}{1} = T{ii};
        jj=2;
        for mm=ii+1:n
            Sections{kk}{jj} = T{mm};
            jj=jj+1;
            if T{mm}=='%'
                if (mm+1<=n) & (strcmp(T{mm+1},'group') | strcmp(T{mm+1},'subj') | strcmp(T{mm+1},'run'))
                    break;
                end
            end
        end
        kk=kk+1;
        ii=mm;
        continue;
    end
    ii=ii+1;
end


% ---------------------------------------------------------------------
function [G, S, R] = consolidateSections(Sections)

% This functions allows the functions for a run, subject or group
% to be scattered. That is, you can multiple group, subject or run
% sections; they'll be consolidated by this function into one group, 
% subject and run sections 

G={};
S={};
R={};
jj=1; kk=1; ll=1;
for ii=1:length(Sections)
    if Sections{ii}{1} ~= '%'
        Sections{ii} = [{'%','run'},Sections{ii}];
    end
    if Sections{ii}{1} == '%' && (~strcmp(Sections{ii}{2},'group') && ~strcmp(Sections{ii}{2},'subj') && ~strcmp(Sections{ii}{2},'run'))
        Sections{ii} = [{'%','run'},Sections{ii}];
    end
    
    if Sections{ii}{1} == '%' && strcmp(Sections{ii}{2},'group')
        if isempty(G)
            G = Sections{ii};
        else
            G = [G(1:end) Sections{ii}{3:end}];
        end
    end 
    if Sections{ii}{1} == '%' && strcmp(Sections{ii}{2},'subj')
        if isempty(S)
            S = Sections{ii};
        else
            S = [S(1:end) Sections{ii}(3:end)];
        end
    end
    if Sections{ii}{1} == '%' && strcmp(Sections{ii}{2},'run')
        if isempty(R)
            R = Sections{ii};
        else
            R = [R(1:end) Sections{ii}(3:end)];
        end
    end    
end





