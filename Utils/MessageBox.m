function MessageBox(msg, title, hp)

if nargin<2
    title = 'MessageBox';
end
if nargin<3
    hp = gcf;
end

% Save original units of parent figure
uf = get(hp, 'units');

% Display message box
hm = msgbox(msg, title);

% set(hm, 'visible','off');
% 
% % Set parent and child figures to same units
% set(hm, 'units', 'pixels');
% set(hp, 'units', 'pixels');
% 
% pm = get(hm, 'position');
% pf = get(hp, 'position');
% 
% % Set new position for our message box in relation to parent figure
% px = (pf(1)+pf(3))-pf(3)*.8;
% py = (pf(2)+pf(4))-pf(4)*.2;
% set(hm, 'position',[px, py, pm(3), pm(4)]);
% set(hm, 'visible','hmon');


% p = get(hm,'position');
% nchar = getMaxLineLength(msg);
% if nchar<40
%     p(3) = p(3)+.3*p(3);
%     hc = get(hm,'children');
% end
% set(hm, 'position',p);


% Set parent figure back to previous units
set(hm, 'units', uf);

% Wait for user to respond before exiting
t = 0;
while ishandles(hm)
    t=t+1;
    pause(.2);
    if mod(t,30)==0
        fprintf('Waiting for user responce, t = %d ticks\n', t);
    end
end




% -------------------------------------------------------------
function maxlen = getMaxLineLength(msg)
maxlen = 0;
lines = str2cell(msg);
for ii=1:length(lines)
    if length(lines{ii})>maxlen
        maxlen=length(lines{ii});
    end
end


