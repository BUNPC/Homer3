function  s = strtrim_improve(s0)
%             
% strtrim handles only a limited number of whitespace types.
% But does NOT handle 0 for example. This function turns all
% whitespaces including 0 to plain old spaces which strtrim
% does handle.
%
% strtrim_improve also handles cell string arrays unlike strtrim
%
if ~iscell(s0)
    s = {s0};
else
    s = s0;
end

for ii=1:length(s)
    s{ii}(s{ii}<33) = ' ';
    
    % Feed the digeteable new string to strtrim.
    s{ii} = strtrim(s{ii});
end

if ~iscell(s0)
    s = s{1};
end

