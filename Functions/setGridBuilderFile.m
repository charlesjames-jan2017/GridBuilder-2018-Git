function SG=setGridBuilderFile()
handles=getGUIData('handles');
grid=getGUIData('grid');

SG.grid=grid;
SG.side=getGUIData('side');
SG.corner=getGUIData('corner');

% masks and depths updated as required - treat as empty if not updated
mask=getGUIData('mask');
if any(size(mask)~=[grid.m-1 grid.n-1])
    mask=[];
end
depths=getGUIData('depths');
if any(size(depths)~=[grid.m-1 grid.n-1])
    depths=[];
end

SG.mask=mask;
SG.depths=depths;
SG.coast=getGUIData('coast');
SG.bathymetry=getGUIData('bathymetry');
SG.limits=getGUIData('limits');
SG.Translation=getGUIData('Translation');
SG.Rotation=getGUIData('Rotation');
SG.Dtheta=getGUIData('Dtheta');
SG.projection=getGUIData('projection');
SG.GridType=getGUIData('GridType');
SG.BathyInterpolant=getGUIData('BathyInterpolant');
SG.userbath=getGUIData('userbath');
SG.user_BathyInterpolant=getGUIData('user_BathyInterpolant');
SG.usercoast=getGUIData('usercoast');
SG.user_coast=getGUIData('user_coast');
if getGUIData('SigmaCoord')
   zstyle=handles.puVertType.String{handles.puVertType.Value};
   SG.Z.(zstyle)=getGUIData('Sigcoef');     
end
end
