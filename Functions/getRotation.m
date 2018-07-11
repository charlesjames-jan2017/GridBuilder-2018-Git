function [xr,yr]=getRotation(x,y,x0,y0,theta)
% function [xr,yr]=getRotation(x,y,x0,y0,theta)
% Charles James 2018
% rotates coordinates by theta (in radians)

xr=x0+cos(theta).*(x-x0)-sin(theta).*(y-y0);
yr=y0+sin(theta).*(x-x0)+cos(theta).*(y-y0);

end