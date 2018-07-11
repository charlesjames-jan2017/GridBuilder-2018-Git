function setGridModify(PType)
% function setGridModify(PType)
% callback function to modify grid based on figure elements
% main routine for user interactions than modify the grid
% Charles James 2017
if strcmpi(PType,'do nothing')
    return
end
if getGUIData('ZoomOn')||getGUIData('PanOn')
    return
end

rbState=getButtonState();
setGUIData(rbState);
hside=getGUIData('hside');

handles=getGUIData('handles');
selectiontype=get(handles.MainFigure,'selectiontype');

switch getGUIData('ScreenMode')
    case 'modgrid'
        switch getGUIData('GridEdit')
            case 'corners'
                if strcmp(PType,'Corner')
                    h_point=gcbo;
                    corner=getGUIData('corner');
                    switch selectiontype
                        case 'normal'
                            set(handles.MainFigure,'pointer','circle')
                            set(h_point,'visible','off');
                            currentpoint=getMapSelectedPoint('up');
                            x=currentpoint(1,1);y=currentpoint(1,2);
                            set(handles.MainFigure,'pointer','arrow')
                            switch getGUIData('GridType')
                                case 'Fixed'
                                    set(h_point,'visible','on');
                                    return;
                                case 'Free'
                                    corner=setResizeCornerFree(corner,x,y,h_point);
                                case {'Orthogonal','Rectangle'}
                                    corner=setResizeCornerRectOrthog(corner,x,y,h_point);
                            end
                            setGUIData(corner);
                            % forces changes to mask and grid
                            setGUIData('maskGridState',false);
                            setGUIData('depthGridState',false);
                            setGridCreate();
                            setGridUpdate('Grid','Mask','Depths');
                            setPlotsUpdate();
                        case 'alt'
                            grid=getGUIData('grid');
                            side=getGUIData('side');
                            [grid,corner,side]=setCornerRoll(grid,corner,side,h_point);
                            setGridDepths();
                            setGridMask();
                            setGUIData(grid);
                            setGUIData(side);
                            setGUIData(corner);
                            setGridCreate();
                            setGridUpdate('Grid','Mask','Depths');
                            setPlotsUpdate();
                            
                    end
                    
                end
            case 'control'
                switch PType
                    case 'Sides'
                        if strcmp(selectiontype,'normal')
                            currentpoint=getGUIData('CurrentDownPoint');
                            h_side=gcbo;
                            side=getGUIData('side');
                            x=currentpoint(1,1);y=currentpoint(1,2);
                            % add control point
                            iside=get(h_side,'UserData');
                            
                            h=plot(x,y,'bo');
                            side(iside).control.x(end+1)=x;
                            side(iside).control.y(end+1)=y;
                            side(iside).control.handle(end+1)=h;
                            set(h,'ButtonDownFcn','setGridModify(''Control'')'...
                                ,'UserData',iside,'tag','control');
                            
                            cnpts=handle(side(iside).control.handle);
                            xp=[cnpts.XData];
                            yp=[cnpts.YData];
                            xline=get(hside(iside),'XData');
                            yline=get(hside(iside),'YData');
                            [~,inds]=sort(getPointsOnLine(xp,yp,xline,yline));
                            
                            side(iside).control.handle=side(iside).control.handle(inds);
                            side(iside).control.x=side(iside).control.x(inds);
                            side(iside).control.y=side(iside).control.y(inds);
                            setGUIData(side);
                        end
                    case 'Control'
                        side=getGUIData('side');
                        hcon=gcbo;
                        iside=get(hcon,'UserData');
                        whichpoint=hcon==side(iside).control.handle;
                        if strcmp(selectiontype,'alt')
                            % delete control point and update  control structure
                            delete(hcon);
                            side(iside).control.x(whichpoint)=[];
                            side(iside).control.y(whichpoint)=[];
                            side(iside).control.handle(whichpoint)=[];
                        else
                            % move control point
                            set(handles.MainFigure,'pointer','circle')
                            set(hcon,'visible','off');
                            currentpoint=getMapSelectedPoint('up');
                            x=currentpoint(1,1);y=currentpoint(1,2);
                            set(handles.MainFigure,'pointer','arrow')
                            set(hcon,'Xdata',x,'Ydata',y,'visible','on');
                            side(iside).control.x(whichpoint)=x;
                            side(iside).control.y(whichpoint)=y;
                        end
                        setGUIData(side);
                        % forces changes to mask and grid
                        setGUIData('maskGridState',false);
                        setGUIData('depthGridState',false);
                        % in all cases we need to reset and replot the grid.
                        setGridCreate();
                        setGridUpdate('Grid','Mask','Depths');
                end
            case 'spacers'
                side=getGUIData('side');
                switch PType
                    case 'Sides'
                        hside=gcbo;
                        iside=get(hside,'UserData');
                        switch selectiontype
                            case 'extend'
                                % reset spacing
                                if side(iside).spacing.active
                                    side(iside).spacing.spindex=linspace(0,1,length(side(iside).spacing.spindex));
                                end
                            case 'normal'
                                currentpoint=get(handles.MainAxis,'currentpoint');
                                x=currentpoint(1,1);y=currentpoint(1,2);
                                % add spacer point
                                if side(iside).spacing.active
                                    h=plot(x,y,'bs');
                                    side(iside).spacing.handle(end+1)=h;
                                    xline=side(iside).x;
                                    yline=side(iside).y;
                                    spindex=side(iside).spacing.spindex(2:end-1);
                                    
                                    [~,spind]=getPointsOnLine(x,y,xline,yline);
                                    spindex(end+1)=spind;
                                    [spindex,inds]=sort(spindex);
                                    spind=[0;spindex(:);1];
                                    
                                    
                                    side(iside).spacing.handle=side(iside).spacing.handle(inds);
                                    
                                    side(iside).spacing.spindex=spind;
                                    
                                    set(h,'ButtonDownFcn','setGridModify(''Spacers'')','UserData',iside,'tag','spacer');
                                end
                        end
                    case 'Spacers'
                        hspc=gcbo;
                        iside=get(hspc,'UserData');
                        whichpoint=hspc==side(iside).spacing.handle;
                        switch selectiontype
                            case 'normal'
                                % move spacer point
                                xline=side(iside).x;
                                yline=side(iside).y;
                                set(handles.MainFigure,'pointershapecdata',getGUIData('squarepointer'));
                                set(handles.MainFigure,'pointer','custom')
                                set(hspc,'visible','off');
                                currentpoint=getMapSelectedPoint('up');
                                x=currentpoint(1,1);y=currentpoint(1,2);
                                [~,dist,spxi,spyi]=getPointsOnLine(x,y,xline,yline);
                                % return out of bound points to original
                                % position
                                if (dist>=1)||(dist<=0)
                                    x=get(hspc,'Xdata');
                                    y=get(hspc,'Ydata');
                                else
                                    x=spxi;
                                    y=spyi;
                                end
                                
                                set(hspc,'Xdata',x,'Ydata',y);
                                xspc=get(side(iside).spacing.handle,'Xdata');
                                yspc=get(side(iside).spacing.handle,'Ydata');
                                if iscell(xspc)
                                    xspc=cell2mat(xspc);
                                    yspc=cell2mat(yspc);
                                end
                                
                                
                                [~,spind]=getPointsOnLine(xspc,yspc,xline,yline);
                                
                                % in case we clobbered an existing point
                                [spind,inds]=unique(spind);
                                % this may delete duplicate points so be
                                % prepared!
                                side(iside).spacing.handle=side(iside).spacing.handle(inds);
                                
                                % add endpoints
                                spind=[0;spind(:);1];
                                side(iside).spacing.spindex=spind;
                                set(handles.MainFigure,'pointer','arrow');
                                set(hspc,'visible','on');
                            case 'alt'
                                % delete spacing control point and spacing data
                                N=length(side(iside).spacing.handle);
                                if N>1
                                    delete(hspc);
                                    spind=side(iside).spacing.spindex(2:end-1);
                                    spind(whichpoint)=[];
                                    spind=[0;spind(:);1];
                                    side(iside).spacing.spindex=spind;
                                    side(iside).spacing.handle(whichpoint)=[];
                                    
                                end
                        end
                end
                % forces changes to mask and grid
                setGUIData('maskGridState',false);
                setGUIData('depthGridState',false);
                
                setGUIData(side);
                setGridCreate();
                setGridUpdate('Grid','Mask','Depths');
            case 'translate'
                switch selectiontype
                    case 'normal'
                        switch PType
                            case 'Corner'
                                corner=getGUIData('corner');
                                x=[corner.x];
                                y=[corner.y];
                                h=getGUIData('hcorner');
                                x(end+1)=x(1);
                                y(end+1)=y(1);
                                x0=x(h==gcbo);
                                y0=y(h==gcbo);
                                Translation=getGUIData('Translation');
                                
                                setGridToggle('off');
                                
                                
                                trace=setTraceOutline();
                                buttonstatus=getGUIData('ButtonDown');
                                DX=0;
                                DY=0;
                                while buttonstatus
                                    buttonstatus=getGUIData('ButtonDown');
                                    delete(trace);
                                    point=handles.MainAxis.CurrentPoint;
                                    DX=point(1,1)-x0;
                                    DY=point(1,2)-y0;
                                    trace=setTraceOutline(DX,DY);
                                    drawnow
                                end
                                delete(trace);
                                
                                Translation.DX=DX;
                                Translation.DY=DY;
                                % for altered projections (i.e. Orthogonal mode)
                                Translation.RefPt=[x0,y0];
                                setGUIData(Translation);
                                setGridPosition();
                                % reset translation after move
                                Translation.DX=0;
                                Translation.DY=0;
                                setGUIData(Translation);
                                % forces changes to mask and grid
                                setGUIData('maskGridState',false);
                                setGUIData('depthGridState',false);
                                
                                % don't rebuild grid under Orthogonal rotation
                                if ~strcmpi(getGUIData('GridType'),'Orthogonal')
                                    setGridCreate();
                                else
                                    % do grid create without recalculating interior points (all
                                    % done by orthogonal conversions). Passing the existing grid
                                    % into setGridCreate bypasses fps on interior points but won't
                                    % do backup.
                                    setGridCreate(getGUIData('grid'));
                                    setBackup();
                                end
                                setGridUpdate('Grid','Mask','Depths');
                                setGridToggle('on',{'Side','Corners'});
                                setPlotsUpdate();
                        end
                end
            case 'expand'
                grid=getGUIData('grid');
                hedge=gcbo;
                set(hedge,'color','m');
                iside=hedge==getGUIData('hside');
                answer=str2double(inputdlg('Add how many cells?','Expand',1,{'0'}));
                if isnan(answer)
                    answer=0;
                end
                if answer~=0
                    edges=[0 0 0 0];
                    edges(iside)=answer;
                    [grid.x,grid.y,newind,oldind]=getGridExpand(grid.x,grid.y,edges);
                    error=getGridError(grid);
                    if error<0
                        % expanding the grid has created an
                        % unhealthy grid return without modifying
                        msgbox({'This expansion would generate an invalid grid';'Returning without modifying grid'},'Expansion Error','modal');
                        set(hedge,'color','b');
                        return
                    end
                    [grid.m,grid.n]=size(grid.x);
                    setGridCreate(grid);
                    
                    % update depths and mask
                    depths_old=getGUIData('depths');
                    setGUIData('depthGridState',false);
                    depths=setGridDepths();
                    setGUIData('maskGridState',false);
                    mask_old=getGUIData('mask');
                    
                    % if contracting update grid data without recalculating
                    mask=setGridMask();
                    
                    % reuse old values of depths and masks in
                    % unchanged part of grid.  (setGridDepths and
                    % setGridMask has already set maskGridStatus
                    % and depthGridStatus to true so technically
                    % this is done under the table so to speak!
                    depths(newind)=depths_old(oldind);
                    setGUIData(depths);
                    mask(newind)=mask_old(oldind);
                    setGUIData(mask);
                    
                    setGridUpdate('Grid','Mask','Depths');
                    setPlotsUpdate();
                    setBackup();
                end
                
        end
    case 'modmask'
        if strcmpi(handles.puSelectMask.String{handles.puSelectMask.Value},'Contiguous')
            imaskSelect=getMaskContig(getGUIData('mask'));
            setGUIData(imaskSelect);
            setGridUpdate('mask');
        else
            if strcmpi(PType,'mask')
                currentpoint=getGUIData('CurrentDownPoint');
                x=currentpoint(1,1);y=currentpoint(1,2);
                [irho,jrho,hselect]=getGridRegion(x,y);
                
                mask=getGUIData('mask');
                hmask=getGUIData('hmask');
                
                ind=false(size(mask));
                ind(irho,jrho)=true;
                
                switch(handles.panMaskEdit.SelectedObject)
                    case handles.rbLandMask
                        mask(ind)=false;
                        hmask.CData(ind)=-inf;
                    case handles.rbOceanMask
                        mask(ind)=true;
                        hmask.CData(ind)=inf;
                    case handles.rbToggleMask
                        mask(ind)=~mask(ind);
                        cdata=hmask.CData(ind);
                        island=hmask.CData(ind)<0;
                        cdata(island)=inf;
                        cdata(~island)=-inf;
                        hmask.CData(ind)=cdata;
                end
                if handles.puSelectMask.Value>1
                    choice=handles.puSelectMask.String{handles.puSelectMask.Value};
                    imaskSelect=getMaskFeature(mask,choice);
                    if ~any(imaskSelect(:))
                        set(handles.puSelectMask,'Value',1);
                    end
                    setGUIData(imaskSelect);
                end
                if ishandle(hselect)
                    delete(hselect);
                end
                
                setGUIData(mask);
                setGridUpdate('mask');
                
                
                if getGUIData('dobackup')
                    setBackup();
                end
            end
        end
end
% callbacks to setGridModify bypass usual GridBuilderCallbacks so update widgets
% here
setButtonState(getGUIData('rbState'));
setWidgetsUpdate(handles);
setPlotsUpdate();
drawnow;
% make sure we restore backing up
setGUIData('dobackup',true);
end

%%
function corner=setResizeCornerFree(corner,x,y,h_point)
hcorner=getGUIData('hcorner');
set(h_point,'Xdata',x,'Ydata',y);
set(h_point,'visible','on');
ind=h_point==hcorner;
x0=corner(ind).x;
y0=corner(ind).y;
corner(ind).x=x;
corner(ind).y=y;
% keep user from making sides cross!
[~,~,k]=setGridCornersCCW([corner.x],[corner.y]);
if ~all(k==sort(k))
    corner(ind).x=x0;
    corner(ind).y=y0;
end
end
%%
function [newgrid,newcorner,newside]=setCornerRoll(grid,corner,side,h_point)
% function [newgrid,newcorner,newside]=setCornerRoll(grid,corner,side,h_point)
% move the active corner over by one and reshape the grid accordingly
% Charles James 2017
k=find(h_point==getGUIData('hcorner'));

oldind=1:4;
newind=circshift(oldind,1-k,2);
% corners are easy
newcorner=corner(newind);
% sides and grid are harder
newside=side(newind);
newgrid=grid;
%active=find(cell2mat(mgetfield(newside,'active')));
%aside=active(active>2);

% for i=1:length(aside);
%     spind=newside(aside(i)).spacing.spindex;
%     h=newside(aside(i)).spacing.handle;
%     spind=spind(end:-1:1);
%     newside(aside(i)).spacing.spindex=spind;
%     newside(aside(i)).spacing.handle=h(end:-1:1);
% end
depths=getGUIData('depths');
mask=getGUIData('mask');
rx0=getGUIData('rx0');


switch k
    case 2
        depths=rot90(depths,-1);
        mask=rot90(mask,-1);
        rx0=rot90(rx0,-1);
        newgrid.m=grid.n;
        newgrid.n=grid.m;
    case 3
        depths=rot90(depths,2);
        mask=rot90(mask,2);
        rx0=rot90(rx0,2);
    case 4
        depths=rot90(depths);
        mask=rot90(mask);
        rx0=rot90(rx0);
        newgrid.m=grid.n;
        newgrid.n=grid.m;
end

setGUIData(depths);
setGUIData(mask);
setGUIData(rx0);

end
