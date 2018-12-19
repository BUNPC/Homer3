function [p1,p2] = extractButtondownPoints()

p1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
p2 = get(gca,'CurrentPoint');

count=0;
if all(p1==p2) & all(finalRect(3:4)==0)
    dispSelectedPts(p1,p2,finalRect,count);
    return;
end

maxiter = 10;
while all(p1==p2)
    pause(.01);
    count=count+1;
    if count==maxiter
        break;
    end
    p2 = get(gca,'CurrentPoint');
end

dispSelectedPts(p1,p2,finalRect,count);


% ----------------------------------------------------------
function dispSelectedPts(p1,p2,finalRect,count)
fprintf('finalRect: [%0.2f, %0.2f, %0.2f, %0.2f]\n', finalRect(1), finalRect(2), finalRect(3), finalRect(4));
fprintf('p1:        [%0.2f, %0.2f]\n', p1(1), p1(2));
fprintf('p2:        [%0.2f, %0.2f]\n', p2(1), p2(2));
fprintf('count:     %d\n', count);
