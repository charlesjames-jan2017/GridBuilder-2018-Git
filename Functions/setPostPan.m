function setPostPan(limits)
% function setPostPan(limits)
% function to control figure element resolutions after a zoom
% Charles James 2017
handles=getGUIData('handles');
getVarcheck('limits',[handles.MainAxis.XLim,handles.MainAxis.YLim]);
% if called with a character string do nothing (see callback for 'Unused')
if ischar(limits(1))
    return
end
if handles.puCoord.Value==1
    % for Spherical Coordinates check bathymetry and coastlines
    %N and S limits must be +/-90
    limits(3)=max(limits(3),-90);
    limits(4)=min(limits(4),+90);
    
    
    [lon,lat]=getCoastline(limits);
    coast.lon=lon;
    coast.lat=lat;
    setGUIData(coast);
    setGUIData(limits);
    setGridUpdate('Coast');
    
    minx=limits(1);
    maxx=limits(2);
    dlon=maxx-minx;
    if dlon>90
        res=8;
    elseif dlon>45
        res=4;
    else
        res=2;
    end
    dres=2*res/60;
    %for bathymetry go out 1 extra row to ensure no gaps at edge of figure
    b_limits=limits;
    b_limits(1)=b_limits(1)-dres;b_limits(2)=b_limits(2)+dres;b_limits(3)=b_limits(3)-dres;b_limits(4)=b_limits(4)+dres;
    [bathymetry.zbathy,bathymetry.xbathy,bathymetry.ybathy]=getDefaultBathymetry(b_limits,res);
    if min(size(bathymetry.zbathy))>1
        BathyInterpolant=griddedInterpolant(bathymetry.xbathy,bathymetry.ybathy,bathymetry.zbathy,'linear','none');
        setGUIData(bathymetry);
        setGUIData(BathyInterpolant);
        %else
        % we must be too close for this bathymetry - just continue to use
        % current settings
    end
    axis(handles.MainAxis,limits);
    axis(handles.BWAxis,limits);
    axis(handles.ColAxis,limits);
else
% don't need to do much for cartesean coords just store new limits
    setGUIData(limits);
end
setBackup();
end
