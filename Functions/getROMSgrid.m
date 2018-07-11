function SG=getROMSgrid(fname)
nci=ncinfo(fname);
ncvariables={nci.Variables.Name};
% to generate a ROMS grid we need at a miniumum rho x and y points,
% bathymetry, and mask
has_x=false;
has_y=false;
has_mask=false;
has_h=false;
spherical=false;
for i=1:length(ncvariables)
    switch ncvariables{i}
        case 'lon_rho'
            has_x=true;
            spherical=true;
        case 'x_rho'
            has_x=true;
            spherical=false;
        case 'lat_rho'
            has_y=true;
            spherical=true;
        case 'y_rho'
            has_y=true;
            spherical=false;
        case 'mask_rho'
            has_mask=true;
        case 'h'
            has_h=true;
    end
end

if has_x&&has_y&&has_mask&&has_h
    grid=getGUIData('grid');
    switch spherical
        case {'t','T',1,true}
            x=ncread(fname,'lon_rho');
            y=ncread(fname,'lat_rho');
            grid.coord='spherical';
        case {'f','F',0,false}
            x=ncread(fname,'x_rho');
            y=ncread(fname,'y_rho');
            grid.coord='cartesian';
    end
    
    SG.romsx=x;
    SG.romsy=y;
    [grid.x,grid.y]=getRho2Bpsi(x,y);
    [grid.m,grid.n]=size(grid.x);
    grid.type='curvilinear';
    
    % recalculate all metrics on rho grid
    [grid.pm,grid.pn,grid.dndx,grid.dmde,grid.xl,grid.el,grid.angle]=getROMSMetrics(x,y,grid.coord);
    
    grid.orthogonality=getOrthog(grid.x,grid.y);
    grid.minspacing=min([1./grid.pn(:);1./grid.pm(:)]);
    grid.mdy=mean(1./grid.pn(:));
    grid.mdx=mean(1./grid.pm(:));
    
    SG.grid=grid;
    
    side(1).x=grid.x(:,1)';
    side(2).x=grid.x(end,:);
    side(3).x=fliplr(grid.x(:,end)');
    side(4).x=fliplr(grid.x(1,:));
    
    side(1).y=grid.y(:,1)';
    side(2).y=grid.y(end,:);
    side(3).y=fliplr(grid.y(:,end)');
    side(4).y=fliplr(grid.y(1,:));
    
    % default spacing
    side(1).spacing.active=true;side(1).spacing.handle=[];
    side(2).spacing.active=true;side(2).spacing.handle=[];
    side(3).spacing.active=false;side(3).spacing.handle=[];
    side(4).spacing.active=false;side(4).spacing.handle=[];
    % keep track of index where points are
    side(1).spacing.spindex=linspace(0,1,7);
    side(2).spacing.spindex=linspace(0,1,7);
    side(3).spacing.spindex=[];
    side(4).spacing.spindex=[];
    
    % No control points now using Fixed Grid Creation Style
    for i=1:4
        side(i).control.x=[];side(i).control.y=[];
        side(i).control.handle=[];
    end
    SG.side=side;
    
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
    
    SG.corner=corner;
    % check to see if the grid has some natural rotation bias and call that
    % the rotation of the grid for corner rotation.
    
    SG.Rotation=median(grid.angle(:))*180/pi;
    
    SG.mask=ncread(fname,'mask_rho');
    
    % get grid bathymetery and set to user
    SG.depths=ncread(fname,'h');
    
    % if the grid contains raw topography use this for the
    % initial user_BathyInterpolant.
    % ROMS grids are generally treated as curvelinear so use
    % scattered interpolant to be safe (only slow for very large
    % grids)
    if any(strcmpi(ncvariables,'hraw'))
        depths=ncread(fname,'hraw');
        if isempty(depths)
            depths=SG.depths;
        end
        SG.user_BathyInterpolant=scatteredInterpolant(SG.romsx(:),SG.romsy(:),depths(:));
    else
        SG.user_BathyInterpolant=scatteredInterpolant(SG.romsx(:),SG.romsy(:),SG.depths(:));
    end
else
    [~,shortname]=fileparts(fname);
    wstr={};
    if ~has_x
        wstr=cat(1,wstr,'missing x coordinate: lon_rho or x_rho');
    end
    if ~has_y
        wstr=cat(1,wstr,'missing y_coordinate: lat_rho or y_rho');
    end
    if ~has_mask
        wstr=cat(1,wstr,'missing land mask: mask_rho');
    end
    if ~has_h
        wstr=cat(1,wstr,'missing bathymetry: h');
    end
    errordlg(cat(1,['File: ' shortname],wstr),'No ROMS grid');
    SG=[];
end
end
