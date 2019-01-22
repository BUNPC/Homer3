function procStreamSave(filenm, procElem)
fid = fopen(filenm,'w');
for iPanel=1:length(procElem)
    fprintf( fid, '%% %s\n', procElem{iPanel}.type );    
    func = procElem{iPanel}.procStream.input.func;
    for iFunc=1:length(func)

        fprintf( fid, '@ %s %s %s',...
            func(iFunc).funcName, func(iFunc).argOut, ...
            func(iFunc).argIn );
        for iParam=1:func(iFunc).nParam
            fprintf( fid,' %s', func(iFunc).param{iParam} );
            
            foos = func(iFunc).paramFormat{iParam};
            boos = sprintf( foos, func(iFunc).paramVal{iParam} );
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
            if ~strcmp(func(iFunc).param{iParam},'*')
                fprintf( fid,' %s %s', foos, boos );
            end
        end
        if func(iFunc).nParamVar>0
            fprintf( fid,' *');
        end
        fprintf( fid, '\n' );        
    end
    fprintf( fid, '\n' );
end
fclose(fid);
