function pcoef=getDepthSign(x,y,z)
% check sign of bathymetry - returns pcoef=-1 if negative pcoef=1 if positive
% get a relevant ETOPO estimate of depths in area
% Charles James 2017
[Dglob,Xglob,Yglob]=getDefaultBathymetry([min(x(:)) max(x(:)) min(y(:)) max(y(:))],2);
BathyInterpolant=griddedInterpolant(Xglob,Yglob,Dglob);
ZB=BathyInterpolant(x,y);
% find the points for which ZB is greater than 3 m (i.e. under water!)
ind=~isnan(ZB)&(ZB>3);
% best fit slope should be linearish
p=polyfit(ZB(ind),z(ind),1);
% if slope is negative assume input zbathy is negative down and fix
% Interpolant
pcoef=sign(p(1));
end

