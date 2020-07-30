function MessageBox(msg, title)

if nargin<2
    title = 'MessageBox';
end

% Display message box
hm = msgbox(msg, title);

% Wait for user to respond before exiting
t = 0;
while ishandles(hm)
    t=t+1;
    pause(.2);
    if mod(t,30)==0
        fprintf('Waiting for user responce, t = %d ticks\n', t);
    end
end

