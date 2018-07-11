function [iselect,jselect,hselect]=getGridRegion(x0,y0)
% function [iselect,jselect,hselect]=getGridRegion(x0,y0)
% allows user to select region from grid and returns indicies of selected
% part of grid - highlights selected region of grid.
% Charles James 2017

getVarcheck('x0',[]);
getVarcheck('y0',[]);

grid=getGUIData('grid');
handles=getGUIData('handles');

pointer=handles.MainFigure.Pointer;
handles.MainFigure.Pointer='crosshair';

if isempty(x0)||isempty(y0)
    currentpoint=getMapSelectedPoint('down');
    x0=currentpoint(1,1);y0=currentpoint(1,2);
    selcol='r-';
    onpsi=true;
else
    selcol='k-';
    onpsi=false;
end
   
X=grid.x;
Y=grid.y;
if ~onpsi
    [X,Y]=getBpsi2rho(X,Y);
end


[i0,j0]=getNearestPoint(X,Y,x0,y0);
% flush Button Down check if this is just a quick tap
drawnow;
i=i0;
j=j0;
hselect=[];
ButtonDown=getGUIData('ButtonDown');
while ButtonDown
    if ~isempty(hselect)
        delete(hselect);
    end
    ButtonDown=getGUIData('ButtonDown');
    currentpoint=get(handles.MainAxis,'currentpoint');
    xC=currentpoint(1,1);yC=currentpoint(1,2);
    [iC,jC]=getNearestPoint(X,Y,xC,yC);
    i=sort([i0,iC]);
    j=sort([j0,jC]);
    Xs=X(i(1):i(2),j(1):j(2));
    Ys=Y(i(1):i(2),j(1):j(2));
    hselect=plot(handles.MainAxis,Xs,Ys,selcol,Xs',Ys',selcol);
    drawnow
end

iselect=i(1):i(end);
jselect=j(1):j(end);

handles.MainFigure.Pointer=pointer;


end
%%
function [i,j]=getNearestPoint(X,Y,x0,y0)
D=sqrt((X-x0).^2+(Y-y0).^2);
[i,j]=find(D==min(D(:)),1);
end
