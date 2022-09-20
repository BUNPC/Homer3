function hm = MessageBox(msg, title, options)

timelimit = 10000;

if nargin<2
    title = 'MessageBox';
end
if ~exist('options','var')
    options = '';
end
 

% Display message box
hm = msgbox(msg, title);
%resizeBox(hm, msg, title)
 
if optionExists(options, 'nowait')
    return
end
if optionExists(options, 'timelimit')
    % Wait 5 seconds for user to click OK before exitng
    timelimit = 25;  
end

% Wait for user to respond before exiting
t = 0;
while ishandles(hm) && t<timelimit
    t = t+1;
    pause(.2);
    if mod(t,30)==0
        fprintf('Waiting for user responce, t = %d ticks\n', t);
    end
end
if ishandle(hm)
    close(hm);
end



% ----------------------------------------------------
function resizeBox(hm, msg, title)
u = get(hm, 'units');
p = get(hm, 'position');
fx = guiUnitConversion(u,'characters');
offset = 34;

k = 1;
if ispc()
    k = 1.4;
elseif ismac()
    k = 1.2;
end
if length(title) < length(msg)
    k = 1;
end

s(1) = k*length(msg)+offset;
s(2) = k*length(title)+offset;
sm = max(s);

if sm > p(3)*fx
    set(hm, 'position',[p(1), p(2), sm/fx, p(4)]);
end


