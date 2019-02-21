function y = isalnum( x )

y = all( (x>='0' & x<='9') | (x>='a' & x<='z') | (x>='A' & x<='Z') );
