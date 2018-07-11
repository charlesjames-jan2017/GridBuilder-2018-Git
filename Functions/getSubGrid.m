function [corner,grid,side,mask,depths,hselect]=getSubGrid(handles)
mask=getGUIData('mask');
depths=getGUIData('depths');
corner=getGUIData('corner');
grid=getGUIData('grid');
side=getGUIData('side');

Visible=getGUIData('Visible');

setGridToggle('off',{'Control','Spacers','Side','Corners'});
setGridToggle('on',{'grid'});
Visible.grid='on';
setGUIData(Visible);
handles.rbGrid.Value=1;
size_parent=size(grid.x);

[i,j,hselect]=getGridRegion();
Xs=grid.x(i,j);
Ys=grid.y(i,j);

if min(size(Xs))<3
    msgbox('Miniumum Sub-grid Dimensions: 3x3')
    if ishandle(hselect)
        delete(hselect);
        hselect=[];
    end
else
    corner(1).x=Xs(1,1);corner(1).y=Ys(1,1);
    corner(2).x=Xs(end,1);corner(2).y=Ys(end,1);
    corner(3).x=Xs(end,end);corner(3).y=Ys(end,end);
    corner(4).x=Xs(1,end);corner(4).y=Ys(1,end);
    
    grid.x=Xs;
    grid.y=Ys;
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
    
    irho=i(1):(i(end)-1);
    jrho=j(1):(j(end)-1);
    
    [grid.m,grid.n]=size(Xs);
    if all(size(depths)==[size_parent(1)-1 size_parent(2)-1])
        depths=depths(irho,jrho);
        setGUIData('depthGridState',true);
    else
        depths=[];
    end
    if all(size(mask)==[size_parent(1)-1 size_parent(2)-1])
        mask=mask(irho,jrho);
        setGUIData('maskGridState',true);
    else
        mask=[];
    end
end
setGridToggle(Visible);

end
