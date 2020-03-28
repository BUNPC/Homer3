function [h, p1, p2] = line2(p1, p2, k, gridsize)

%
% Usage: 
%
%      h = line2(p1, p2) 
%      h = line2(p1, p2, k)
%
% Description:  
% 
%      Draw line segment between two points p1 and p2 in the
%      current axes. The line segment is cropped equally at either end 
%      by k percent relative to the total length of line segment
%      p1-p2. If the percentage argument is not passed, it is
%      calculated based on the length of p1-p2 relative to axes grid  
%      width and height. 
%                
%      This function is useful when line segment end points have text 
%      labels that have to be clearly visible; i.e., not be obscured 
%      by the line segment itself. (This can especially be a problem 
%      when multiple segments are emanating from a single end point.) 
%               
% Example 1:    
%  
%      Draw line segment between p1 and p2, cropping each end by
%      20% of total segment length; i.e. draw segment between points 
%      [12,0,0] and [18,0,0].  
%
%      p1 = [10,0,0];
%      p2 = [20,0,0];
%      h = line2(p1,p2,20);
%
% Example 2:    
%   
%      Draw line segment between p1 and p2 (no cropping)
%
%      p1 = [10,0,0];
%      p2 = [20,0,0];
%      h = line2(p1,p2,0);
%
% Author: Jay Dubb, jdubb@bu.edu
% Date:   11/30/2018
% 

% Save initial values of p1 and p2
p1_0 = p1;
p2_0 = p2;

if isempty(k)
    len_edge = dist3(p1_0, p2_0);
    
    sx = gridsize{1}(2) - gridsize{1}(1);
    sy = gridsize{2}(2) - gridsize{2}(1);
    sz = gridsize{3}(2) - gridsize{3}(1);
    len_griddiag = sqrt(sx^2+sy^2+sz^2);
    
    if len_edge/len_griddiag >= 1.00
        percent_offset = 0;
    elseif len_edge/len_griddiag <= 0.05
        percent_offset = 0;
    elseif len_edge/len_griddiag >= 0.95
        percent_offset = 2;
    elseif len_edge/len_griddiag > 0.06 && len_edge/len_griddiag < 0.07
        percent_offset = len_griddiag/len_edge;
    elseif len_edge/len_griddiag > 0.4
        percent_offset = 3;
    else
        percent_offset = 5;
    end
else
    percent_offset = k;
end

p1 = points_on_line(p1_0, p2_0, percent_offset/100);
p2 = points_on_line(p2_0, p1_0, percent_offset/100);
h = line([p1(1), p2(1)], [p1(2), p2(2)]);


