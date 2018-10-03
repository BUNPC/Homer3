function diffvars(v1,v2,v1name,v2name)

if nargin==2
    v1name = inputname(1);
    v2name = inputname(2);
end
if isempty(v1name)
    v1name = 'v1';
end
if isempty(v2name)
    v2name = 'v2';
end

logger = LogClass();
varcmp(v1, v2, v1name, v2name, logger);
clear logger;


% --------------------------------------------------------------
function varcmp(v1, v2, v1name, v2name, logger)

if nargin==2
    v1name = inputname(1);
    v2name = inputname(2);
end
if isempty(v1name)
    v1name = 'v1';
end
if isempty(v2name)
    v2name = 'v2';
end

if ndims(v1) ~= ndims(v2)
    logger.Write(sprintf('%s ~= %s: ndims\n', v1name, v2name));
    return;
elseif ~all(size(v1) == size(v2))
    logger.Write(sprintf('%s ~= %s: size\n', v1name, v2name));
    return;
elseif ~strcmp(class(v1), class(v2))
    logger.Write(sprintf('%s ~= %s: class\n', v1name, v2name));
    return;
elseif length(v1(:))>20
    if ~isequaln(v1,v2)
        logger.Write(sprintf('%s ~= %s\n', v1name, v2name));
    end
    return;
end


kk=0;
if isbasictype(v1)
    
    for ii=1:length(v1(:))
        if ~isequaln(v1(ii),v2(ii))
            if kk>20
                continue;
            end
            logger.Write(sprintf('%s(%d) ~= %s(%d)\n', v1name, ii, v2name, ii));
            kk=kk+1;
        end
    end
    
elseif iscell(v1)
    
    for ii=1:length(v1(:))
        if ~isequal(v1{ii},v2{ii})
            if kk>20
                continue;
            end
            logger.Write(sprintf('%s{%d} ~= %s{%d}\n', v1name, ii, v2name, ii));
            kk=kk+1;
        end
    end
    
else
    
    fields = unique([propnames(v1); propnames(v2)]);
    for ii=1:length(v1(:))
        for jj=1:length(fields)
            if ~isproperty(v2(ii),fields{jj})
                if kk>20
                    continue;
                end
                logger.Write(sprintf('%s(%d) ~= %s(%d): field %s exists in %s(%d) but not %s(%d)\n', ...
                         v1name, ii, v2name, ii, fields{jj}, v1name, ii, v2name, ii));
                kk=kk+1;
            elseif ~isproperty(v1(ii),fields{jj})
                if kk>20
                    continue;
                end
                logger.Write(sprintf('%s(%d) ~= %s(%d): field %s exists in %s(%d) but not %s(%d)\n', ...
                         v1name, ii, v2name, ii, fields{jj}, v2name, ii, v1name, ii));
                kk=kk+1;
            else
                if v1name(end)==')'
                    eval( sprintf('varcmp(v1(%d).%s, v2(%d).%s, ''%s.%s'', ''%s.%s'', logger);', ...
                        ii, fields{jj}, ii, fields{jj}, v1name, fields{jj}, v2name, fields{jj}) );
                else
                    eval( sprintf('varcmp(v1(%d).%s, v2(%d).%s, ''%s(%d).%s'', ''%s(%d).%s'', logger);', ...
                        ii, fields{jj}, ii, fields{jj}, v1name, ii, fields{jj}, v2name, ii, fields{jj}) );
                end
            end
        end
    end
    
end




