function error=getGridError(grid)
% function error=getGridError(grid)
% Checks for any fatal grid errors like cell points outside the boundaries
% Charles James 2017
error=0;

x=grid.x;
y=grid.y;

xb=[x(1,:),x(:,end)',fliplr(x(end,:)),fliplr(x(:,1)')];
yb=[y(1,:),y(:,end)',fliplr(y(end,:)),fliplr(y(:,1)')];

% do any grid points lie outside the boundary?
% but only check first layer of cells
indc=false(size(x));
indc(2:end-1,2:end-1)=~indc(2:end-1,2:end-1);
indc(3:end-2,3:end-2)=~indc(3:end-2,3:end-2);

xc=x(indc);
yc=y(indc);


xc(3:end-2,3:end-2)=nan;
yc(3:end-2,3:end-2)=nan;
xc=xc(~isnan(xc));
yc=yc(~isnan(yc));

ind=inpolygon(xc,yc,xb,yb);

if any(~ind(:))
    error=-1;
end

xc=[x(1,1),x(end,1),x(end,end),x(1,end)];
yc=[y(1,1),y(end,1),y(end,end),y(1,end)];
ind=convhull(xc,yc);

ind(end)=[];
if any(ind~=sort(ind))
    error=-1;
end


end