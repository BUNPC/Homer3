function y = isalnum( x )
y = false;
if isempty(x)
    return;
end
y = all( (x>='0' & x<='9') | (x>='a' & x<='z') | (x>='A' & x<='Z') );
