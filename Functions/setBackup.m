function setBackup()
% function setBackup()
% function to backup current state of grid so it can be restored later if
% required
% Charles James 2017

% internal grids can be reset
% external grids keep grid properties on first import

side=getGUIData('side');
corner=getGUIData('corner');
handles=getGUIData('handles');
grid=getGUIData('grid');
mask=getGUIData('mask');
depths=getGUIData('depths');
projection=getGUIData('projection');
GridType=getGUIData('GridType');
Rotation=getGUIData('Rotation');
Translation=getGUIData('Translation');

igrid=getGUIData('igrid');
backup=getGUIData('backup');

nbackups=length(backup);
% new backup means no more going forward
if igrid<nbackups
    backup(igrid+1:nbackups)=[];
end

if ~isempty(side)
    igrid=igrid+1;
    backup(igrid).side=side;
    backup(igrid).corner=corner;
    backup(igrid).grid=grid;
    backup(igrid).limits=axis(handles.MainAxis);
    backup(igrid).mask=mask;
    backup(igrid).depths=depths;
    backup(igrid).projection=projection;
    backup(igrid).GridType=GridType;
    backup(igrid).Rotation=Rotation;
    backup(igrid).Translation=Translation;
    
    % store depth edit settings
    backup(igrid).minDepth=getGUIData('minDepth');
    backup(igrid).maxDepth=getGUIData('maxDepth');
    Sigcoef=getGUIData('Sigcoef');
    backup(igrid).Z.ROMS=Sigcoef;
    setGUIData(backup);
    setGUIData(igrid)
end

if igrid>1
    set([handles.tbUndo,handles.mUndo],'enable','on');
else
    set([handles.tbUndo,handles.mUndo],'enable','off');
end
set([handles.tbRedo,handles.mRedo],'enable','off');
end