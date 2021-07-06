function hm = MessageBox(msg, title, options)

if nargin<2
    title = 'MessageBox';
end
if ~exist('options','var')
    options = '';
end
if iscell(msg)
    msg = [msg{:}];
end 

% Display message box
hm = msgbox(msg, title);
if optionExists(options, 'nowait')
    return
end

% Wait for user to respond before exiting
waitForGui(hm);



