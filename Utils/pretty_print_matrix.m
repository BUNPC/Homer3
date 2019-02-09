function pretty_print_matrix(M, indentrow, fmt)

if ~exist('indentrow','var')
    indentrow = 0;
end
if ~exist('fmt','var')
    fmt = sprintf('%%0.4f');
end

nr = size(M,1);
nc = size(M,2);

for ii=1:nr
    fprintf(blanks(indentrow));
    for jj=1:nc
        
        if M(ii,jj)>=0 && M(ii,jj)<10
            fprintf(['    ', fmt, ' '], M(ii,jj));
        elseif (M(ii,jj)>=10 && M(ii,jj)<100) || (M(ii,jj)<0 && M(ii,jj)>-10)
            fprintf(['   ', fmt, ' '], M(ii,jj));
        elseif (M(ii,jj)>=100 && M(ii,jj)<1000) || (M(ii,jj)<=-10 && M(ii,jj)>-100)
            fprintf(['  ', fmt, ' '], M(ii,jj));
        elseif (M(ii,jj)>=1000) || (M(ii,jj)<=-100 && M(ii,jj)>-1000)
            fprintf([' ', fmt, ' '], M(ii,jj));
        elseif M(ii,jj)<=-1000 
            fprintf([' ', fmt, ' '], M(ii,jj));
        end
        
    end
    fprintf('\n');
end
