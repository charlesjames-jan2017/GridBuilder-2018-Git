function getGridBuilderFile(fname)
if isstruct(fname)
    D.SG=fname;
else
    D=load(fname);
end
handles=getGUIData('handles');
% .SG field is legeacy of old Seagrid name
if isfield(D,'SG')
    % new style file
    SG=D.SG;
    setGUIData('grid',SG.grid);
    setGUIData('side',SG.side);
    setGUIData('corner',SG.corner);
    setGUIData('mask',SG.mask);
    setGUIData('depths',SG.depths);
    setGUIData('minDepth',min(SG.depths(:)));
    setGUIData('maxDepth',max(SG.depths(:)));
    
    if isfield(SG,'userbath')
        setGUIData('userbath',SG.userbath);
        if SG.userbath
            if isfield(SG,'user_BathyInterpolant')
                setGUIData('user_BathyInterpolant',SG.user_BathyInterpolant);
            else
                setGUIData('user_BathyInterpolant',getUserBathymetry(SG));
            end
        end
    else
        setGUIData('userbath',true);
        setGUIData('user_BathyInterpolant',getUserBathymetry(SG));
    end    
    setGUIData('coast',SG.coast);
    setGUIData('bathymetry',SG.bathymetry);
    % Bug fix
    if isfield(SG,'bathyInterpolant')
        BathyInterpolant=SG.bathyInterpolant;
    elseif isfield(SG,'BathyInterpolant')
        BathyInterpolant=SG.BathyInterpolant;
    else
        BathyInterpolant=[];
    end
    if ~isempty(BathyInterpolant)
        setGUIData(BathyInterpolant);
    end
    
    
    if isfield(SG,'usercoast')
        setGUIData('usercoast',SG.usercoast);
        if SG.usercoast
            if isfield(SG,'user_coast')
                setGUIData('user_coast',SG.user_coast);
            else
                setGUIData('usercoast',false);
            end
        end
    end
    setGUIData('limits',SG.limits);
    % older SG or GB files may not have field RefPt used by new
    % orthogonal grid (GB 1.1+)
    if ~isfield(SG.Translation,'RefPt')
       SG.Translation.RefPt=[0,0];
    end
    setGUIData('Translation',SG.Translation);
    setGUIData('Rotation',SG.Rotation);
    setGUIData('Dtheta',SG.Dtheta);
    setGUIData('projection',SG.projection);
    setGUIData('GridType',SG.GridType);
    
    set(handles.editRot,'String',num2str(SG.Rotation,4));    
    set(handles.sbRot,'value',SG.Rotation);
    setGUIData('cornermode','done');
    gridDep=getGUIData('gridDep');
    set(gridDep,'enable','on');
    setZoom('set');
    setGridUpdate('Grid','Mask');
    setGUIData('gridLoaded',true);
    handles.puGtype.Value=find(ismember(handles.puGtype.String,SG.GridType));
    if strcmpi(SG.projection,'Spherical')
        handles.puCoord.Value=1;
    else
        handles.puCoord.Value=2;
    end
    % does this grid have any vertical data?
    if isfield(SG,'Z')
        setGUIData('SigmaCoord',true);
        zstyle=fieldnames(SG.Z);
        zstyle=zstyle{1};
        Z=SG.Z.(zstyle);
        switch zstyle
            case 'ROMS'
                setGUIData('Sigcoef',Z);
            otherwise
                % nothing to put here yet but we could get here with an
                % outdated GridBuilder File
                setGUIData('SigmaCoord',false);
                zstyle='None';
        end
        handles.puVertType.Value=find(strcmpi(handles.puVertType.String,zstyle));
    end
        setGridUpdate('depths');
elseif isfield(D,'s')&&isfield(D.s,'geographic_grids')
    % this is an old seagrid file
    grid=getGUIData('grid');
    s=D.s;
    % set grid
    grid.x=s.geographic_grids{1};
    grid.y=s.geographic_grids{2};
    
    limits=[min(grid.x(:))-.5 max(grid.x(:))+.5 min(grid.y(:))-.5 max(grid.y(:))+.5];
    setGUIData(limits);
    
    [m,n]=size(grid.x);
    grid.m=m;
    grid.n=n;
    % treat them all as spherical for import.
    grid.coord='spherical';
    [pm,pn,~,~,xl,el,~]=getROMSMetrics(grid.x,grid.y,grid.coord);
    grid.xl=xl;
    grid.el=el;
    grid.orthogonality=getOrthog(grid.x,grid.y);
    grid.minspacing=min([1./pn(:);1./pm(:)]);
    grid.mdy=mean(1./pn(:));
    grid.mdx=mean(1./pm(:));
    setGUIData(grid);
    
    %set corners
    corner(1).x=grid.x(1,1);
    corner(1).y=grid.y(1,1);
    corner(2).x=grid.x(end,1);
    corner(2).y=grid.y(end,1);
    corner(3).x=grid.x(end,end);
    corner(3).y=grid.y(end,end);
    corner(3).x=grid.x(end,end);
    corner(3).y=grid.y(end,end);
    corner(4).x=grid.x(1,end);
    corner(4).y=grid.y(1,end);
    setGUIData(corner);
    
    spaced_edges=s.spaced_edges;
    %set sides
    side(1).x=grid.x(:,1)';
    side(2).x=grid.x(end,:);
    side(3).x=fliplr(grid.x(:,end)');
    side(4).x=fliplr(grid.x(1,:));
    
    side(1).y=grid.y(:,1)';
    side(2).y=grid.y(end,:);
    side(3).y=fliplr(grid.y(:,end)');
    side(4).y=fliplr(grid.y(1,:));
    
    for i=1:4
        % default spacing
        edgetype=ismember(spaced_edges,i);
        if any(edgetype)
            side(i).spacing.active=true;
            side(i).spacing.handle=[];
            spc=s.spacings{edgetype};
            side(i).spacing.spindex=interp1(linspace(0,1,length(spc)),spc,linspace(0,1,7));
        else
            side(i).spacing.active=false;
            side(i).spacing.handle=[];
            side(i).spacing.spindex=[];
        end
    end
    
    % and control points
    points=s.points;
    xp=points(:,1);
    yp=points(:,2);
    crnp=points(:,3);
    icorner=crnp==1;
    % conversion from grid points to geographic points
    px=polyfit(xp(icorner),[corner.x]',1);
    py=polyfit(yp(icorner),[corner.y]',1);
    
    ind=find(icorner);
    cp=find(~icorner);
    for i=1:4
        istart=ind(i);
        if i<4
            iend=ind(i+1);
        else
            iend=length(xp)+1;
        end
        icp=cp((cp>istart)&(cp<iend));
        if any(icp)
            side(i).control.x=polyval(px,xp(icp));
            side(i).control.y=polyval(py,yp(icp));
        else
            side(i).control.x=[];
            side(i).control.y=[];
        end
        side(i).control.handle=[];
    end
    
    setGUIData(side);    
    
    % set mask and depth if computed
    if ~isempty(s.mask)
        setGUIData('mask',double(~s.mask));
    end
    if ~isempty(s.gridded_bathymetry)
        setGUIData('depths',s.gridded_bathymetry);
        setGUIData('minDepth',min(s.gridded_bathymetry(:)));
        setGUIData('maxDepth',max(s.gridded_bathymetry(:)));
    end
    

    % must be free type on spherical coordinates
    setGUIData('GridType','Free');
    handles.puGtype.Value=2;
    
    setGUIData('cornermode','done');
    gridDep=getGUIData('gridDep');
    set(gridDep,'enable','on');
    setGridUpdate('Coast','Bathymetry','Grid','Mask','Depths');
    setGUIData('gridLoaded',true);
    
    
end
handles.minDepthEdit.String=num2str(getGUIData('minDepth'));
handles.maxDepthEdit.String=num2str(getGUIData('maxDepth'));

setGUIData('maskGridState',true);
setGUIData('depthGridState',true);
setGridResDisplay(handles);
end
