function corner=setResizeCornerRectOrthog(corner,x,y,h)
% function corner=setResizeCornerRectOrthog(corner,x,y,h)
% for rectangle - only care about Rotational transformation
% find angle to undo all rotation
% Charles James 2018
Rotation=getGUIData('Rotation');
theta=-Rotation*pi/180;
hcorner=getGUIData('hcorner');
GridType=getGUIData('GridType');

% create dummy points where unrotated corner points would be
xpiv=corner(1).x;
ypiv=corner(1).y;
xb=[corner.x];
yb=[corner.y];

% can transform from Free to Rectangle without other arguments.
getVarcheck('x',xb(3));
getVarcheck('y',yb(3));
getVarcheck('h',hcorner(3));

if strcmp(GridType,'Orthogonal')
   [xb,yb]=getMercatorCoord(xb,yb,'C2M');
   [xpiv,ypiv]=getMercatorCoord(xpiv,ypiv,'C2M');
   [x,y]=getMercatorCoord(x,y,'C2M'); 
end

[xu,yu]=getRotation(xb,yb,xpiv,ypiv,theta);

% new corner location in unrotated coordinates;
[x0,y0]=getRotation(x,y,xpiv,ypiv,theta);

if strcmp(GridType,'Orthogonal')
    [x,y]=getMercatorCoord(x,y,'M2C');
end

set(h,'Xdata',x,'Ydata',y);
set(h,'visible','on');

ind=find(h==getGUIData('hcorner'));
% rectangle box behaviour - opposite corner stays the same and adjacent
% corners adjust to x and y of opposite corners
xu(ind)=x0;
yu(ind)=y0;
% we are explicit about all 4 corners in case we are switching from free to
% rectangle
switch ind
    case 1
        % change 2 and 4
        xu(2)=x0;
        yu(2)=yu(3);
        xu(4)=xu(3);
        yu(4)=y0;
        shft=0;
    case 2
        % change 3 and 1
        xu(1)=x0;
        yu(1)=yu(4);
        xu(3)=xu(4);
        yu(3)=y0;
        shft=2;
    case 3
        % change 4 and 2
        xu(4)=x0;
        yu(4)=yu(1);
        xu(2)=xu(1);
        yu(2)=y0;
        shft=0;
    case 4
        % change 1 and 3
        xu(3)=x0;
        yu(3)=yu(2);
        xu(1)=xu(2);
        yu(1)=y0;
        shft=2;
end

[~,~,k]=setGridCornersCCW(xu,yu);
% put pivot point at first spot
if any(k~=sort(k))
    xu=xu(k);
    yu=yu(k);
    xu=circshift(xu,shft,2);
    yu=circshift(yu,shft,2);
end

theta=-theta;
% rotate back and update corner
[xu,yu]=getRotation(xu,yu,xpiv,ypiv,theta);

if strcmp(GridType,'Orthogonal')
    [xu,yu]=getMercatorCoord(xu,yu,'M2C');
end

xb=num2cell(xu);
yb=num2cell(yu);

[corner.x]=xb{:};
[corner.y]=yb{:};


end