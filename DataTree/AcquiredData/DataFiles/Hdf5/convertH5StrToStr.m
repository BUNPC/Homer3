function snew = convertH5StrToStr(s)

snew = '';
if iscell(s) || ischar(s) 
    snew = strtrim_improve(s);
elseif iswholenum(s)
    snew = char(s(:)');  % make sure it's row vector
    snew(snew==0)='';
    snew = strtrim_improve(snew);
end
if iscell(snew)
    snew = [snew{:}];
end


