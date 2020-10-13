function [p1, p2, err] = extractButtondownPoints()

p1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
p2 = abs(get(gca,'CurrentPoint'));

fprintf('Initial ...\n');
dispSelectedPts(p1, p2, finalRect);

[err, p1, p2] = errorCheck(p1, p2, finalRect);
if err<0
    dispSelectedPts(p1,p2,finalRect);
    return;
end

count=0;
maxiter = 10;
while all(p1==p2)
    pause(.01);
    count=count+1;
    if count==maxiter
        break;
    end
    p2 = get(gca,'CurrentPoint');
end

fprintf('Modified ...\n');
dispSelectedPts(p1, p2, finalRect);
fprintf('\n');



% ----------------------------------------------------------
function [err, p1, p2] = errorCheck(p1, p2, finalRect)

% NOTE - bug alert! Oct 2, 2020, JD:
% This function was added to check the coherence of a user button down 
% selection in GUI axes. There seems to be a bug in Matlab R2020a where 
% you select an axes region, rbbox correctly reports that a rectangle was 
% selected - in other words, the 3rd number in finalRect is > 0 - BUT p2 
% is equal to p1 (meaning only a point has been selected), contradicting 
% what rbbox shows. This problem does not exist in say R2017b. So to 
% compensate for this bug we check finalRect against {p1,p2} and if 
% finalRect is showing a size > 0 then we add the comparable size to p2. 
%
err = 0;

u = get(gcf, 'units');
u0 = get(gcf, 'units');
set(gca, 'units',u);
p = get(gca, 'position');
xlim = get(gca, 'xlim');

axesSize_guiUnits  = p(3);
axesSize_userUnits = xlim(2) - xlim(1);

scalingFactor = axesSize_userUnits / axesSize_guiUnits;

offset = 0;
if finalRect(1)<p(1)
    offset = abs(finalRect(1) - p(1));
    p2(:) = xlim(1);
end
rectSize_finalRect    = scalingFactor * (finalRect(3) - offset);
% rectSize_finalRect    = scalingFactor * finalRect(3);
rectSize_CurrentPoint = p2(1) - p1(1);

if all(p1==0) & all(p2==0)
    err = -1;
    set(gca, 'units',u0);
    return
end


if all(p1(1)==p2(1)) & p1(1)==p1(2)
    farSidePosX = (scalingFactor*abs(finalRect(1)-p(1)) + scalingFactor*finalRect(3));
    nearSidePosX = scalingFactor*abs(finalRect(1)-p(1));
    if abs(p1(1) - farSidePosX) < 1
        p1(:,1) = p2(1) - rectSize_finalRect;
    elseif abs(p1(1) - nearSidePosX) < 1
        p2(:,1) = p1(1) + rectSize_finalRect;
    end 
elseif p1(1) <= p2(1)
    p2(:,1) = p1(1) + rectSize_finalRect;
else
    p1(:,1) = p2(1) + rectSize_finalRect;
end

fprintf('Selection rectangle from finalRect    :  %0.1f\n', rectSize_finalRect);
fprintf('Selection rectangle from CurrentPoint :  %0.1f\n', rectSize_CurrentPoint );

set(gca, 'units',u0);



% ----------------------------------------------------------
function dispSelectedPts(p1, p2, finalRect)
u = get(gcf, 'units');
u0 = get(gcf, 'units');
set(gca, 'units',u);
p = get(gca, 'position');
xlim = get(gca, 'xlim');

fprintf('axes size:  [%0.2f, %0.2f, %0.2f, %0.2f]\n', p(1), p(2), p(3), p(4));
fprintf('axes xlim:  [%0.2f, %0.2f]\n', xlim(1), xlim(2));
fprintf('finalRect: [%0.2f, %0.2f, %0.2f, %0.2f]\n', finalRect(1), finalRect(2), finalRect(3), finalRect(4));
fprintf('p1:        [%0.2f, %0.2f]\n', p1(1), p1(2));
fprintf('p2:        [%0.2f, %0.2f]\n', p2(1), p2(2));

set(gca, 'units',u0);




