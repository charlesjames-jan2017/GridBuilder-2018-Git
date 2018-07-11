function [ex,ey,newindex,oldindex]=getGridExpand(gx,gy,edges)
% function [ex,ey,newindex,oldindex]=getGridExpand(gx,gy,edges)
% take sides of existing grid and expand number of cells in each direction
% convention is in order from origin counter clockwise around grid
% use index to regrid.
% Charles James 2017
[n,m]=size(gx);
n1=edges(1);
n2=edges(2);
n3=edges(3);
n4=edges(4);

[Np,Mp]=ndgrid(1:n,1:m);
[NIp,MIp]=ndgrid((1-n4):(n+n2),(1-n1):(m+n3));
% calculate equivalent indicies on rho grid for indexing mask and depths
[N,M]=ndgrid(1:n-1,1:m-1);
[NI,MI]=ndgrid((1-n4):(n-1+n2),(1-n1):(m-1+n3));

newindex=ismember(NI,N)&ismember(MI,M);
oldindex=ismember(N,NI)&ismember(M,MI);

if strcmpi(getGUIData('GridType'),'Orthogonal')
    [gx,gy]=getMercatorCoord(gx,gy,'C2M');
end

Fx=griddedInterpolant(Np,Mp,gx,'linear','linear');
Fy=griddedInterpolant(Np,Mp,gy,'linear','linear');

ex=Fx(NIp,MIp);
ey=Fy(NIp,MIp);

if strcmpi(getGUIData('GridType'),'Orthogonal')
    [ex,ey]=getMercatorCoord(ex,ey,'M2C');
end
end