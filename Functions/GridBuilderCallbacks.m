function GridBuilderCallbacks(hObject,eventdata,handles)
% function GridBuilderCallbacks(hObject,eventdata,handles)
% independent multi callback handler for all GridBuilder Callbacks (helps
% with debugging as code can be modified without having to restart the GUI)
% Charles James 2017
updateplots=true;
switch hObject
%% Initialize Call
% initializes or resets GridBuilder, will reset backups too
    case {'Initialize',handles.tbReset,handles.mSG_Clear_Grid}
        setGuiInitial(handles);
%%
    case handles.MainFigure
        % Only reached during resize of main Figure
        % synchronize all Axes sizes;        
        handles.BWAxis.Position=handles.MainAxis.Position;
        handles.BWAxis.OuterPosition=handles.MainAxis.OuterPosition;
        handles.ColAxis.Position=handles.MainAxis.Position;
        handles.ColAxis.OuterPosition=handles.MainAxis.OuterPosition;
        updateplots=false;        
%% Menu and Toolbar Callbacks  
    case handles.mSG_LoadSG
        [filename,pathname]=getGUIfilename('*.mat','Select GridBuilder file');
        if ~isnumeric(filename)
            setGuiInitial(handles);
            setGUIData('CurrentFile',fullfile(pathname,filename));
            getGridBuilderFile(fullfile(pathname,filename));
            handles.rbGrid.Value=1;
            setBackup();
            setZoom('set');
        end  
        updateplots=false;        
    case {handles.tbSaveGrid , handles.mSG_Save_Grid, handles.mSG_Save_As}
        SG=setGridBuilderFile();         %#ok<NASGU>
        if isempty(getGUIData('CurrentFile'))||hObject==handles.mSG_Save_As
            [filename,pathname]=setGBfilename('*.mat','Select File Name');
            if ~isnumeric(filename)
                CurrentFile=fullfile(pathname,filename);
                setGUIData(CurrentFile);
                save(CurrentFile,'SG');
            end
        else
            if exist(getGUIData('CurrentFile'),'file')
                [~,fnm,ext]=fileparts(getGUIData('CurrentFile'));
                k=questdlg(['Overwrite ' [fnm ext]],'File Exists','Yes','Cancel','Yes');              
                if strcmpi(k,'Yes')
                    save(getGUIData('CurrentFile'),'SG');
                end
            end         
        end
        updateplots=false;        
% Export Options
    case handles.mExROMS
        [filename,pathname]=setGBfilename('*.nc','ROMS grid file','ROMS');
        if ~isnumeric(filename)
            % call to generate ROMS metrics and write netcdf file
            setExportROMSgrid(fullfile(pathname,filename));
        end
        updateplots=false;        
    case handles.mExSWAN
        [filename,pathname]=setGBfilename('*.grd','SWAN grid file','SWAN');
        if ~isnumeric(filename)
            % call to generate SWAN grid and bathymetry
            setExportSWANgrid(fullfile(pathname,filename));
        end
        updateplots=false;        
% Import Options
    case handles.mImROMS
        [filename,pathname]=getGUIfilename('*.nc','ROMS grid file');
        if ~isnumeric(filename)
            setGuiInitial(handles);
            SG=getROMSgrid(fullfile(pathname,filename));
            if ~isempty(SG)
                setROMSgrid(SG);
                setGridUpdate('Mask','Depths');
                setGUIData('gridLoaded',true);
                handles.rbGrid.Value=1;
            end
        else            
            updateplots=false;
        end 
    case handles.mSG_Load_Coast
        [coastname,coastpath]=getGUIfilename('*.*','Select a Coastline File');
        if coastname==0
            return;
        end
        user_coast=getUserCoastline(fullfile(coastpath,coastname));
        if ~isempty(user_coast)
            setGUIData(user_coast);
            setGUIData('usercoast',true);
            handles.rbUserCoast.Enable='on';
            handles.rbUserCoast.Value=1.0;
            set(handles.mMaskUser,'enable','on');
            set(handles.mMaskRes,'enable','off');
            setGridUpdate('Coast');
            if getGUIData('gridLoaded')&&(handles.rbMask.Value==1)
                setGridMask();
                setGridUpdate('Mask','Depths');
            end
        else
            updateplots=false;
        end
    case handles.mSG_Load_Bath
        %   the variables
        %   are expected to be "xbathy" (latitude), "ybathy" (longitude),
        %   "zbathy" (arbitrary units, positive downwards).  If an
        %   ascii file with three columns, the arrangement is expected
        %   to be [xbathy ybathy zbathy].
        [bathname,bathpath]=getGUIfilename('*.*','Select a Bathymetry File','MultiSelect','off');
        if isnumeric(bathname)
            return
        end
        user_BathyInterpolant=getUserBathymetry(fullfile(bathpath,bathname));
        if ~isempty(user_BathyInterpolant)
            setGUIData('depthGridState',false);
            switch class(user_BathyInterpolant)
                case 'scatteredInterpolant'
                    x=user_BathyInterpolant.Points(:,1);
                    y=user_BathyInterpolant.Points(:,2);
                case 'griddedInterpolant'
                    x=user_BathyInterpolant.GridVectors{1};
                    y=user_BathyInterpolant.GridVectors{2};                    
            end 
            setGUIData(user_BathyInterpolant);
            setGUIData('userbath',true);
            if getGUIData('gridLoaded')
                setGridDepths();
                setBackup();
                setlims=getGUIData('limits');
                setGridUpdate('Bathymetry','Mask','Depths');
            else     
                setlims=[min(x),max(x),min(y),max(y)];
            end
            % show off new bathymetry
            handles.rbBath.Value=1;
            setZoom('set',setlims);
        else            
            updateplots=false;
        end
    case handles.mRefPoints
        k=questdlg('Read in from file or Set on screen','Reference Points','Read-In','Set','Cancel','Read-In');
        unread=true;
        Ref=getGUIData('Ref');
        switch k
            case 'Read-In'
                [Ref,unread]=getRefPts(Ref);
            case 'Set'
                [Ref.x,Ref.y]=ginput;
                unread=false;
        end
        if ~unread
            if isfield(Ref,'h')
                delete(Ref.h);
                Ref=rmfield(Ref,'h');
            end
            setGUIData(Ref);
            set(handles.tbOverlay,'enable','on','State','on');
        end     
% Clear options
    case handles.mClearCoast
        setGUIData('usercoast',false);
        handles.mMaskUser.Enable='Off';
        setGUIData('user_coast',[]);
        set(getGUIData('user_hcoast'),'Visible','off');
        if getGUIData('gridLoaded')&&strcmpi(handles.mMaskUser.Checked,'On')
            % if use user mask was on when we cleared go to default
            % fastmask mode
            handles.mMaskUser.Checked='Off';
            handles.mMaskTopo.Checked='On';
            handles.mMaskRes.Enable='Off';
            setGUIData('FastMask',true);
            setGUIData('maskGridState',false);
            setGridMask();
            setGridUpdate('Mask');
            setBackup();
        end
        updateplots=false;       
    case handles.mClearDepths
        setGUIData('userbath',false);
        setGUIData('user_bathymetry',[]);
        set(getGUIData('user_hbath'),'Visible','off');
        set(getGUIData('user_hbath_bound'),'Visible','off');
        if getGUIData('gridLoaded')
            setGUIData('depthGridState',false);
            setGridCreate();
            setGridUpdate('Depths');
        end
        updateplots=false;       
% Edit Options
    case {handles.tbRedo,handles.mRedo}
        igrid=getGUIData('igrid');
        igrid=igrid+1;
        setGUIData('dobackup',false);
        setRestoreGrid(igrid);
        setGridUpdate('Grid','Mask','Depths');
        setGUIData('dobackup',true);
    case {handles.tbUndo,handles.mUndo}
        igrid=getGUIData('igrid');
        igrid=igrid-1;
        setGUIData('dobackup',false);
        setRestoreGrid(igrid);
        setGridUpdate('Grid','Mask','Depths');
        setGUIData('dobackup',true);    
% Mask Options
    case handles.mMaskTopo
        hObject.Checked='On';
        handles.mMaskGSHHG.Checked='Off';
        handles.mMaskUser.Checked='Off';
        handles.mMaskRes.Enable='Off';
        setGUIData('FastMask',true);
        setGUIData('userMask',false);
        if getGUIData('gridLoaded')
            setGUIData('maskGridState',false);
            setGridMask();
            setGridUpdate('Mask');
            setBackup();
        end
        updateplots=false;       
    case handles.mMaskGSHHG
        hObject.Checked='On';
        handles.mMaskTopo.Checked='Off';
        handles.mMaskUser.Checked='Off';
        handles.mMaskRes.Enable='On';
        setGUIData('FastMask',false);
        setGUIData('userMask',false);
        if getGUIData('gridLoaded')
            setGUIData('maskGridState',false);
            setGridMask();
            setGridUpdate('Mask');
            setBackup();
        end
        updateplots=false;       
    case handles.mMaskUser
        hObject.Checked='On';
        handles.mMaskTopo.Checked='Off';
        handles.mMaskGSHHG.Checked='Off';
        handles.mMaskRes.Enable='Off';
        setGUIData('FastMask',false)
        setGUIData('userMask',true);
        if getGUIData('gridLoaded')
            setGUIData('maskGridState',false);
            setGridMask();
            setGridUpdate('Mask');
            setBackup();
        end
        updateplots=false;       
    case {handles.mFullRes,handles.mHighRes,handles.mIntRes,handles.mLowRes,handles.mCoarseRes,handles.mAutoRes}
        set(getGUIData('maskViewDep'),'Checked','off')
        set(hObject,'Checked','on');
        setGridMask();
        setGridUpdate('Mask');
% Help/Info Options
    case {handles.tbAbout,handles.mAbout}
        [id, datenumber]=getVersion();
        msgbox({['GridBuilder v' id];datestr(datenumber,'dd mmmm yyyy');'Author: Charles james';'e-mail: charles.james@sa.gov.au'},'About Grid Builder','Help')
        updateplots=false;       
    case handles.mDoc
        web('gbhelp.html');
        updateplots=false;       
% toolbar zoom and pan options
    case handles.tbZoomMan
        % turn off panning
        state=hObject.State;
        if strcmpi(state,'on')
            % set hittest on mask to off in case it is visible
            handles.tbPan.Enable='off';
            set(getGUIData('hmask'),'HitTest','off');
            set(getGUIData('hdepths'),'HitTest','off'); 
            set(handles.MainAxis,'HitTest','on','PickableParts','All');
            set([handles.panMode],'visible','off');
            handles.MainFigure.PointerShapeCData=getGUIData('magpointer');           
            handles.MainFigure.Pointer='custom';
            setGUIData('ZoomOn',true);
        else
            handles.tbPan.Enable='on';
            set([handles.panMode],'visible','on');
            set(getGUIData('hmask'),'HitTest','on');
            setGUIData('ZoomOn',false);
            handles.MainFigure.Pointer='arrow';
        end
        updateplots=false;       
    case handles.tbZoomOutMan
        setZoom('zoomout');
        updateplots=false;       
    case handles.tbPan
        switch handles.tbPan.State
            case 'on'
                % turn off Bathymetry, Mask, and Orthogonality for panning
                handles.tbZoomMan.Enable='off';
                handles.tbZoomOutMan.Enable='off';
                setGUIData('prepanState',[handles.rbBath.Value,handles.rbDepths.Value,handles.rbMask.Value,handles.rbOrthog.Value]);
                handles.rbBath.Value=0;handles.rbBath.Enable='off';
                handles.rbDepths.Value=0;
                handles.rbMask.Value=0;
                handles.rbOrthog.Value=0;
                set([handles.panMode, handles.panGridEl,handles.panMetrics],'visible','off');
                setGUIData('PanOn',true);
            case 'off'            
                handles.tbZoomMan.Enable='on';
                handles.tbZoomOutMan.Enable='on';    
                prepanState=getGUIData('prepanState');
                handles.rbBath.Value=prepanState(1);handles.rbBath.Enable='on';
                handles.rbDepths.Value=prepanState(2);
                handles.rbMask.Value=prepanState(3);
                handles.rbOrthog.Value=prepanState(4);
                setGridUpdate('Bathymetry');
                set([handles.panMode, handles.panGridEl,handles.panMetrics],'visible','on');
                setGUIData('PanOn',false);
        end 
    case handles.tbSubGrid
        % CreateSubGrid
        [corner,grid,side,mask,depths,hselect]=getSubGrid(handles);
        if ~isempty(hselect)
            qcleargrid=questdlg('Clear Unselected Grid?','Sub Grid Selected','yes','cancel','cancel');
        else
            return
        end
        if strcmp(qcleargrid,'yes')
            qsavegrid=questdlg('Do you want to save the existing grid before it is cleared?','Clearing Main Grid','yes','no','yes');
            if strcmp(qsavegrid,'yes')
                GridBuilderCallbacks(handles.mSG_Save_As,[],handles);
            end%     
            % remove any control points as they won't be on boundary of new
            % sub grid
            for i=1:4
                delete(side(i).control.handle);
                side(i).control.x=[];
                side(i).control.y=[];
                side(i).control.handle=[];
            end
            setGUIData(corner);
            setGUIData(grid);
            setGUIData(side);     
            setGUIData('maskGridState',false);
            setGUIData('depthGridState',false);
            % do depths before mask in case grid mask depends on depths
            if isempty(depths) 
                depths=setGridDepths();
            end            
            if isempty(mask)
                mask=setGridMask();
            end                
            setGUIData(mask);
            setGUIData(depths);
            subSG=setGridBuilderFile();
            getGridBuilderFile(subSG);
            handles.rbGrid.Value=1;
            setBackup();
            setZoom('set');
        end
           
        delete(hselect);
%% Grid Resolution Panel
    case handles.Nedit
        grid=getGUIData('grid');
        n=grid.n;
        newn=getTxt2Num(hObject);
        if isnan(newn)
            set(hObject,'string',int2str(n));
        else
            newn=max(newn,3);
            set(hObject,'string',int2str(newn),'FontAngle','Italic','FontWeight','bold');
        end
        updateplots=false;       
    case handles.Medit
        grid=getGUIData('grid');
        m=grid.m;
        newm=getTxt2Num(hObject);
        if isnan(newm)
            set(hObject,'string',int2str(m));
        else
            % poisson solver needs at least 3x3
            newm=max(newm,3);
            set(hObject,'string',int2str(newm),'FontAngle','Italic','FontWeight','bold');
        end
        updateplots=false;       
    case handles.pbResDone
        grid=getGUIData('grid');
        newn=round(str2double(get(handles.Nedit,'string')));
        newm=round(str2double(get(handles.Medit,'string')));
        set(handles.Medit,'FontAngle','normal','FontWeight','normal');
        set(handles.Nedit,'FontAngle','normal','FontWeight','normal');
        drawnow;
        if ~isnan(newn)&&~isnan(newm)
            % refresh mask and depths
            setGUIData('depthGridState',false);
            setGUIData('maskGridState',false);
            grid.n=newn+1;
            grid.m=newm+1;
            setGUIData(grid);
            setGridCreate();
            setGridUpdate('Grid','Mask','Depths');
        else
            handles.Nedit.String=int2str(grid.n);
            handles.Medit.String=int2str(grid.m);
            updateplots=false;
        end
%%  Grid Properties Panel
    case handles.puGtype
        contents=get(hObject,'String');
        value=get(hObject,'Value');
        GridType=contents{value};
        switch GridType
            case {'Orthogonal','Rectangle'}
                setGUIData('maskGridState',false);
                setGUIData('depthGridState',false);
                setGUIData(GridType);
                % check we are not in middle of assigning corner points
                if strcmpi(getGUIData('cornermode'),'add')
                   setGUIData('cornermode',[]); 
                   setGUIData('corner',[]);
                   set(getGUIData('hcorner'),'Visible','off');
                end
                
                % clear all control points
                side=getGUIData('side');
                c.x=[];c.y=[];c.handle=[];
                cnt=[side.control];
                delete([cnt.handle]);
                [side.control]=deal(c);
                setGUIData(side);
                % square grid
                corner=getGUIData('corner');
                if ~isempty(corner)
                    corner=setResizeCornerRectOrthog(corner);
                    setGUIData(corner);
                    setGridCreate();
                    setGridUpdate('Grid','Mask','Depths');
                end
            case 'Free'
                setGUIData('GridType','Free');
                setBackup();
            case 'Fixed'
                setGUIData('GridType','Fixed');
                setBackup();
        end
        setGUIData(GridType);
    case handles.puCoord
        setGUIData('projection',hObject.String{hObject.Value});
        % if we switch to Cartesian we have to reset zoom level and limits
        if strcmpi(getGUIData('projection'),'Cartesian')
            [zoomlims(1:2), ~]=getMapCoord([-180 180],[0 0],'ll2xy');
            [~,zoomlims(3:4)]=getMapCoord([0 0],[-90 90],'ll2xy');
            setGUIData('zoomlims',zoomlims);
            setGUIData('zoomlevel',1);
        end
        if getGUIData('gridLoaded')
            setGUIData('maskGridState',false);
            setGUIData('depthGridState',false);
            setGridBuilderCoord(handles)
            setGridUpdate('Grid','Mask','Depths');
        else
            setGuiInitial(handles);
        end
    case handles.puVertType
        switch hObject.String{hObject.Value}
            case 'ROMS'
                setGUIData('SigmaCoord',true);
                setGridRx1();
                setGridUpdate('depths');
                setSigAxis(handles);
                setBackup();
            otherwise
                setGUIData('SigmaCoord',false);
                setGUIData('rx1',[]);
        end
        updateplots=false;       
    case handles.MainAxis
        if getGUIData('ZoomOn')
            if strcmp(handles.tbZoomMan.State,'on')
                setZoom('zoomin');
            end
        elseif getGUIData('PanOn')
            % should be unreachable but just in case don't set corners
        else
            setGridCorners(handles)
        end
%% Rotate Panel
    case handles.sbRot
        Rotation=get(hObject,'Value');
        Dtheta=Rotation-getGUIData('Rotation');
        setGUIData(Dtheta);
        set(handles.editRot,'String',num2str(Rotation,'%4.1f'));
        setGUIData(Rotation);
        setGridPosition();
        setGridUpdate('Grid','Mask','Depths');
        updateplots=false;       
    case handles.editRot
        oldRot=getGUIData('Rotation');
        Rotation=str2double(get(hObject,'String'));
        if isnan(Rotation)||(Rotation<-180)||(Rotation>180)
            set(hObject,'String',num2str(oldRot,4));
            setGUIData('Dtheta',0);
        else
            Dtheta=Rotation-getGUIData('Rotation');
            setGUIData(Dtheta);
            setGUIData(Rotation);
            set(handles.sbRot,'value',Rotation);
            setGridPosition();
            setGridUpdate('Grid','Mask','Depths');
        end
        updateplots=false;       
    case handles.pbRotFinish
        set(handles.panRot,'visible','off');
        setGUIData('GridEdit','corners');
        setGUIData('maskGridState',false);
        setGUIData('depthGridState',false);
        setGUIData('Dtheta',0);
        % Rebuild grid for all but Orthogonal rotations
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
        setButtonState(getGUIData('rbState'));
        handles.rbCorners.Value=1.0;
        handles.rbRot.Value=0.0;
        gridViewDep=getGUIData('gridViewDep');
        set(gridViewDep,'enable','on');
        delete(getGUIData('trace'));
%% Screen Mode Select
    case handles.panMode
        hmask=getGUIData('hmask');
        hdepths=getGUIData('hdepths');
        if all(ishandle(hmask))
            set(hmask,'hittest','off');
        end
        if all(ishandle(hdepths))
            set(hdepths,'hittest','off');
        end
        switch eventdata.NewValue
            case handles.rbModGrid
                setGUIData('ScreenMode','modgrid');
                % most options available
                setGridToggle('on',{'Sides','Corners'});
                set(handles.panGrid,'visible','on');                
                set([handles.panMaskEdit handles.panDepthEdit,handles.panROMSsigma],'visible','off');
                set([handles.Nedit handles.Medit],'enable','on');                
                % reset to corners to avoid funny looking grid;
                setGUIData('GridEdit','corners');
                handles.panGrid.SelectedObject=handles.rbCorners;
            case handles.rbModMask
                setGUIData('ScreenMode','modmask');
                % hide grid, and turn on toggle view:  coastline and mask
                % turn off toggle view: bathymetry and depth
                % but leave options to turn on again
                % turn off selection mechanisim each time we select mod
                % mask
                handles.puSelectMask.Value=1;
                setGUIData('imaskSelect',false(size(getGUIData('mask'))));
                setGridToggle('off');
                set(handles.panMaskEdit,'visible','on');
                set([handles.panGrid, handles.panDepthEdit,handles.panROMSsigma],'visible','off');
                handles.rbMask.Value=1;
                hmask=getGUIData('hmask');
                set(hmask,'hittest','on');
                set([handles.Nedit handles.Medit],'enable','off');
                if ~getGUIData('maskGridState')
                    setGridMask();
                end
                setGridUpdate('Mask');
            case handles.rbModBath
                setGUIData('ScreenMode','modbath');
                % hide grid, and turn on toggle view:  coastline and depth
                % turn off toggle view: bathymetry and mask
                % but leave options to turn on again
                setGridToggle('off',{'Grid','Corners','Side','Control','Spacer','Mask','Orthogonality'});
                set(handles.panDepthEdit,'visible','on');
                set([handles.panGrid,handles.panMaskEdit,handles.panROMSsigma],'visible','off');
                if (handles.rbDepths.Value==0)&&(handles.rbRx0.Value==0)&&(handles.rbRx1.Value==0)
                    handles.rbRx0.Value=1;
                end
                hdepths=getGUIData('hdepths');
                set(hdepths,'hittest','on');
                set([handles.Nedit handles.Medit],'enable','off');
                if ~getGUIData('depthGridState')
                    setGridDepths();
                    setGridUpdate('Depths');
                end
                depths=getGUIData('depths');
                minDepth=min(depths(:));
                maxDepth=max(depths(:));
                setGUIData(minDepth);
                setGUIData(maxDepth);
                handles.minDepthEdit.String=num2str(minDepth);
                handles.maxDepthEdit.String=num2str(maxDepth);
                setGridDepths();
                setGridUpdate('depths');
            case handles.rbModVert                
                setGUIData('ScreenMode','modvert');
                % hide grid, and turn on toggle view:  coastline and depth
                % turn off toggle view: bathymetry and mask
                % but leave options to turn on again
                setGridToggle('off');
                set(handles.panROMSsigma,'visible','on');
                set([handles.panGrid,handles.panMaskEdit,handles.panDepthEdit],'visible','off');
                if (handles.rbDepths.Value==0)&&(handles.rbRx0.Value==0)&&(handles.rbRx1.Value==0)
                    handles.rbRx1.Value=1;
                end
                setGridUpdate('depths');      
        end
%% Modify Grid Panel
    case handles.panGrid
        rbState=getButtonState();
        setGUIData(rbState);
        switch eventdata.OldValue
            case handles.rbRotate
                setGridCreate();
                setGridUpdate('Grid','Mask','Depths')
                gridViewDep=getGUIData('gridViewDep');
                set(gridViewDep,'enable','on');
                delete(getGUIData('trace'));
        end
        set(handles.panRot,'visible','off');
        switch eventdata.NewValue
            case handles.rbCorners
                GridEdit='corners';
                setGridToggle({'on','on','off','off'},{'Side','Corners','Control','Spacers'});
            case handles.rbControl
                GridEdit='control';
                setGridToggle({'on','off','on','off'},{'Side','Corners','Control','Spacers'});
            case handles.rbSpacer
                GridEdit='spacers';
                setGridToggle({'on','off','off','on'},{'Side','Corners','Control','Spacers'});
            case handles.rbRotate
                GridEdit='rotate';
                setGridToggle('off');
                set(getGUIData('hcb'),'Visible','off');
                trace=setTraceOutline();
                setGUIData(trace);
            case handles.rbTranslate
                GridEdit='translate';
                setGridToggle('on',{'Side','Corners'})
                setGridToggle('off',{'Control','Spacers'});
            case handles.rbExpand
                GridEdit='expand';
                setGridToggle('off',{'Control','Spacers','Corners'});
        end
        setGUIData(GridEdit);
    case handles.pbClearCP
        side=getGUIData('side');
        for i=1:4
            delete(side(i).control.handle);
            side(i).control.x=[];
            side(i).control.y=[];
            side(i).control.handle=[];
        end
        setGUIData(side);
        setGridCreate();
        setGridUpdate('grid');
        updateplots=false;       
%% Modify Mask Panel
    case handles.pbClearMask
        mask=getGUIData('mask');
        mask=ones(size(mask));
        setGUIData(mask);
        setGridUpdate('Mask');
        setBackup();
        updateplots=false;       
    case handles.pbResetMask
        setGUIData('maskGridState',false);
        setGridMask();
        setGridUpdate('Mask');
        setBackup();
        updateplots=false;       
    case handles.pbFillSelectedMask
        imaskSelect=getGUIData('imaskSelect');
        if any(imaskSelect(:))
            mask=getGUIData('mask');    
            choice=handles.puSelectMask.String{handles.puSelectMask.Value};
            if strcmpi(choice,'Contiguous')
                switch(handles.panMaskEdit.SelectedObject)
                    case handles.rbLandMask
                        mask(imaskSelect)=false;
                    case handles.rbOceanMask
                        mask(imaskSelect)=true;
                    case handles.rbToggleMask
                        mask(imaskSelect)=~mask(imaskSelect);
                end
            else
                mask(imaskSelect)=false;
                imaskSelect=getMaskFeature(mask,choice);
                if ~any(imaskSelect(:))
                    set(handles.puSelectMask,'Value',1);
                end
            end
            setGUIData(imaskSelect);
            setGUIData(mask);
            setGridUpdate('mask');
        end
        updateplots=false;
    case handles.puSelectMask
        mask=getGUIData('mask');
        choice=hObject.String{hObject.Value};
        imaskSelect=getMaskFeature(mask,choice);
        setGUIData(imaskSelect);
        setGridUpdate('mask');
        updateplots=false;       
%% Modify Bathymetry Panel
    case handles.minDepthEdit
        minDepth=getGUIData('minDepth');
        maxDepth=getGUIData('maxDepth');
        newMinDepth=getTxt2Num(hObject);
        if ~isnan(newMinDepth)
            minDepth=newMinDepth;
        end
        if minDepth>=maxDepth
            minDepth=maxDepth-1;
        end
        hObject.String=num2str(minDepth);
        setGUIData(minDepth);
        depths=getGUIData('depths');
        setGUIData('depthGridState',false);
        setGridDepths(depths);
        setGridUpdate('depths');
        setBackup();
    case handles.maxDepthEdit       
        minDepth=getGUIData('minDepth'); 
        maxDepth=getGUIData('maxDepth');
        newMaxDepth=getTxt2Num(hObject);
        if ~isnan(newMaxDepth)
            maxDepth=newMaxDepth;
        end
        if minDepth>=maxDepth
            maxDepth=minDepth+1;
        end
        hObject.String=num2str(maxDepth);
        setGUIData(maxDepth);
        depths=getGUIData('depths');
        setGUIData('depthGridState',false);
        setGridDepths(depths);
        setGridUpdate('depths');
        setBackup();
    case handles.pbResetDepths
        setGUIData('minDepth',[]);
        setGUIData('maxDepth',[]);
        setGUIData('depthGridState',false);
        setGridDepths();
        setGridUpdate('depths');
        setBackup();
    case handles.edTargetRx0
        fieldvalue=getTxt2Num(hObject);
        switch handles.puFilterType.Value
            case {1,2}
                fldname='rx0Max';
            case {3,4}
                fldname='shapiroDepth';
        end
        if isnan(fieldvalue)
            hObject.String=num2str(getGUIData(fldname),'%4.2f');
        else
            hObject.String=num2str(fieldvalue,'%4.2f');
            setGUIData(fldname,fieldvalue);
        end
        updateplots=false;       
    case handles.puFilterType
        switch hObject.Value
            case {1,2}
                handles.txtTargetRx0.String='Target rx0';
                handles.edTargetRx0.String=num2str(getGUIData('rx0Max'),'%4.2f');
                set(getGUIData('filtOrderDep'),'Visible','off');
            case {3,4}
                handles.txtTargetRx0.String='Apply below';
                handles.edTargetRx0.String=num2str(getGUIData('shapiroDepth'),'%4.2f');
                set(getGUIData('filtOrderDep'),'Visible','on');
        end
        updateplots=false;       
    case handles.pbFilterDepths
        depths=getGUIData('depths');
        mask=getGUIData('mask');
        if isempty(depths)
            depths=setGridDepths();
        end
        if isempty(mask)
            mask=setGridMask();
        end
        depths=setGridFilter(depths,mask,handles);
        setGUIData(depths);
        setGridUpdate('depths');
        setBackup();
%% ROMS S Coordinate Panel
    case handles.edZlev 
        Sigcoef=getGUIData('Sigcoef');
        N=getTxt2Num(hObject);
        if isnan(N)||N<2
            hObject.String=int2str(Sigcoef.N);
            return
        else
            Sigcoef.N=N;
            setGUIData(Sigcoef);
        end
        setGridUpdate('depths');
        setBackup();
    case handles.puVtrans
        Sigcoef=getGUIData('Sigcoef');
        Sigcoef.Vtransform=hObject.Value;
        setGUIData(Sigcoef);
        setGridUpdate('depths');
        setBackup();
    case handles.puVstretch
        Sigcoef=getGUIData('Sigcoef');
        Sigcoef.Vstretching=hObject.Value;
        setGUIData(Sigcoef);
        setGridUpdate('depths');
        setBackup();
    case handles.edThetaS
        Sigcoef=getGUIData('Sigcoef');
        Sold=Sigcoef;
        Theta_S=getTxt2Num(hObject);
        if isnan(Theta_S)
            hObject.String=num2str(Sigcoef.Theta_S,'%4.2f');
            return
        else
            Sigcoef.Theta_S=Theta_S;
            hObject.String=num2str(Sigcoef.Theta_S,'%4.2f');
            setGUIData(Sigcoef);
        end
        ztest=testROMSz;
        if any(~isfinite(ztest))
            setGUIData('Sigcoef',Sold);
            hObject.String=num2str(Sold.Theta_S,'%4.2f');
            return
        end
        setGridUpdate('depths');
        setBackup();
    case handles.edThetaB
        Sigcoef=getGUIData('Sigcoef');
        Sold=Sigcoef;
        Theta_B=getTxt2Num(hObject);
        if isnan(Theta_B)
            hObject.String=num2str(Sigcoef.Theta_B,'%4.2f');
            return
        else
            Sigcoef.Theta_B=Theta_B;
            hObject.String=num2str(Sigcoef.Theta_B,'%4.2f');
            setGUIData(Sigcoef);
        end
        ztest=testROMSz;
        if any(~isfinite(ztest))
            setGUIData('Sigcoef',Sold);
            hObject.String=num2str(Sold.Theta_B,'%4.2f');
            return
        end
        setGridUpdate('depths');
        setBackup();
    case handles.edTcline
        Sigcoef=getGUIData('Sigcoef');
        Sold=Sigcoef;
        Tcline=getTxt2Num(hObject);
        if isnan(Tcline)||(Tcline<=0)
            hObject.String=num2str(Sigcoef.Tcline,'%4.2f');
            return
        else
            Sigcoef.Tcline=Tcline;
            hObject.String=num2str(Sigcoef.Tcline,'%4.2f');
            setGUIData(Sigcoef);
        end
        ztest=testROMSz;
        if any(~isfinite(ztest))
            setGUIData('Sigcoef',Sold);
            hObject.String=num2str(Sold.Tcline,'%4.2f');
            return
        end
        setGridUpdate('depths');
        setBackup();
%% Map Elements Panel
    case {handles.rbCoast,handles.rbBath}
    case handles.rbBath
%%  Grid Elements Panel
    case handles.rbGrid
    case handles.rbDepths
        if hObject.Value==1
            if ~getGUIData('depthGridState')||isempty(getGUIData('depths'))
                setGridDepths();
                setGridUpdate('Depths');
            end
        end
    case handles.rbMask
        if hObject.Value==1
            if ~getGUIData('maskGridState')||isempty(getGUIData('mask'))
                setGridMask();
                setGridUpdate('Mask');
            end
        end
        % if we are updating orthogonality on basis of wet cells only
        setGridUpdate('Grid');
    case handles.rbUserCoast
%% Grid Metrics Panel
    case handles.rbOrthog
        if hObject.Value==1
            handles.rbRx0.Value=0;
            handles.rbRx1.Value=0;
        end
    case handles.rbRx0
        if hObject.Value==1
            handles.rbOrthog.Value=0;
            handles.rbRx1.Value=0;
            if ~getGUIData('depthGridState')
                setGridRx0();
                setGridUpdate('depths');
            end
        end
    case handles.rbRx1
        if hObject.Value==1
            handles.rbOrthog.Value=0;
            handles.rbRx0.Value=0;
            if ~getGUIData('depthGridState')
                setGridRx1();
                setGridUpdate('depths');
            end
        end
%% Colorbar Limits Panel
    case {handles.editMaxCaxis,handles.editMinCaxis}
        minval=getTxt2Num(handles.editMinCaxis);
        maxval=getTxt2Num(handles.editMaxCaxis);
        [Caxis,haxis]=setCaxis(handles);
        if ~isnan(minval)
            Caxis(1)=minval;
        end
        if ~isnan(maxval)
            Caxis(2)=maxval;
        end
        Caxis=sort(Caxis);
        caxis(haxis,Caxis);
        setCaxis(handles);
    case handles.pbAutoCaxis
        setCaxis(handles,'auto');
%% ETC.
    case 'Unused'
        % this point is never reached but it contains calls to m files that
        % are embedded in callbacks but not explicitly called - this just
        % makes sure they get placed in the compiler project
        setGridModify('do nothing');
        setZoom('do nothing');
        setPostPan('do nothing');
end
% Save updating plots for callbacks that don't change plot settings

if updateplots
    setPlotsUpdate();
end
setWidgetsUpdate(handles)
end
%%
function ztest=testROMSz
Sigcoef=getGUIData('Sigcoef');
ztest=squeeze(getROMSsigma(Sigcoef.Tcline*2,'rho'));
end
