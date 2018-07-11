function setGridCreate(grid)
% function setGrid(grid)
% use ROMS naming convention for verticies (psi points) but redefine N,M
% note ROMS psi grid is usually only interior verticies but as we will
% also track boundary veritices so size of psi grid is [N M] rather than
% [N-2 M-2], ROMS rho grid being number of cells [N-1 M-1];
% can be called with existing grid to just set GridBuilder to update
% state assuming grid.x grid.y is correct.
% Charles James (2017)
% Incorporates code from Charles Denham's Seagrid: rect2grid.m and fps.m

corner=getGUIData('corner');
side=getGUIData('side');
GridType=getGUIData('GridType');

getVarcheck('grid',[]);
if ~isempty(grid)
    recompute=false;
else
    recompute=true;
end

if recompute
    grid=getGUIData('grid');
    
    % generate or regenerate psi grid
    setWatch('on');
    
    % total number of psi verticies
    m=grid.m;
    n=grid.n;
    xc=[corner.x];
    yc=[corner.y];
    
    N=[m n m n];
    for iside=1:4
        cside=side(iside);
        xs=xc(iside);
        ys=yc(iside);
        if iside==4
            xe=xc(1);
            ye=yc(1);
        else
            xe=xc(iside+1);
            ye=yc(iside+1);
        end
        %cti=s;
        cti=linspace(0,1,N(iside));
        switch GridType
            case 'Fixed'
                if ~isempty(cside.x)
                    z0=cside.x+1i*cside.y;
                else
                    z0=[xs;xe]+1i*[ys;ye];
                end
                N0=length(z0);
                zi=interp1(linspace(0,1,N0),z0,cti);
            case 'Orthogonal'                
                % create straight lines in mercator space
                [xm,ym]=getMercatorCoord([xs,xe],[ys,ye],'C2M');               
                z0=[xm(1);xm(2)]+1i*[ym(1);ym(2)];                    
                N0=length(z0);
                zi=interp1(linspace(0,1,N0),z0,cti);
                [xi,yi]=getMercatorCoord(real(zi),imag(zi),'M2C');
                zi=xi+1i*yi;
            otherwise
                if isfield(cside.control,'handle')
                    xcon=cside.control.x;
                    ycon=cside.control.y;
                    xsp=[xs;xcon(:);xe];
                    ysp=[ys;ycon(:);ye];
                else
                    xsp=[xs;xe];
                    ysp=[ys;ye];
                end
                
                zt=xsp+1i*ysp;
                ct=linspace(0,1,length(zt));
                sl=diff(zt(:))./diff(ct(:));
                pp=spline(ct(:),[sl(1);zt(:);sl(end)]);
                ppt=ppval(pp,cti);
                dist=[0,cumsum(abs(diff(ppt)))];
                dist=dist/max(dist);
                sl=diff(ppt(:))./diff(dist(:));
                pp=spline(dist(:),[sl(1);ppt(:);sl(end)]);
                zi=ppval(pp,cti);
                
        end
        side(iside).x=real(zi);
        side(iside).y=imag(zi);
    end
    
    
    xp=[side.x];
    yp=[side.y];
    % remove duplicate points at end of each side
    delind=cumsum([m n m n]);
    xp(delind)=[];
    yp(delind)=[];
    
    if strcmpi(GridType,'Orthogonal')
        % if we've moved corners and have a new boundary, we will do our
        % best
        [xp,yp]=getMercatorCoord(xp,yp,'C2M');
    end
    [uu,vv,grid.error]=getBpsi2grid(xp,yp,m,n);
    if strcmpi(GridType,'Orthogonal')
        [uu,vv]=getMercatorCoord(uu,vv,'M2C');
    end
    % fix spacing
    sm=linspace(0,1,m);
    sn=linspace(0,1,n);
    
    sspace=[side.spacing];
    active=[sspace.active];
    
    zz=uu+1i*vv;
    
    if active(1)
        sp1=getSpacerInfo(side,1);
        s1=scalevar([0;cumsum(abs(diff(zz(:,1))))]);
    elseif active(3)
        sp1=getSpacerInfo(side,3);
        s1=scalevar([0; cumsum(abs(diff(zz(:,end))))]);
        s1=1-s1(end:-1:1);
    end
    if active(2)
        sp2=getSpacerInfo(side,2);
        s2=scalevar([0 cumsum(abs(diff(zz(end,:))))]).';
    elseif active(4)
        sp2=getSpacerInfo(side,4);
        s2=scalevar([0 cumsum(abs(diff(zz(1,:))))]).';
        s2=1-s2(end:-1:1);
    end
    
    uu=getspline(s1,uu,sm).';
    vv=getspline(s1,vv,sm).';
    uu=getspline(s2,uu,sn).';
    vv=getspline(s2,vv,sn).';
    
    s1=scalevar(sp1);
    s2=scalevar(sp2);
    if active(3)
        s1=1-s1(end:-1:1);
    end
    if active(4)
        s2=1-s2(end:-1:1);
    end
    
    uu=getspline(sm,uu,s1).';
    vv=getspline(sm,vv,s1).';
    uu=getspline(sn,uu,s2).';
    vv=getspline(sn,vv,s2).';
    
    grid.x=uu;
    grid.y=vv;
else
    corner(1).x=grid.x(1,1);
    corner(1).y=grid.y(1,1);
    corner(2).x=grid.x(end,1);
    corner(2).y=grid.y(end,1);
    corner(3).x=grid.x(end,end);
    corner(3).y=grid.y(end,end);
    corner(4).x=grid.x(1,end);
    corner(4).y=grid.y(1,end);
    setGUIData(corner);
end

%update new sides;
side(1).x=grid.x(:,1)';side(1).y=grid.y(:,1)';
side(2).x=grid.x(end,:);side(2).y=grid.y(end,:);
side(3).x=grid.x(end:-1:1,end)';side(3).y=grid.y(end:-1:1,end)';
side(4).x=grid.x(1,end:-1:1);side(4).y=grid.y(1,end:-1:1);

[x_rho,y_rho]=getBpsi2rho(grid.x,grid.y);
[pm, pn, dndx, dmde, xl, el, angle]=getROMSMetrics(x_rho,y_rho,grid.coord);
grid.pn=pn;
grid.pm=pm;
grid.dndx=dndx;
grid.dmde=dmde;
grid.xl=xl;
grid.el=el;
grid.angle=angle;
grid.orthogonality=getOrthog(grid.x,grid.y);
% update stats
handles=getGUIData('handles');
grid.minspacing=min([1./pn(:);1./pm(:)]);
grid.mdy=mean(1./pn(:));
grid.mdx=mean(1./pm(:));
if strcmpi(grid.coord,'Spherical')
    grid.origin.lon=mean(grid.x(:));
    grid.origin.lat=mean(grid.y(:));
else
    grid.origin.x=mean(grid.x(:));
    grid.origin.y=mean(grid.y(:));
end

setGUIData(grid);
setGridResDisplay(handles);
setGUIData(side);

% define BathyInterp based on new grid dimensions
if strcmpi(getGUIData('projection'),'spherical')
    glimits=[min(grid.x(:)) max(grid.x(:)) min(grid.y(:)) max(grid.y(:))];
    [zbathy,xbathy,ybathy]=getDefaultBathymetry(glimits,2);
    BathyInterpolant=griddedInterpolant(xbathy,ybathy,zbathy,'linear','none');
    setGUIData(BathyInterpolant);
end
setWatch('off');

% update mask and depths
setGridDepths();
setGridMask();
setGridRx0();
if getGUIData('SigmaCoord')
    setGridRx1();
end

% all calls to setgrid will modify grid - backup unless called to restore
% previous state
if getGUIData('dobackup')&&recompute
    setBackup();
end
% a grid has been set
setGUIData('gridLoaded',true);


end
%%
function [xi_psi,eta_psi,error_norm]=getBpsi2grid(xbound,ybound,m,n)
% function [xi_psi,eta_psi,error_norm]=Bpsi2grid(xpmap,ypmap,m,n)
% xbound:  vector of x_psi coordinates of grid boundary
% ybound:  vector of y_psi coordinates of grid boundary
% m,n:  xi, eta dimensions of required grid.
% derived from rect2grid routine from Charles Denham's Seagrid
%
% %=======================================================================
% % Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
% %  All Rights Reserved.
% %   Disclosure without explicit written consent from the
% %    copyright owner does not constitute publication.
% %=======================================================================
% % Version of 21-Oct-1998 20:50:16.
% % Updated    23-Jun-2000 14:29:17.

% create vector containing the indicies of the boundary points
ind=reshape(1:m*n,m,n);
ind=[ind(1:m-1,1);ind(m,1:n-1)';ind(m:-1:2,n);ind(1,n:-1:1)'];

% close the boundary
xbound(end+1)=xbound(1);
ybound(end+1)=ybound(1);

% create x and y point arrays with locations on boundaries and zeros
% everywhere else
X = zeros(m,n);
Y = zeros(m,n);
X(ind) = xbound;
Y(ind) = ybound;

% Solve Laplace's equation inside the boundary.
xi_psi=getPoisson(X);
eta_psi=getPoisson(Y);

% grid error kept for reference
del2_u = 4*del2(X);
err_norm_u = norm(del2_u(2:end-1, 2:end-1));
del2_v = 4*del2(Y);
err_norm_v = norm(del2_v(2:end-1, 2:end-1));
error_norm = err_norm_u + sqrt(-1).*err_norm_v;

end
%%
function result = getPoisson(q)
% derived from the fast Poisson solver fps.m from Charles Denham's Seagrid
% %=======================================================================
% % Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
% %  All Rights Reserved.
% %   Disclosure without explicit written consent from the
% %    copyright owner does not constitute publication.
% %=======================================================================
%
% % Reference: Press, et al., Numerical Recipes,
% %    Cambridge University Press, 1986 and later.
%
% % Version of 23-Oct-1998 09:02:58.
% % Updated    10-Feb-2000 20:48:26.

result=q;
q(2:end-1,[2 end-1])=q(2:end-1,[2 end-1])-q(2:end-1,[1 end]);
q([2 end-1],2:end-1)=q([2 end-1],2:end-1)-q([1 end],2:end-1);

% Extract the interior.
q = q(2:end-1, 2:end-1);

[mi, ni] = size(q);
q = [zeros(mi, 1) q zeros(mi, 1) -fliplr(q)];
q = [zeros(1, 2*ni+2); q; zeros(1, 2*ni+2); -flipud(q)];

% Fast Poisson Transform.  The array q is now twice the size
%  of the original p, minus two elements in each direction.
%  Thus, to invoke a power-of-two Fourier transform, use
%  sizes that themselves are a power-of-two plus one.

[mq, nq] = size(q);
i = (0:mq-1)' * ones(1, nq);
j = ones(mq, 1) * (0:nq-1);

% The simple formula for unit sample intervals is:
%  weights = 2 * (cos(2*pi*i/m) + cos(2*pi*j/n) - 2);

weights = 2 * (cos(2*pi*i/mq) + cos(2*pi*j/nq) - 2);
weights(1, 1) = 1;

res = real(ifft2(fft2(q) ./ weights));
result(2:end-1, 2:end-1) = res(2:mi+1, 2:ni+1);
end
%%
function ys=getspline(x,y,xs)
% similar to splinesafe without flags - always uses the end-slope control
x=x(:);
xs=xs(:);
if isvector(y)
    y=y(:);
end

dx=diff(x);dx=dx([1 end],:);
dy=diff(y);dy=dy([1 end],:);
n=size(dy,2);
dx=dx*ones(1,n);
slope=dy./dx;
y=[slope(1,:);y;slope(end,:)];


pp=spline(x.',y.');
ys=ppval(pp,xs.').';

end
%%
function xs=scalevar(x)
x(:) = x - min(x(:));
x(:) = x ./ max(x(:));
xs=x;
end