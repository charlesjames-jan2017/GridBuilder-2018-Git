function setGuiInitial(handles)
% function setGuiInitial(handles)
% some things that need to be set up before we start model
% clear any surviving children from main axis
% Charles James 2017
%coast_color=[1 .5 .25];
coast_color=[.3 .3 .3];

delete(handles.BWAxis.Children);
delete(handles.ColAxis.Children);
delete(handles.MainAxis.Children);
handles.MainAxis.Visible='off';
% Need to interact with Main Axis to define corners
handles.MainAxis.HitTest='on';
handles.MainAxis.PickableParts='all';
% store userdata to save reloading
GSHHS=getGUIData('GSHHS');
CWD=getGUIData('CWD');
set(0,'UserData',[]);
setGUIData(CWD);

setGUIData(handles);
setGUIData('ButtonDown',false);
setGUIData('ismap',true);
setGUIData('ScreenMode','modgrid');
setGUIData('GridEdit','corners');

setGUIData('watchState',false);
handles.panGrid.SelectedObject=handles.rbCorners;

% to update default coasts and bathymetry during zoom events
squarepointer=nan(16);
squarepointer(3:end-2,3:end-2)=1;
squarepointer(4:end-3,4:end-3)=nan;
setGUIData(squarepointer);
%cj_mapProj('cart',handles.MainAxis');

% Set grid definition (can retain choice this is a reset) 
contents={'Orthogonal';'Rectangle';'Free';'Fixed'};
handles.puGtype.String=contents;
value=handles.puGtype.Value;
GridType=contents{value};
setGUIData(GridType);

% Set grid coordinates;
contents={'Spherical';'Cartesian'};
handles.puCoord.String=contents;
value=handles.puCoord.Value;
Coord=contents{value};

% prepare default empty grid
% set grid resolution (number of verticies
m=11;
n=21;
handles.Nedit.String=int2str(n-1);
handles.Medit.String=int2str(m-1);
set(handles.editRot,'String',0);
set(handles.sbRot,'Value',0);
setGUIData('Rotation',0);
setGUIData('Dtheta',0);
Translation.DX=0;
Translation.DY=0;
Translation.RefPt=[0,0];
setGUIData('Translation',Translation);

% define and store blank grid structure
grid.m=m;
grid.n=n;
grid.x=[];
grid.y=[];
grid.error=[];
grid.type='curvilinear';
grid.coord=lower(Coord);
setGUIData(grid);

% No grid loaded
setGUIData('gridLoaded',false);
handles.rbGrid.Value=0;

% Reset View Radio buttons
handles.rbBath.Value=0;
handles.rbDepths.Value=0;
handles.rbMask.Value=0;
handles.rbOrthog.Value=0;
handles.rbRx0.Value=0;
handles.rbModBath.Value=0;
handles.rbModMask.Value=0;
handles.rbModGrid.Value=1;
handles.rbCorners.Value=1;
handles.panRot.Visible='off';
handles.panMaskEdit.Visible='off';
handles.panDepthEdit.Visible='off';
handles.panGrid.Visible='on';
handles.txtOrth.String='-';
handles.txtOrth.ForegroundColor='w';
handles.txtR.String='-';
handles.txtR.ForegroundColor='w';
handles.txtRx1.String='-';
handles.txtRx1.ForegroundColor='w';

% add colorbar for topography, then hide till required
hcb(1)=colorbar(handles.MainAxis);
colormap(handles.MainAxis,gray);
hcb(2)=colorbar(handles.BWAxis);
colormap(handles.BWAxis,flipud(bone));
hcb(3)=colorbar(handles.ColAxis);
colormap(handles.ColAxis,jet);
set(hcb,'visible','off');
setGUIData(hcb);

% remove mean xi and eta resolution
handles.dispMDxi.String='';
handles.dispMDeta.String='';

load defbathy2
bathymetry=defbathy2;
% defbath formed from:
% [bathymetry.zbathy,bathymetry.xbathy,bathymetry.ybathy]=getETOPO(axlim,8);
setGUIData(bathymetry);
BathyInterpolant=griddedInterpolant(bathymetry.xbathy,bathymetry.ybathy,bathymetry.zbathy,'linear','none');
setGUIData(BathyInterpolant);
% Cartesian plot default bathymetry is 1000m everywhere
[xlims, ~]=getMapCoord([-180 180],[0 0],'ll2xy');
[~,ylims]=getMapCoord([0 0],[-90 90],'ll2xy');
[X,Y]=ndgrid(linspace(xlims(1),xlims(2),10),linspace(ylims(1),ylims(2),10));
cart_BathyInterpolant=griddedInterpolant(X,Y,1000*ones(size(X)));
setGUIData(cart_BathyInterpolant);

% save global interpolant in case we need to patch anything quickly
% (haven't got a use for it yet 0.99.5)
setGUIData('global_BathyInterpolant',BathyInterpolant);
setGUIData('userbath',false);

user_bathymetry.xbathy=[];
user_bathymetry.ybathy=[];
user_bathymetry.zbathy=[];
setGUIData(user_bathymetry);

setGUIData('bath_caxis',[0 4000]);
setGUIData('orthog_caxis',[0 10]);
setGUIData('mask_caxis',[0 1]);
setGUIData('rx0_caxis',[0 1]);
setGUIData('rx1_caxis',[0 10]);

% create bathymetry plot layer (this is at very bottom)
hbath=setPlotImage(handles.BWAxis,bathymetry.xbathy,bathymetry.ybathy,bathymetry.zbathy);
hbath.FaceColor='interp';
set(hbath,'hittest','off','visible','off','tag','bathymetry');
setGUIData(hbath);
% create user_bathymetry plot layer (above default bathymetry) initialize with default bathymetry;
user_hbath=setPlotImage(handles.BWAxis,bathymetry.xbathy,bathymetry.ybathy,bathymetry.zbathy);
user_hbath.FaceColor='interp';
set(user_hbath,'hittest','off','visible','off','tag','user_bathymetry');
% make a layer for the bounding convex hull of new bathymetry;
user_hbath_bound(1)=plot(handles.MainAxis,-180,-90,'-k','visible','off','linewidth',2,'tag','user_bathymetry');
user_hbath_bound(2)=plot(handles.MainAxis,-180,-90,'-w','visible','off','linewidth',.5,'tag','user_bathymetry');
setGUIData(user_hbath);
setGUIData(user_hbath_bound);
setGridUpdate('Bathymetry');
handles.rbBath.Value=0;

% depth editing data
set(handles.minDepthEdit,'String','');
set(handles.maxDepthEdit,'String','');
contents={'Positive Adjustment';'Negative Adjustment';'Shapiro (B.C. constant)';'Shapiro (B.C. smooth)'};
handles.puFilterType.String=contents;
handles.puFilterType.Value=1;
handles.txtTargetRx0.String='Target rx0';
handles.edTargetRx0.String='0.2';
contents={'2';'4';'8';'16'};
handles.puFiltOrder.String=contents;
handles.puFiltOrder.Value=1;
handles.puFiltOrder.Visible='off';
handles.txtFiltOrder.Visible='off';
setGUIData('rx0Max',.2);
setGUIData('shapiroDepth',0);


% mask editting
contents={'None','Isolated Cells','Isolated Bays','Narrow Channels','Contiguous'};
handles.puSelectMask.String=contents;

% Z-coord editing Data
% only supporting ROMS for now
Sigcoef.Vtransform=2;
Sigcoef.Vstretching=4;
Sigcoef.N=15;
Sigcoef.Theta_S=8;
Sigcoef.Theta_B=4;
Sigcoef.Tcline=20;
setGUIData(Sigcoef);

handles.puVertType.String={'None','ROMS'};
handles.puVertType.Value=1;
handles.puVtrans.String={'1';'2'};
handles.puVtrans.Value=Sigcoef.Vtransform;
handles.puVstretch.String={'1';'2';'3';'4'};
handles.puVstretch.Value=Sigcoef.Vstretching;
handles.edThetaS.String=num2str(Sigcoef.Theta_S,'%2.2f');
handles.edThetaB.String=num2str(Sigcoef.Theta_B,'%2.2f');
handles.edTcline.String=num2str(Sigcoef.Tcline,'%2.2f');
handles.edZlev.String=int2str(Sigcoef.N);
handles.puVertType.Enable='off';
setGUIData('SigmaCoord',false);

% preload a default coastline for global projection
handles.rbCoast.Enable='on';
load defcoast2
if isempty(GSHHS)
    res={'c','l','i','h','f'};
    for i=1:length(res)
        fid=fopen(['gshhs_' res{i} '.b']);
        GSHHS.(res{i}).bin=uint8(fread(fid,'uint8'));
        f=load(['gshhs_ind_' res{i} '.mat']);
        GSHHS.(res{i}).ind=f.ind;
    end
end
setGUIData(GSHHS);
setGUIData('FastMask',true);
setGUIData('userMask',false);
handles.mMaskTopo.Checked='On';
handles.mMaskGSHHG.Checked='Off';
handles.mMaskUser.Checked='Off';

% This sets the order of figure elements (bathymetry already on bottom layer)
set(handles.MainFigure,'CurrentAxes',handles.MainAxis);
% green grid mesh at bottom otherwise a fine mesh can block everything
hgrid=plot(1,1,'g-','visible','off');
set(hgrid,'HitTest','off','PickableParts','none');
% depths,rx0,rx1, and orthogonality are never plotted at same time so order
% here is not important.
set(handles.MainFigure,'CurrentAxes',handles.BWAxis);
hdepths=patch([1 1 0 0],[0 1 1 0],0,'edgecolor','none','visible','off','PickableParts','None','HitTest','Off');
setGUIData(hdepths);
set(handles.MainFigure,'CurrentAxes',handles.ColAxis);
hrx0=patch([1 1 0 0],[0 1 1 0],0,'edgecolor','none','visible','off','PickableParts','None','HitTest','Off');
setGUIData(hrx0);
hrx1=patch([1 1 0 0],[0 1 1 0],0,'edgecolor','none','visible','off','PickableParts','None','HitTest','Off');
setGUIData(hrx1);
horthog=patch([1 1 0 0],[0 1 1 0],0,'edgecolor','none','visible','off','PickableParts','None','HitTest','Off');
setGUIData(horthog);
%  mask is semi-transparent so goes on top and is only used with grid or
%  depths
set(handles.MainFigure,'CurrentAxes',handles.MainAxis);
hmask=patch([1 1 0 0],[0 1 1 0],0,'edgecolor','none','visible','off','FaceAlpha',.5,'PickableParts','all','HitTest','Off');
setGUIData(hmask);

% coast goes above everything except grid sides and corners
setGUIData('coast',defcoast2);
hcoast=plot(handles.MainAxis,defcoast2.lon,defcoast2.lat,'color',coast_color,'hittest','off','PickableParts','none','tag','coast','visible','off');
setGUIData(hcoast);
user_hcoast(1)=plot(handles.MainAxis,defcoast2.lon,defcoast2.lat,'color','w','hittest','off','PickableParts','none','tag','user_coast','visible','off','linewidth',1);
user_hcoast(2)=plot(handles.MainAxis,defcoast2.lon,defcoast2.lat,'color','b','hittest','off','PickableParts','none','tag','user_coast','visible','off','linewidth',.5);
setGUIData(user_hcoast);
setGUIData('usercoast',false);
axis(handles.MainAxis,'equal');

% sides second to top with corners on top
setGUIData(hgrid);
hside(1)=plot(handles.MainAxis,1,1,'r-','visible','off','linewidth',2);
hside(2)=plot(handles.MainAxis,1,1,'r-','visible','off','linewidth',2);
hside(3)=plot(handles.MainAxis,1,1,'r-','visible','off','linewidth',2);
hside(4)=plot(handles.MainAxis,1,1,'r-','visible','off','linewidth',2);
setGUIData(hside);
hcorner(1)=plot(handles.MainAxis,1,1,'ro','visible','off');
hcorner(2)=plot(handles.MainAxis,1,1,'ro','visible','off');
hcorner(3)=plot(handles.MainAxis,1,1,'ro','visible','off');
hcorner(4)=plot(handles.MainAxis,1,1,'ro','visible','off');
setGUIData(hcorner);

% Note: control and spacer points set on the fly and will be above these
% elements.



setGUIData('CurrentPointer','arrow');
handles.MainFigure.Pointer='arrow';

if strcmp(Coord,'Spherical')
    % start with global view
    axlim=[-180 180 -90 90];
    setGUIData('limits',axlim);
    setGridUpdate('Coast');
    handles.rbCoast.Value=1;
    hcoast.Visible='on';
    % tidy up axis
    delete([get(handles.BWAxis,'xlabel'),get(handles.BWAxis','ylabel')])
    hxlabel=xlabel(handles.BWAxis,'Longitude');
    hylabel=ylabel(handles.BWAxis,'Latitude');
else
    [axlim(1:2), ~]=getMapCoord([-180 180],[0 0],'ll2xy');
    [~,axlim(3:4)]=getMapCoord([0 0],[-90 90],'ll2xy');
    setGUIData('limits',axlim);
    handles.rbCoast.Enable='off';
    hcoast.Visible='off';
    % tidy up axis
    delete([get(handles.BWAxis,'xlabel'),get(handles.MainAxis','ylabel')])
    hxlabel=xlabel(handles.BWAxis,'xi (m)');
    hylabel=ylabel(handles.BWAxis,'eta (m)');
end

hxlabel.Color=[.941 .941 .941];
hylabel.Color=[.941 .941 .941];

%set(handles.MainFigure,'Pointer','cross');


% Default Grid creation projction
setGUIData('projection',Coord);
setGUIData(hxlabel);
setGUIData(hylabel);

% manual zoom and pan functions
setGUIData('ZoomOn',false);
setGUIData('PanOn',false);
setGUIData('zoomlims',axlim);
setGUIData('zoomlevel',1);
setGUIData('prepanState',[handles.rbBath.Value,handles.rbDepths.Value,handles.rbMask.Value,handles.rbOrthog.Value]);

% zoom style pointer
magpointer=...
    [NaN   NaN   NaN   NaN     1     1     1     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
    NaN   NaN     1     1   NaN     2   NaN     2     1     1   NaN   NaN   NaN   NaN   NaN   NaN
    NaN     1     2   NaN     2     1     1   NaN     2   NaN     1   NaN   NaN   NaN   NaN   NaN
    NaN     1   NaN     2   NaN     1     1     2   NaN     2     1   NaN   NaN   NaN   NaN   NaN
    1   NaN     2   NaN     2     1     1   NaN     2   NaN     2     1   NaN   NaN   NaN   NaN
    1     2     1     1     1     1     1     1     1     1   NaN     1   NaN   NaN   NaN   NaN
    1   NaN     1     1     1     1     1     1     1     1     2     1   NaN   NaN   NaN   NaN
    1     2   NaN     2   NaN     1     1     2   NaN     2   NaN     1   NaN   NaN   NaN   NaN
    NaN     1     2   NaN     2     1     1   NaN     2   NaN     1   NaN   NaN   NaN   NaN   NaN
    NaN     1   NaN     2   NaN     1     1     2   NaN     2     1     2   NaN   NaN   NaN   NaN
    NaN   NaN     1     1     2   NaN     2   NaN     1     1     1     1     2   NaN   NaN   NaN
    NaN   NaN   NaN   NaN     1     1     1     1   NaN     2     1     1     1     2   NaN   NaN
    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     2     1     1     1     2   NaN
    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     2     1     1     1     2
    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     2     1     1     1
    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     2     1     2];
setGUIData(magpointer);
% palmpointer=...
%     [NaN   NaN   NaN   NaN   NaN   NaN   NaN     1     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN
%     NaN   NaN   NaN     1     1   NaN     1     2     2     1     1     1   NaN   NaN   NaN   NaN
%     NaN   NaN     1     2     2     1     1     2     2     1     2     2     1   NaN   NaN   NaN
%     NaN   NaN     1     2     2     1     1     2     2     1     2     2     1   NaN     1   NaN
%     NaN   NaN   NaN     1     2     2     1     2     2     1     2     2     1     1     2     1
%     NaN   NaN   NaN     1     2     2     1     2     2     1     2     2     1     2     2     1
%     NaN     1     1   NaN     1     2     2     2     2     2     2     2     1     2     2     1
%     1     2     2     1     1     2     2     2     2     2     2     2     2     2     2     1
%     1     2     2     2     1     2     2     2     2     2     2     2     2     2     1   NaN
%     NaN     1     2     2     2     2     2     2     2     2     2     2     2     2     1   NaN
%     NaN   NaN     1     2     2     2     2     2     2     2     2     2     2     2     1   NaN
%     NaN   NaN     1     2     2     2     2     2     2     2     2     2     2     1   NaN   NaN
%     NaN   NaN   NaN     1     2     2     2     2     2     2     2     2     2     1   NaN   NaN
%     NaN   NaN   NaN   NaN     1     2     2     2     2     2     2     2     1   NaN   NaN   NaN
%     NaN   NaN   NaN   NaN   NaN     1     2     2     2     2     2     2     1   NaN   NaN   NaN
%     NaN   NaN   NaN   NaN   NaN     1     2     2     2     2     2     2     1   NaN   NaN   NaN];
% setGUIData(palmpointer);

% default spacing on sides 1 and 2
side(1).spacing.active=true;side(1).spacing.handle=[];
side(2).spacing.active=true;side(2).spacing.handle=[];
side(3).spacing.active=false;side(3).spacing.handle=[];
side(4).spacing.active=false;side(4).spacing.handle=[];
% just to simplify set grid and spacing
% keep track of index where points are
side(1).spacing.spindex=linspace(0,1,7);
side(2).spacing.spindex=linspace(0,1,7);
side(3).spacing.spindex=[];
side(4).spacing.spindex=[];

% start with no control points
side(1).control.x=[];side(1).control.y=[];side(1).control.handle=[];
side(2).control.x=[];side(2).control.y=[];side(2).control.handle=[];
side(3).control.x=[];side(3).control.y=[];side(3).control.handle=[];
side(4).control.x=[];side(4).control.y=[];side(4).control.handle=[];
% 
side(1).x=[];side(1).y=side(1).x;
side(2).x=[];side(2).y=side(2).x;
side(3).x=[];side(3).y=side(3).x;
side(4).x=[];side(4).y=side(4).x;
setGUIData(side);

% keep track of grid visibility
Visible.grid='on';
Visible.corner='on';
Visible.side='on';
Visible.control='off';
Visible.spacer='off';
Visible.mask='off';
Visible.depths='off';
Visible.orthogonality='off';
Visible.rx0='off';

setGUIData(Visible);
% editing
setGUIData('igrid',0);
setGUIData('maskGridState',false);
setGUIData('depthGridState',false);
backup(1).side=side;
backup(1).corner=[];
handles.tbUndo.Enable='off';
handles.tbRedo.Enable='off';
setGUIData(backup);
setGUIData('dobackup',true);

% set default widget states
% set(handles.panRot,'visible','off');
% 
rbHandles=[handles.rbModGrid,handles.rbModMask,handles.rbModBath,handles.rbModVert,...
    handles.rbLandMask,handles.rbOceanMask,handles.rbToggleMask,handles.rbCorners,...
    handles.rbControl,handles.rbSpacer,handles.rbRotate,handles.rbTranslate,...
    handles.rbExpand,handles.rbCoast,handles.rbGrid,handles.rbDepths,handles.rbMask,...
    handles.rbOrthog,handles.rbRx0,handles.rbRx1];
setGUIData(rbHandles);

gridModDep=[handles.rbModMask,handles.rbModBath];
gridViewDep=[handles.rbGrid,handles.rbDepths,handles.rbMask,handles.rbOrthog,handles.rbRx0,handles.rbRx1];
gridEditDep=[handles.Nedit,handles.Medit, handles.pbResDone,handles.rbControl, handles.rbSpacer, handles.rbRotate, handles.rbTranslate, handles.rbExpand];
gridDep=[gridModDep,gridViewDep,gridEditDep];

targetRx0Dep=[handles.txtTargetRx0,handles.edTargetRx0];
filtOrderDep=[handles.txtFiltOrder,handles.puFiltOrder];

setGUIData(targetRx0Dep);
setGUIData(filtOrderDep);

maskViewDep=[handles.mFullRes,handles.mHighRes,handles.mIntRes,handles.mLowRes,handles.mCoarseRes];
setGUIData(maskViewDep);

setGUIData('maskres',0)
set(maskViewDep,'Checked','off')
set(handles.mAutoRes,'Checked','on');

setGUIData(gridModDep);
setGUIData(gridViewDep);
setGUIData(gridEditDep);
setGUIData(gridDep);

% Reset Toolbar Objects
handles.tbOverlay.State='off';
handles.tbOverlay.Enable='off';
handles.tbSubGrid.Enable='off';
panZoomDep=[handles.panGrid,handles.panMode];
set([handles.tbZoomMan, handles.tbPan],'State','off');
pan(handles.MainAxis,'off');
setGUIData(panZoomDep);
set(panZoomDep,'visible','on');

PanControl=pan(handles.MainFigure);
set(PanControl,'ActionPostCallback','setPostPan');
set(gridViewDep,'Value',0);

handles.panMode.SelectedObject=handles.rbModGrid;
handles.panMaskEdit.SelectedObject=handles.rbToggleMask;
handles.panMaskEdit.Visible='off';
handles.panDepthEdit.Visible='off';
handles.panROMSsigma.Visible='off';
%

% synchronize axes
handles.BWAxis.Position=handles.MainAxis.Position;
handles.BWAxis.OuterPosition=handles.MainAxis.OuterPosition;
handles.ColAxis.Position=handles.MainAxis.Position;
handles.ColAxis.OuterPosition=handles.MainAxis.OuterPosition;
limits=axis(handles.MainAxis);
DAR=handles.MainAxis.DataAspectRatio;
axis(handles.BWAxis,limits);
axis(handles.ColAxis,limits);
handles.BWAxis.DataAspectRatio=DAR;
handles.ColAxis.DataAspectRatio=DAR;

%handles.MainAxis.Visible='on';
setWidgetsUpdate(handles);
end