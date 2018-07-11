function setGridBuilderCoord(handles)
% remap coordinates;
Coord=getGUIData('projection');
GridType=getGUIData('GridType');
grid=getGUIData('grid');
gCoord=grid.coord;
limits0=getGUIData('limits');
if strcmpi(Coord,gCoord)
    % no need to do anything;
    return
end
setGUIData('dobackup',true);
side=getGUIData('side');
corner=getGUIData('corner');
px=corner(1).x;
py=corner(1).y;
if strcmpi(Coord,'Spherical')
    % convert distances to lats and lons
     [limits(1:2), ~]=getMapCoord(limits0(1:2),[mean(limits0(3:4)) mean(limits0(3:4))],'xy2ll',px,py);
     [~, limits(3:4)]=getMapCoord([mean(limits0(1:2)) mean(limits0(1:2))],limits0(3:4),'xy2ll',px,py);
    grid.coord='spherical';    
    for i=1:4
        [corner(i).x, corner(i).y]=getMapCoord(corner(i).x,corner(i).y,'xy2ll',px,py);
        if ~isempty(side(i).control.x)
            [side(i).control.x,side(i).control.y]=getMapCoord(side(i).control.x,side(i).control.y,'xy2ll',px,py);
        end
    end    
    % update axis labels
    xlabel(handles.BWAxis,'Longitude');
    ylabel(handles.BWAxis,'Latitude');
    handles.rbCoast.Enable='on';
elseif strcmpi(Coord,'Cartesian')
    % convert lats and lons to distances
    [limits(1:2), ~]=getMapCoord(limits0(1:2),[mean(limits0(3:4)) mean(limits0(3:4))],'ll2xy',px,py);
    [~, limits(3:4)]=getMapCoord([mean(limits0(1:2)) mean(limits0(1:2))],limits0(3:4),'ll2xy',px,py);
    grid.coord='cartesian';  
    for i=1:4
        [corner(i).x,corner(i).y]=getMapCoord(corner(i).x,corner(i).y,'ll2xy',px,py);
        if ~isempty(side(i).control.x)
            [side(i).control.x, side(i).control.y]=getMapCoord(side(i).control.x,side(i).control.y,'ll2xy',px,py);           
        end        
    end
    % update axis labels
    xlabel(handles.BWAxis,'xi (m)');
    ylabel(handles.BWAxis,'eta (m)');    
    handles.rbCoast.Enable='off';
end
if strcmpi(GridType,'Rectangle')||strcmpi(GridType,'Orthogonal')
    corner=setResizeCornerRectOrthog(corner);
end
setGUIData(limits);
setGUIData(grid);
setGUIData(corner);
setGUIData(side);
axis(handles.MainAxis,limits);
setGridCreate();

end
