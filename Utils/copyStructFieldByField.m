function s1=copyStructFieldByField(s1,s2)

if ~strcmp(class(s1),class(s2)) 
    if ~(isa(s1,'handle') && ~isa(s2,'struct'))
        if ~(isa(s1,'struct') && ~isa(s2,'handle'))
            return;
        end
    end
end

if isa(s1,'struct') || isa(s1,'handle')

    fields = fieldnames(s2);
    for ii=1:length(fields)
        if isempty(s1)
            s1 = struct();
        end
        field_class = eval(sprintf('class(s2.%s)',fields{ii}));
        if ~isproperty(s1,fields{ii})
            if strcmp(field_class,'cell')
                field_arg='{}';
            else
                field_arg='[]';
            end
            eval(sprintf('s1.%s = %s(%s);',fields{ii},field_class,field_arg));
        end
        eval(sprintf('s1.%s = copyStructFieldByField(s1.%s,s2.%s);',fields{ii},fields{ii},fields{ii}));
    end

else

    s1 = s2;

end
