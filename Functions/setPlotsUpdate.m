function setPlotsUpdate()
% function setPlotsUpdate()
% systematically checks visibility of various plotted elements against GUI
% settings and dependencies to maintain consistency after callbacks have
% been executed.  
% Charles James 2017

handles=getGUIData('handles');
setWatch('on');

hcoast=getGUIData('hcoast');
hgrid=getGUIData('hgrid');
user_hcoast=getGUIData('user_hcoast');
hbath=getGUIData('hbath');
user_hbath=getGUIData('user_hbath');
user_hbath_bound=getGUIData('user_hbath_bound');
hmask=getGUIData('hmask');
hmaskSelect=getGUIData('hmaskSelect');
hdepths=getGUIData('hdepths');
horthog=getGUIData('horthog');
hrx0=getGUIData('hrx0');
hrx1=getGUIData('hrx1');
%grid=getGUIData('grid');
hcb=getGUIData('hcb');
Visible=getGUIData('Visible');

editControl=(handles.rbControl.Value==1);


showCoast=(handles.rbCoast.Value==1);
showUserCoast=(handles.rbUserCoast.Value==1);
showBath=(handles.rbBath.Value==1);
showGrid=(handles.rbGrid.Value==1);
showMask=(handles.rbMask.Value==1);
showDepths=(handles.rbDepths.Value==1);
showRx0=(handles.rbRx0.Value==1);
showRx1=(handles.rbRx1.Value==1);
showOrthog=(handles.rbOrthog.Value==1);

% Fix Limits
axis(handles.MainAxis,getGUIData('limits'));
setZoom('set');


if editControl
    handles.pbClearCP.Enable='on';
else
    handles.pbClearCP.Enable='off';
end

if showCoast
    set(hcoast,'Visible','on');
else
    set(hcoast,'Visible','off');
end

if getGUIData('usercoast')
    if showUserCoast
        set(user_hcoast,'Visible','on');
    else
        set(user_hcoast,'Visible','off');
    end
else
    handles.rbUserCoast.Value=0.0;
    handles.rbUserCoast.Enable='off';
end

if getGUIData('gridLoaded')
    if showGrid
        set(hgrid,'Visible','on');
        Visible.grid='on';
    else
        set(hgrid,'Visible','off');
        Visible.grid='off';
    end
    
    if showOrthog
        set(horthog,'Visible','on');
        caxis(handles.ColAxis,getGUIData('orthog_caxis'));
        Visible.orthogonality='on';
    else
        set(horthog,'Visible','off');
        Visible.orthogonality='off';
    end
    
    if showRx0
        set(hrx0,'Visible','on');
        caxis(handles.ColAxis,getGUIData('rx0_caxis'));
        Visible.rx0='on';
    else
        set(hrx0,'Visible','off');
        Visible.rx0='off';
    end
    if showRx1
        set(hrx1,'Visible','on');
        caxis(handles.ColAxis,getGUIData('rx1_caxis'));
        Visible.rx1='on';
    else
        set(hrx1,'Visible','off');
        Visible.rx1='off';
    end
    if showMask
        set(hmask,'Visible','on');
        Visible.mask='on';
        caxis(handles.BWAxis,getGUIData('mask_caxis'));
        if ishandle(hmaskSelect)
            set(hmaskSelect,'Visible','on');
        end
    else
        set(hmask,'Visible','off');
        Visible.mask='off';
        if ishandle(hmaskSelect)
            set(hmaskSelect,'Visible','off');
        end
    end
    if showDepths
        hdepths=getGUIData('hdepths');
        set(hdepths,'Visible','on');
        caxis(handles.BWAxis,getGUIData('bath_caxis'));
        Visible.depths='on';
    else
        set(hdepths,'Visible','off');
        Visible.depths='off';
    end
    
    setGUIData(Visible);
    if strcmpi(getGUIData('ScreenMode'),'modvert')
        % update sigma level plots
       setSigAxis(handles); 
    end
    
    % create consistent grid elements in edit mode
    if strcmpi(getGUIData('ScreenMode'),'modgrid')
        hcorner=getGUIData('hcorner');
        hside=getGUIData('hside');
        switch getGUIData('GridEdit')
            case 'corners'
                set(hside,'Color','r');
                set(hcorner,'MarkerFaceColor','r');
                set(hcorner(1),'MarkerFaceColor','b');
            case 'control'
                set(hside,'Color','r');
            case 'spacers'
                set(hside,'Color','r');
            case 'rotate'
                gridViewDep=getGUIData('gridViewDep');
                set(gridViewDep,'enable','off');
                set(handles.panRot,'visible','on');
            case 'translate'
                set(hside,'Color','r');
                set(hcorner,'MarkerFaceColor','b');
            case 'expand'     
                set(hside,'color','b');                      
        end
        
    end
    
end


if showBath&&getGUIData('userbath')
    set(user_hbath,'Visible','on');
    set(user_hbath_bound,'Visible','on');
else
    set(user_hbath,'Visible','off');
    set(user_hbath_bound,'Visible','off');
end
if showBath
    set(hbath,'Visible','on');
    caxis(handles.BWAxis,getGUIData('bath_caxis'));
else
    set(hbath,'Visible','off');
end

set(hcb,'Visible','off')
if showOrthog||showRx0||showRx1
    set(hcb(3),'Visible','on');
elseif showDepths||showBath
    set(hcb(2),'Visible','on');
end

setWatch('off');
handles.MainFigure.Pointer='arrow';
end