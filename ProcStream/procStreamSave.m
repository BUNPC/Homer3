function procStreamSave(filenm,procFunc)


fid = fopen(filenm,'w');

for iFunc=1:length(procFunc)
    fprintf( fid, '@ %s %s %s',...
        procFunc(iFunc).funcName, procFunc(iFunc).funcArgOut, ...
        procFunc(iFunc).funcArgIn );
    for iParam=1:procFunc(iFunc).nFuncParam
        fprintf( fid,' %s', procFunc(iFunc).funcParam{iParam} );

        foos = procFunc(iFunc).funcParamFormat{iParam};
        boos = sprintf( foos, procFunc(iFunc).funcParamVal{iParam} );
        for ii=1:length(foos)
            if foos(ii)==' '
                foos(ii) = '_';
            end
        end
        for ii=1:length(boos)
            if boos(ii)==' '
                boos(ii) = '_';
            end
        end
        if ~strcmp(procFunc(iFunc).funcParam{iParam},'*')
            fprintf( fid,' %s %s', foos, boos );        
        end
    end
    if procFunc(iFunc).nFuncParamVar>0
        fprintf( fid,' *');
    end

    fprintf( fid, '\n' );
end

fclose(fid);
