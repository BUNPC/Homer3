function waitForGui(h)
if nargin==0
    return;
end

timer = tic;
guiname = get(h, 'name');
fprintf('%s GUI is busy...\n', guiname);
while ishandle(h)
    if mod(toc(timer), 5)>4.5
        fprintf('%s GUI is busy...\n', guiname);
        timer = tic;
    end
    pause(.1);
end

