function [xp,yp]=getRho2Bpsi(xr,yr)
% function [xp,yp]=getRho2Bpsi(xr,yr)
% reconstruct boundary psi grid (psi points external to rho) from standard
% rho grid
% Charles James 2017

% linear expantion of rho grid +1 in all directions
[xre,yre]=getGridExpand(xr,yr,[1,1,1,1]);
% get new psi
[xp,yp]=getBpsi2rho(xre,yre);

end