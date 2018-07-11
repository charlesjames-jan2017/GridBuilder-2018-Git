function hpatch=setPropertyPlot(x,y,prop,hpatch)
% function hpatch=setPropertyPlot(x,y,prop,hpatch)
% x and y are the verticies of model cells
% Charles James 2017
x1=x(1:end-1,1:end-1);
x2=x(1:end-1,2:end);
x3=x(2:end,2:end);
x4=x(2:end,1:end-1);

y1=y(1:end-1,1:end-1);
y2=y(1:end-1,2:end);
y3=y(2:end,2:end);
y4=y(2:end,1:end-1);

Mx=[x1(:) x2(:) x3(:) x4(:)]';
My=[y1(:) y2(:) y3(:) y4(:)]';
Mm=prop(:)';
if size(Mm,2)~=size(Mx,2)
    Mm=zeros(1,size(Mx,2));
end
if ishandle(hpatch)
    set(hpatch,'XData',Mx,'YData',My,'CData',Mm);
else
    hpatch=patch(Mx,My,Mm);
end
end