function err = procstreamOrderCheckDlg(elem)
    % Check the processing stream order
    [fn_error, missing_args, prereqs] = elem.CheckProcStreamOrder();
    if isa(fn_error, 'FuncCallClass')
        l1 = sprintf('The following function: %s', fn_error.nameUI);
        l2 = sprintf('cannot run because of unavailable input(s) %s.\n', cell2str(missing_args));
        if ~isempty(prereqs)
           l3 = sprintf('Add one of the following prerequisite functions to the processing stream:\n%s', strtrim(prereqs));
        else
           l3 = 'Ensure that a function which outputs the necessary inputs appears before the function in the processing stream.'; 
        end
        choice = questdlg({l1, l2, l3}, ...
        'Invalid Processing Stream', ...
        'Continue Anyway','Cancel', 'Cancel');
        switch choice
            case 'Continue Anyway'
                err = 0;
            case 'Cancel'
                err = -1;
            otherwise
                err = -1;
        end
    else
       err = 0; 
    end
end