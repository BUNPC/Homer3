function r = checkToolboxes(toolboxes, app)

r = true;

if ~exist('app','var')
    app = '';
end

missing = [];
kk = 1;
for ii=1:length(toolboxes)
    if ~isToolboxAvailable(toolboxes{ii})
        missing(kk) = ii;
        kk=kk+1;
    end
end

if ~isempty(missing)
    msg1 = sprintf('WARNING: The following matlab toolboxes have not been installed:\n');
    msg2 = sprintf('\n');
    msg3 = '';
    msg4 = sprintf('\n');
    if isempty(app)
        msg5 = sprintf('SOME FUNCTIONS MAY NOT WORK PROPERLY.');
    else
        msg5 = sprintf('SOME FUNCTIONS IN %s MAY NOT WORK PROPERLY.', app);
    end
    for jj=1:length(missing)
        if isempty(msg3)
            msg3 = sprintf('%s\n', toolboxes{missing(jj)});
        else
            msg3 = sprintf('%s%s\n', msg3, toolboxes{missing(jj)});
        end
    end
    
    msg = [msg1, msg2, msg3, msg4, msg5];
    menu(msg, 'OK');
    r = false;
end

