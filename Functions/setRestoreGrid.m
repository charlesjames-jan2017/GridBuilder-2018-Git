function setRestoreGrid(igrid)
% function setRestoreGrid(igrid)
% extract a backup seagrid grid state
% Charles James 2018
handles=getGUIData('handles');
backup=getGUIData('backup');
% delete existing grid
side=getGUIData('side');
nbackups=length(backup);


set([handles.tbUndo handles.tbRedo handles.mUndo handles.mRedo],'enable','on');
if igrid>=nbackups
    set([handles.tbRedo,handles.mRedo],'enable','off');
    igrid=nbackups;
end
if igrid<=1
    set([handles.tbUndo,handles.mUndo],'enable','off');
	igrid=1;
end
for i=1:4
    hspace=side(i).spacing.handle;
    hcont=side(i).control.handle;
    delete(hspace(ishandle(hspace)));
    delete(hcont(ishandle(hcont)));
end


% update grid properties and make mask and depths current
setGUIData('grid',backup(igrid).grid);
setGUIData('side',backup(igrid).side);
setGUIData('corner',backup(igrid).corner);

GridType=backup(igrid).GridType;
setGUIData(GridType);
projection=backup(igrid).projection;
setGUIData(projection);
setGUIData('limits',backup(igrid).limits);
setGUIData('Rotation',backup(igrid).Rotation);
handles.sbRot.Value=getGUIData('Rotation');
setGUIData('Translation',backup(igrid).Translation);

setGUIData('minDepth',backup(igrid).minDepth);
setGUIData('maxDepth',backup(igrid).maxDepth);
handles.minDepthEdit.String=num2str(backup(igrid).minDepth);
handles.maxDepthEdit.String=num2str(backup(igrid).maxDepth);
Z=backup(igrid).Z.ROMS;
setGUIData('Sigcoef',Z);
handles.edZlev.String=int2str(Z.N);
handles.puVtrans.Value=Z.Vtransform;
handles.puVstretch.Value=Z.Vstretching;
handles.edThetaS.String=num2str(Z.Theta_S,'%4.2f');
handles.edThetaB.String=num2str(Z.Theta_B,'%4.2f');
handles.edTcline.String=num2str(Z.Tcline,'%4.2f');

handles.puGtype.Value=find(ismember(handles.puGtype.String,GridType));
if strcmpi(projection,'Spherical')
    handles.puCoord.Value=1;
else
    handles.puCoord.Value=2;
end

% do depths first in case mask is depth dependent
depths=backup(igrid).depths;
mask=backup(igrid).mask;

if isempty(depths)
    setGridDepths();
   backup(igrid).depths=getGUIData('depths');
else
    setGUIData(depths);
end
if isempty(mask)
   setGridMask();
   backup(igrid).mask=getGUIData('mask');
else
    setGUIData(mask);
end

setGUIData(backup);
setGUIData('maskGridState',true);
setGUIData('depthGridState',true);
setGUIData(igrid);

end
