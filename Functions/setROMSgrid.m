function setROMSgrid(SG)
% function setROMSgrid(SG)
% after loading a ROMS grid set up all required values for SG structure
% Charles James 2017
handles=getGUIData('handles');
% extract grid elements
grid=SG.grid;
mask=SG.mask;
side=SG.side;
corner=SG.corner;
depths=SG.depths;
Rotation=SG.Rotation;

setGUIData(grid);
setGUIData(side);
setGUIData(corner);
setGUIData(mask);
setGUIData(depths);
setGUIData(Rotation);
setGUIData('minDepth',min(depths(:)));
setGUIData('maxDepth',max(depths(:)));

set(handles.editRot,'String',num2str(SG.Rotation,4));
set(handles.sbRot,'value',SG.Rotation);
setGUIData('cornermode','done');

user_BathyInterpolant=SG.user_BathyInterpolant;
setGUIData(user_BathyInterpolant);

% currently imported ROMS grids only do scattered interpolants
user_bathymetry=getInterpolant2Bathy(user_BathyInterpolant);
setGUIData(user_bathymetry);

setGUIData('userbath',true);
% supress grid generation
setGUIData('cornermode','done');
% set some tighter limits
xmin=min(grid.x(:));
xmax=max(grid.x(:));
ymin=min(grid.y(:));
ymax=max(grid.y(:));
dx=0.1*(xmax-xmin);
dy=0.1*(ymax-ymin);
limits=[xmin-dx xmax+dx ymin-dy ymax+dy];
setGUIData(limits);
% update coast and bathymetry resoltions
[coast.lon,coast.lat]=getCoastline(limits);
setGUIData(coast);
% recalculate bathymetry for zoomed view
dlon=xmax-xmin;
if dlon>90
    res=8;
elseif dlon>10
    res=4;
else
    res=2;
end
[bathymetry.zbathy,bathymetry.xbathy,bathymetry.ybathy]=getDefaultBathymetry(limits,res);
BathyInterpolant=griddedInterpolant(bathymetry.xbathy,bathymetry.ybathy,bathymetry.zbathy,'linear','none');
setGUIData(bathymetry);
setGUIData(BathyInterpolant);
%
gridDep=getGUIData('gridDep');
set(gridDep,'enable','on');
% set current mask to one from ROMS
mask(mask==1)=+inf;
mask(mask==0)=-inf;
hmask=setPropertyPlot(grid.x,grid.y,mask,getGUIData('hmask'));
if (handles.rbMask.Value==0)
    set(hmask,'visible','off');
end
set(hmask,'ButtonDownFcn','setGridModify(''Mask'')','EdgeAlpha',.5,'FaceAlpha',.6,'tag','mask');
setGUIData(hmask);
if ishandle(hmask)
    set(handles.rbModMask,'enable','on');
end
% set current depths to ROMS
hdepths=setPropertyPlot(grid.x,grid.y,depths,getGUIData('hdepths'));
if (handles.rbDepths.Value==0)
    set(hdepths,'visible','off');
end
set(hdepths,'ButtonDownFcn','setGridModify(''Depths'')','EdgeColor','none');
setGUIData(hdepths);
if ishandle(hdepths)
    set(handles.rbModBath,'enable','on');
end
% ROMS imported grids may be curvilinear - choose fixed type
% for saftey
setGUIData('GridType','Fixed');
handles.puGtype.Value=find(ismember(handles.puGtype.String,getGUIData('GridType')));


% grid - but leave mask and depths until grid is modified
setGridUpdate('Coast','Bathymetry','Grid');
setGridResDisplay(handles);
handles.minDepthEdit.String=num2str(getGUIData('minDepth'));
handles.maxDepthEdit.String=num2str(getGUIData('maxDepth'));
% create backup point for starting
setGUIData('maskGridState',true);
setGUIData('depthGridState',true);
setBackup();


end
