function [x,y]=getAxis2xy(axlim,closebox)
% function [x,y]=getAxis2xy(axlim,closebox)
% computes coordinates of a box using x and y limits as returned from an
% axis call
% Charles James 2017
getVarcheck('axlim',axis(gca));
getVarcheck('closebox',false);
x=[axlim(1),axlim(1),axlim(2), axlim(2)];
y=[axlim(3),axlim(4),axlim(4), axlim(3)];

if closebox
    x(end+1)=x(1);
    y(end+1)=y(1);
end




end