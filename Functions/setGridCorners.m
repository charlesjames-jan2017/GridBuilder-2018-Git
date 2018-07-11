function setGridCorners(handles)
% which mousebutton
selectiontype=get(handles.MainFigure,'selectiontype');
currentpoint=get(handles.MainAxis,'CurrentPoint');
x=currentpoint(1,1);y=currentpoint(1,2);
setGUIData('CurrentPoint',[x,y]);
corner=getGUIData('corner');
cornermode=getGUIData('cornermode');
GridType=getGUIData('GridType');
gridDep=getGUIData('gridDep');
hcorner=getGUIData('hcorner');
switch GridType
    case {'Free','Fixed'}
        if strcmp(selectiontype,'normal')
            if isempty(cornermode)
                set(hcorner(1),'XData',x,'YData',y,'color','r','marker','d','visible','on','markersize',8);
                setGUIData('cornerNumber',1);
                corner(1).x=x;
                corner(1).y=y;
                setGUIData(corner);
                setGUIData('cornermode','add');
                set(handles.MainFigure,'pointer','crosshair');
            end
            if strcmp(cornermode,'add')
                cornerNumber=getGUIData('cornerNumber')+1;
                set(hcorner(cornerNumber),'XData',x,'YData',y,'color','r','marker','o','visible','on','markersize',8);
                setGUIData(cornerNumber);
                corner(cornerNumber).x=x;
                corner(cornerNumber).y=y;
                setGUIData(corner);
                if cornerNumber==4
                    % find counter clockwise sequence
                    [~,~,k]=setGridCornersCCW([corner.x],[corner.y]);
                    % resort corners
                    corner=corner(k);
                    hcorner=hcorner(k);
                    setGUIData(corner);
                    setGUIData(hcorner);
                    setGUIData('cornermode','done');
                    set(handles.MainFigure,'Pointer','arrow');
                    set(gridDep,'enable','on');
                    setGridCreate();
                    setGridUpdate('Grid','Mask','Depths');
                    handles.rbGrid.Value=1;
                    grid=getGUIData('grid');
                    setGUIData('Rotation',median(grid.angle(:))*180/pi);
                end
            end
        end
    case {'Orthogonal','Rectangle'}
        if strcmp(selectiontype,'normal')&&isempty(cornermode)
            [x,y]=getRectangle();
            if isempty(x)
                return
            end
            corner(1).x=x(1);corner(1).y=y(1);
            corner(2).x=x(2);corner(2).y=y(2);
            corner(3).x=x(3);corner(3).y=y(3);
            corner(4).x=x(4);corner(4).y=y(4);
            set(hcorner(1),'XData',x(1),'YData',y(1),'color','r','marker','d','markersize',8);
            set(hcorner(2),'XData',x(2),'YData',y(2),'color','r','marker','o','markersize',8);
            set(hcorner(3),'XData',x(3),'YData',y(3),'color','r','marker','o','markersize',8);
            set(hcorner(4),'XData',x(4),'YData',y(4),'color','r','marker','o','markersize',8);
            
            ax=axis(handles.MainAxis);
            [xa,ya]=getAxis2xy(ax);
            if ~any(inpolygon([corner.x],[corner.y],xa,ya))
                p=handles.MainFigure.Position;
                handles.MainFigure.Position=p/2;
                handles.MainFigure.Position=p;
                return
            end

            setGUIData(corner);
            setGUIData(hcorner);
            setGUIData('cornermode','done');
            set(handles.MainFigure,'Pointer','arrow');
            set(gridDep,'enable','on');
            setGridCreate();
            setGridUpdate('Grid','Mask','Depths');
            handles.rbGrid.Value=1;
        end
end



end

