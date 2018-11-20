function s1=copyStructFieldByField(s1,s2)

if ~strcmp(class(s1),class(s2))
    if ~isobject(s1) && ~isstruct(s2)
        if ~isstruct(s1) && ~isobject(s2)
            return;
        end
    end
end

if isstruct(s1) || isobject(s1)
    
    if ~isstruct(s2) && ~isobject(s2)
        return;
    end
    
    for jj=1:length(s2)
        fields = fieldnames(s2(jj));
        for ii=1:length(fields)
            field_class = eval(sprintf('class(s2(jj).%s)',fields{ii}));
            if ~isproperty(s1,fields{ii}) || length(s1)<jj
                if isobject(s1)
                    continue;
                end
                if strcmp(field_class,'cell')
                    field_arg='{}';
                else
                    field_arg='[]';
                end
                eval(sprintf('s1(jj).%s = %s(%s);',fields{ii},field_class,field_arg));
            end
            eval(sprintf('s1(jj).%s = copyStructFieldByField(s1(jj).%s, s2(jj).%s);', fields{ii}, fields{ii}, fields{ii}));
        end
    end
    
else
    
    s1 = s2;
    
end
