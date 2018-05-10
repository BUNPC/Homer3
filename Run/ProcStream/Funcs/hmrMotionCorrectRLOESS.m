function dod = hmrMotionCorrectRLOESS(dod, t, span, turnon)
% Meryem Yucel, Oct, 2017
% span = 0.02 (default)
% Added turn on/off option Meryem Nov 2017
if exist('turnon')
   if turnon==0
   return;
   end
end


if span>0
    for i=1:size(dod,2)
    dod(:,i)=smooth(t,dod(:,i),span,'rloess');
    end
elseif span==-1
    return
end