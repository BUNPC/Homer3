function waitForGui(h, quiet)
if nargin==0
    return;
end
if nargin < 2
    quiet = 0;
end

set(h, 'visible','on');

timer = tic;
guiname = get(h, 'name');
if ~quiet
    fprintf('%s GUI is busy...\n', guiname);
end
while ishandle(h)
    if mod(toc(timer), 5)>4.5
        if ~quiet
            fprintf('%s GUI is busy...\n', guiname);
        end
        timer = tic;
    end
    pause(.1);
end

