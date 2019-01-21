function procStreamSave(filenm, procElem)


fid = fopen(filenm,'w');
for iPanel=1:length(procElem)

    fprintf( fid, '%% %s\n', procElem{iPanel}.type );    
    func = procElem{iPanel}.procInput.func;
    for iFunc=1:length(func)

        fprintf( fid, '@ %s %s %s',...
            func(iFunc).funcName, func(iFunc).funcArgOut, ...
            func(iFunc).funcArgIn );
        for iParam=1:func(iFunc).nFuncParam
            fprintf( fid,' %s', func(iFunc).funcParam{iParam} );
            
            foos = func(iFunc).funcParamFormat{iParam};
            boos = sprintf( foos, func(iFunc).funcParamVal{iParam} );
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
            if ~strcmp(func(iFunc).funcParam{iParam},'*')
                fprintf( fid,' %s %s', foos, boos );
            end
        end
        if func(iFunc).nFuncParamVar>0
            fprintf( fid,' *');
        end
        
        fprintf( fid, '\n' );
        
    end
    fprintf( fid, '\n' );
    
end

fclose(fid);
