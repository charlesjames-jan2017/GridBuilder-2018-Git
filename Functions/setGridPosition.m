function setGridPosition(invert)
% function setGridPosition(invert)
% transforms grid and updates GUI data
% Charles James 2017
getVarcheck('invert',false);
grid=getGUIData('grid');
corner=getGUIData('corner');
side=getGUIData('side');
trace=getGUIData('trace');

[grid.x,grid.y]=getGridTransform(grid.x,grid.y,invert);
for iside=1:4
    [corner(iside).x,corner(iside).y]=getGridTransform(corner(iside).x,corner(iside).y,invert);
    [side(iside).x,side(iside).y]=getGridTransform(side(iside).x,side(iside).y,invert);
    [side(iside).control.x,side(iside).control.y]=getGridTransform(side(iside).control.x,side(iside).control.y,invert);
end
if ishandle(trace)
    [xdata,ydata]=getGridTransform(trace.XData,trace.YData,invert);
    trace.XData=xdata;
    trace.YData=ydata;
    setGUIData(trace);
end

grid.orthogonality=getOrthog(grid.x,grid.y);

setGUIData(grid);
setGUIData(corner);
setGUIData(side);
end
%%
function [Xm,Ym]=getGridTransform(X,Y,invert)
%function [Xm,Ym]=getGridTransform(X,Y,invert)
% calculate transformation coordinates for grid
Dtheta=getGUIData('Dtheta');
Translation=getGUIData('Translation');
corner=getGUIData('corner');
GridType=getGUIData('GridType');

Xm=X;Ym=Y;
if isempty(X)||isempty(Y)
    return;
end
DX=Translation.DX;
DY=Translation.DY;

Pivot=corner(1);
xpiv=Pivot.x;
ypiv=Pivot.y;
    
if strcmpi(GridType,'Orthogonal')
            % DX is a difference so can't do direct conversion to mercator
            % projection we need reference point to get differences in
            % mercator space
            x0=Translation.RefPt(1);
            y0=Translation.RefPt(2);
            [DX,DY]=getMercatorCoord(x0+DX,y0+DY,'C2M');
            [x0,y0]=getMercatorCoord(x0,y0,'C2M');
            DX=DX-x0;
            DY=DY-y0;
            [Xm,Ym]=getMercatorCoord(X,Y,'C2M');
            [xpiv,ypiv]=getMercatorCoord(xpiv,ypiv,'C2M');
end

if Dtheta~=0
    if invert
        Dtheta=-Dtheta;
    end
    % Rotation
    theta=Dtheta*pi/180;
    
    [Xm,Ym]=getRotation(Xm,Ym,xpiv,ypiv,theta);
end

if DX~=0
    Xm=Xm+DX;
end

if DY~=0
    Ym=Ym+DY;
end

if strcmpi(GridType,'Orthogonal')
    [Xm,Ym]=getMercatorCoord(Xm,Ym,'M2C');
end

end
