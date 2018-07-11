function [pm, pn, dndx, dmde, xl, el, angle]=getROMSMetrics(rho_x,rho_y,coord)
% function [pm, pn, dndx, dmde, xl, el, angle]=getROMSMetrics(rho_x,rho_y,coord)
% Charles James 2017
% Based on code by H. Arango but with angle added in:
%=========================================================================%
%  Copyright (c) 2002-2012 The ROMS/TOMS Group                            %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.txt                           Hernan G. Arango      %
%=========================================================================%
getVarcheck('coord','spherical');
[u,v]=setRho2uvp(rho_x,rho_y);

%radius  = 6371.315;
deg2rad = pi/180.0;

% lon and lat arise from setRho2uvp;
Xr = rho_x;
Yr = rho_y;
Xu = u.lon;
Yu = u.lat;
Xv = v.lon;
Yv = v.lat;

%----------------------------------------------------------------------------
%  Compute grid spacing (meters).
%----------------------------------------------------------------------------

[Lp,Mp] = size(Xr);

L = Lp-1;   Lm = L-1;
M = Mp-1;   Mm = M-1;

dx = zeros(size(Xr));
dy = zeros(size(Xr));

% Compute grid spacing.

if strcmpi(coord,'spherical')            % great circle distances    
%     x=(Xr-mean(Xr(:)))*deg2rad;
%     y=atanh(sin(Yr*deg2rad));
    x=(Xr-mean(Xr(:)))*deg2rad.*cosd(Yr);
    y=(Yr-mean(Yr(:)))*deg2rad;
    dx(2:L,1:Mp) = gcircle(Xu(1:Lm,1:Mp), Yu(1:Lm,1:Mp),                ...
        Xu(2:L ,1:Mp), Yu(2:L ,1:Mp));
    dx(1  ,1:Mp) = gcircle(Xr(1   ,1:Mp), Yr(1   ,1:Mp),                ...
        Xu(1   ,1:Mp), Yu(1   ,1:Mp)).*2.0;
    dx(Lp ,1:Mp) = gcircle(Xr(Lp  ,1:Mp), Yr(Lp  ,1:Mp),                ...
        Xu(L   ,1:Mp), Yu(L   ,1:Mp)).*2.0;
    
    dy(1:Lp,2:M) = gcircle(Xv(1:Lp,1:Mm), Yv(1:Lp,1:Mm),                ...
        Xv(1:Lp,2:M ), Yv(1:Lp,2:M ));
    dy(1:Lp,1  ) = gcircle(Xr(1:Lp,1   ), Yr(1:Lp,1   ),                ...
        Xv(1:Lp,1   ), Yv(1:Lp,1   )).*2.0;
    dy(1:Lp,Mp ) = gcircle(Xr(1:Lp,Mp  ), Yr(1:Lp,Mp  ),                ...
        Xv(1:Lp,M   ), Yv(1:Lp,M   )).*2.0;
    
    dx = dx .* 1000;       % great circle function computes
    dy = dy .* 1000;       % distances in kilometers
else                                      % Cartesian distance
    x=Xr;
    y=Yr;
    dx(2:L,1:Mp) = sqrt((Xu(2:L ,1:Mp) - Xu(1:Lm,1:Mp)).^2 +            ...
        (Yu(2:L ,1:Mp) - Yu(1:Lm,1:Mp)).^2);
    dx(1  ,1:Mp) = sqrt((Xu(1   ,1:Mp) - Xr(1   ,1:Mp)).^2 +            ...
        (Yu(1   ,1:Mp) - Yr(1   ,1:Mp)).^2).*2.0;
    dx(Lp ,1:Mp) = sqrt((Xr(Lp  ,1:Mp) - Xu(L   ,1:Mp)).^2 +            ...
        (Yr(Lp  ,1:Mp) - Yu(L   ,1:Mp)).^2).*2.0;
    
    dy(1:Lp,2:M) = sqrt((Xv(1:Lp,2:M ) - Xv(1:Lp,1:Mm)).^2 +            ...
        (Yv(1:Lp,2:M ) - Yv(1:Lp,1:Mm)).^2);
    dy(1:Lp,1  ) = sqrt((Xv(1:Lp,1   ) - Xr(1:Lp,1   )).^2 +            ...
        (Yv(1:Lp,1   ) - Yr(1:Lp,1   )).^2).*2.0;
    dy(1:Lp,Mp ) = sqrt((Xr(1:Lp,Mp  ) - Xv(1:Lp,M   )).^2 +            ...
        (Yr(1:Lp,Mp  ) - Yv(1:Lp,M   )).^2).*2.0;
end

% Compute inverse grid spacing metrics.

xl=sum(dx(:,1));
el=sum(dy(1,:));

pm = 1.0./dx;
pn = 1.0./dy;

% grid is transposed so d/dxi is second term;
[~, dxdxi]=gradient(x);
[~, dydxi]=gradient(y);
angle = atan2(dydxi,dxdxi);

%----------------------------------------------------------------------------
% Compute inverse metric derivatives.
%----------------------------------------------------------------------------

dndx = zeros(size(Xr));
dmde = zeros(size(Xr));

dndx(2:L,2:M) = 0.5.*(1.0./pn(3:Lp,2:M ) - 1.0./pn(1:Lm,2:M ));
dmde(2:L,2:M) = 0.5.*(1.0./pm(2:L ,3:Mp) - 1.0./pm(2:L ,1:Mm));



end
%%
function dist=gcircle(lon1,lat1,lon2,lat2)
% Adapted from routine written by Pat J. Haley (Harvard University).
%
% svn $Id: gcircle.m 614 2012-05-02 21:52:32Z arango $
%===========================================================================%
%  Copyright (c) 2002-2012 The ROMS/TOMS Group                              %
%    Licensed under a MIT/X style license                                   %
%    See License_ROMS.txt                           Hernan G. Arango        %
%===========================================================================%

%----------------------------------------------------------------------------
% Set often used parameters.
%----------------------------------------------------------------------------

radius  = 6371.315;
deg2rad = pi/180.0;

%----------------------------------------------------------------------------
% Convert to radians.
%----------------------------------------------------------------------------

slon = lon1.*deg2rad;
slat = lat1.*deg2rad;
elon = lon2.*deg2rad;
elat = lat2.*deg2rad;

%----------------------------------------------------------------------------
% Compute distance along great circle (kilometers).
%----------------------------------------------------------------------------

alpha = sin(slat).*sin(elat) + cos(slat).*cos(elat).*cos(elon-slon);

ind = abs(alpha)>1;
alpha(ind) = sign(alpha(ind));

alpha=acos(alpha);
dist=radius.*alpha;

end
%%
function [u,v,psi]=setRho2uvp(lon_rho,lat_rho)
% function [u,v,psi]=setRho2uvp(lon_rho,lat_rho)
% converts from rho grid to u,v and psi grids
% Charles James 2017


[Lp, Mp]=size(lon_rho);

% recaluculate u,v, and psi grids from rho grid;
M=Mp-1;
L=Lp-1;

vind=1:M;
uind=1:L;

u.lon=(lon_rho(uind,:)+lon_rho(uind+1,:))*.5;
u.lat=(lat_rho(uind,:)+lat_rho(uind+1,:))*.5;
v.lon=(lon_rho(:,vind)+lon_rho(:,vind+1))*.5;
v.lat=(lat_rho(:,vind)+lat_rho(:,vind+1))*.5;
psi.lon=(u.lon(:,vind)+u.lon(:,vind+1))*.5;
psi.lat=(u.lat(:,vind)+u.lat(:,vind+1))*.5;

end

