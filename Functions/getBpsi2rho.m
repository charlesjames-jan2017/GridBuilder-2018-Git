function [xr,yr]=getBpsi2rho(xp,yp)
% function [xr,yr]=getBpsi2rho(xp,yp)
% convert from boundary psi grid (psi points external to rho) to standard
% rho grid
% Charles James 2017
[n,m]=size(xp);

% for any grid property;
x1=xp(1:end-1,1:end-1);
x2=xp(1:end-1,2:end);
x3=xp(2:end,2:end);
x4=xp(2:end,1:end-1);
Mx=[x1(:) x2(:) x3(:) x4(:)];
xr=reshape(mean(Mx,2),[n-1 m-1]);

% add option to do x and y coordinates
if nargin>1
y1=yp(1:end-1,1:end-1);
y2=yp(1:end-1,2:end);
y3=yp(2:end,2:end);
y4=yp(2:end,1:end-1);
My=[y1(:) y2(:) y3(:) y4(:)];
yr=reshape(mean(My,2),[n-1 m-1]);
end

end