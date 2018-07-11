function setWidgetsUpdate(handles)
% function setWidgetsUpdate(handles)
% systematically checks visibility of various widgets against GUI
% settings and dependencies to maintain consistency after callbacks have
% been executed.  Like setPlotsUpdate but for widgets and non dynamic
% settings.
% Charles James 2017

% done after every call back - checks state of GridBuilder widgets
% status accordingly

% what is on
showBath=(handles.rbBath.Value==1);
showDepths=(handles.rbDepths.Value==1);
showRx0=(handles.rbRx0.Value==1);
showRx1=(handles.rbRx1.Value==1);
showOrthog=(handles.rbOrthog.Value==1);

% what mode is active
ScreenMode=getGUIData('ScreenMode');

% dependent widget clusters
gridModDep=getGUIData('gridModDep');
gridViewDep=getGUIData('gridViewDep');
gridEditDep=getGUIData('gridEditDep');
iszoom=strcmpi(handles.tbZoomMan.State,'on');
ispan=strcmpi(handles.tbPan.State,'on');

if iszoom
    % makesure pointer is zoom pointer
    handles.MainFigure.PointerShapeCData=getGUIData('magpointer');
    handles.MainFigure.Pointer='custom';
elseif ~ispan
    handles.MainFigure.Pointer='arrow';
end

% update figure name
if ~isempty(getGUIData('CurrentFile'))
    [~,fnm,ext]=fileparts(getGUIData('CurrentFile'));
    handles.MainFigure.Name=['GridBuilder: ' [fnm ext]];
else
    handles.MainFigure.Name='GridBuilder';
    
end

% check warning colors
if getGUIData('gridLoaded')
    if getGUIData('SigmaCoord')
        rx1=getGUIData('rx1');
        handles.txtRx1.String=num2str(max(rx1(:)),'%4.3f');
        % also update sigma coeffeicients
        switch handles.puVertType.String{handles.puVertType.Value}
            case 'ROMS'
                Sigcoef=getGUIData('Sigcoef');
                handles.edZlev.String=int2str(Sigcoef.N);
                handles.puVtrans.Value=Sigcoef.Vtransform;
                handles.puVstretch.Value=Sigcoef.Vstretching;
                handles.edThetaS.String=num2str(Sigcoef.Theta_S,'%4.2f');
                handles.edThetaB.String=num2str(Sigcoef.Theta_B,'%4.2f');
                handles.edTcline.String=num2str(Sigcoef.Tcline,'%4.2f');
            otherwise
                % can't get here yet
        end
    end
    Rotation=getGUIData('Rotation');
    handles.editRot.String=num2str(Rotation,'%4.1f');
    
    rx0=getGUIData('rx0');
    handles.txtR.String=num2str(max(rx0(:)),'%4.3f');
    if (getTxt2Num(handles.minDepthEdit)<=0)
        handles.minDepthEdit.BackgroundColor=[1 .7 .7];
    else
        handles.minDepthEdit.BackgroundColor='w';
    end
    if (getTxt2Num(handles.txtR)>0.4)  % R. Miller 2007
        handles.txtR.ForegroundColor='r';
    elseif (getTxt2Num(handles.txtR)>0.2)  
        handles.txtR.ForegroundColor=[1 .65 0];
    else
        handles.txtR.ForegroundColor='g';
    end    
    if (getTxt2Num(handles.txtRx1)>10)  % Shchepetkin Insanity Limit (8-10)!
        handles.txtRx1.ForegroundColor='r';
    elseif (getTxt2Num(handles.txtRx1)>7) % Commonly cited upper limit
        handles.txtRx1.ForegroundColor=[1 .65 0];
    else
        handles.txtRx1.ForegroundColor='g';
    end
    if (getTxt2Num(handles.txtOrth)>15)
        handles.txtOrth.ForegroundColor='r';
    elseif (getTxt2Num(handles.txtOrth)>10)
        handles.txtOrth.ForegroundColor=[1 .65 0];
    else
        handles.txtOrth.ForegroundColor='g';
    end
end
%gridDep=getGUIData('gridDep');

hcb=getGUIData('hcb');
showColorbar=any(strcmpi({hcb.Visible},'on'));

% Things that don't depend on whether a grid is loaded or not
% if colorbar is up we need colorbar limits
if showOrthog||showRx0||showRx1
    set(hcb(3),'Visible','on');
    Caxis=caxis(handles.ColAxis);
    showColorbar=true;
elseif showDepths||showBath
    set(hcb(2),'Visible','on');
    Caxis=caxis(handles.BWAxis);
    showColorbar=true;
end
if showColorbar
    handles.panCaxis.Visible='on';
    handles.editMinCaxis.String=num2str(Caxis(1));
    handles.editMaxCaxis.String=num2str(Caxis(2));
else
    handles.panCaxis.Visible='off';
end


%Things that depend on whether a grid is loaded or not
% is there a grid loaded?
if getGUIData('gridLoaded')
    if getGUIData('ZoomOn')||getGUIData('PanOn')
        handles.MainAxis.HitTest='on';
    else
        handles.MainAxis.HitTest='off';
    end
    handles.rbCorners.Enable='on';
    handles.tbSubGrid.Enable='on';
    handles.tbSaveGrid.Enable='on';
    handles.puVertType.Enable='on';
    % Things that depend on Grid Style
    switch getGUIData('GridType')
        case {'Orthogonal','Rectangle','Fixed'} % Rectangular Grid or non-resizable
            handles.rbControl.Enable='off';
            handles.pbClearCP.Enable='off';
            if strcmp(getGUIData('GridEdit'),'control')
                setGUIData('GridEdit','corners');
                handles.rbCorners.Value=1;
                setGridToggle({'on','on','off','off'},{'Side','Corners','Control','Spacers'});
            end
        case 'Free'
            handles.rbControl.Enable='on';
    end
    switch handles.puVertType.String{handles.puVertType.Value}
        case 'None'
            handles.rbModVert.Enable='off';
            handles.rbRx1.Enable='off';
            handles.txtRx1.String='-';
            handles.txtRx1.ForegroundColor='w';
            if strcmpi(ScreenMode,'modvert')
                ScreenMode='modgrid';
                handles.rbModGrid.Value=1;
                handles.panGrid.Visible='on';
                handles.panROMSsigma.Visible='off';
                setGUIData(ScreenMode);                
            end
        case 'ROMS'
            handles.rbModVert.Enable='on';
            handles.rbRx1.Enable='on';
    end
    
    % check backup settings
    %backup=getGUIData('backup');
    %igrid=getGUIData('igrid');
    % toolbar elements that depend on a grid
    handles.tbSubGrid.Enable='on';
    % menu
    handles.mmEdit.Enable='on';
    handles.mSG_Save_Grid.Enable='on';
    handles.mSG_Save_As.Enable='on';
    handles.mExport.Enable='on';
    % Main Axis has Hit test on only for Zoom and Modify Grid
%     if getGUIData('ZoomOn')||strcmpi(getGUIData('ScreenMode'),'modmask');
%         handles.MainAxis.HitTest='on';
%     else
%     end
    

else
    % with no grid most tools are disabled
    set(handles.panRot,'visible','off');
    set(gridModDep,'enable','off');
    set(gridViewDep,'enable','off');
    set(gridEditDep,'enable','off');
    handles.SubGrid.Enable='off';
    handles.puVertType.Enable='off';
    handles.rbModVert.Enable='off';
    % toolbar elements that depend on a grid
    handles.tbUndo.Enable='off';
    handles.tbRedo.Enable='off';
    handles.tbSubGrid.Enable='off';
    handles.tbSaveGrid.Enable='off';
    % menu
    handles.mmEdit.Enable='off';
    handles.mSG_Save_Grid.Enable='off';
    handles.mSG_Save_As.Enable='off';
    handles.mExport.Enable='off';
    
    handles.rbRx1.Enable='off';
    handles.txtRx1.String='-';
    
end

% make sure mask markers are cleared if we are not in mask edit mode
if ~strcmpi(ScreenMode,'modmask')
    hmaskSelect=getGUIData('hmaskSelect');
    if ~isempty(hmaskSelect)&&ishandle(hmaskSelect)
        delete(hmaskSelect);
    end
end

switch ScreenMode
    case 'modgrid'
        switch getGUIData('GridEdit')
            case 'rotate'
                % during rotate features are unavailable until rotation is
                % finished.
                setGridToggle('off')
                set([handles.tbUndo handles.tbRedo handles.mUndo handles.mRedo],'enable','off');               
        end
    otherwise
        % must be grid edit mode to do subgrid selection
        handles.tbSubGrid.Enable='off';
end


Ref=getGUIData('Ref');
if strcmpi(get(handles.tbOverlay,'enable'),'on')&&strcmpi(get(handles.tbOverlay,'State'),'on')
    if isfield(Ref,'h')&&all(ishandle(Ref.h))
        set(Ref.h,'visible','on');
    else
        Ref.h=plot(handles.MainAxis,Ref.x,Ref.y,'k+','markersize',5,'hittest','off');
        setGUIData(Ref);
    end
else
    if ~isempty(Ref)
       if isfield(Ref,'h')&&all(ishandle(Ref.h))
           set(Ref.h,'visible','off');
       end
    end
end


% synchronize all Axes Positions;
handles.BWAxis.Position=handles.MainAxis.Position;
handles.ColAxis.Position=handles.MainAxis.Position;


end