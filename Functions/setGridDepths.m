function depths=setGridDepths(depths)
% function depths=setGridDepths(depths)
% returns and updates depths
% and user_bathyInterpolant (if available)
% Charles James 2017

if getGUIData('depthGridState')
    % only reset things if we need a new depth state
    depths=getGUIData('depths');
    return;
end

handles=getGUIData('handles');

if nargin==0
    depths=getGridDepths();
end

minDepth=getGUIData('minDepth');
if isempty(minDepth)
    minDepth=min(depths(:));
    setGUIData(minDepth);
    handles.minDepthEdit.String=num2str(minDepth);
end
maxDepth=getGUIData('maxDepth');
if isempty(maxDepth)
    maxDepth=max(depths(:));
    setGUIData(maxDepth);
    handles.maxDepthEdit.String=num2str(maxDepth);
end

depths(depths>maxDepth)=maxDepth;
depths(depths<minDepth)=minDepth;
setGUIData(depths);
setGUIData('depthGridState',true);

end
%%
function depths=getGridDepths()
% function depths=getGridDepths
% compute depths for Grid
% Charles James 2017

grid=getGUIData('grid');
% mask and depths are computed on mid points of cells (rho points in ROMS)
% grid is on augmented psi grid.
[X,Y]=getBpsi2rho(grid.x,grid.y);

% global topography is not defined for cartesian projections - we set a
% default constant depth of 1000m
if strcmpi(getGUIData('projection'),'Cartesian')
    depths=getGUIData('depths');
    if isempty(depths)
        cart_BathyInterpolant=getGUIData('cart_BathyInterpolant');
       depths=cart_BathyInterpolant(X,Y);
    end
    return;
end

BathyInterpolant=getGUIData('BathyInterpolant');
if getGUIData('userbath')
    user_BathyInterpolant=getGUIData('user_BathyInterpolant');
    switch class(user_BathyInterpolant)
        case 'scatteredInterpolant'
            x=user_BathyInterpolant.Points(:,1);
            y=user_BathyInterpolant.Points(:,2);
            k=convhull(x,y);
            xb=x(k);
            yb=y(k);
        case 'griddedInterpolant'
            x1=min(user_BathyInterpolant.GridVectors{1});
            x2=max(user_BathyInterpolant.GridVectors{1});
            xb=[x1 x1 x2 x2];
            y1=min(user_BathyInterpolant.GridVectors{2});
            y2=max(user_BathyInterpolant.GridVectors{2});
            yb=[y1 y2 y2 y1];
    end
    depths=user_BathyInterpolant(X,Y);
    
    % replace any out of bounds points or NaN's
    OOB=~inpolygon(X,Y,xb,yb)|isnan(depths);
    if any(OOB(:))
        % merge with default bathymetry (might not be pretty!)
        depths(OOB)=BathyInterpolant(X(OOB),Y(OOB));
    end
else
    depths=BathyInterpolant(X,Y);
end
end