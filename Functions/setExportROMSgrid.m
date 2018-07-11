function setExportROMSgrid(fname)
% function setExportROMSgrid(fname)
% called from GridBuilder - makes ROMS grid file with metrics and masks

grid=getGUIData('grid');

% grid points are on rho points
[Var.x_rho,Var.y_rho]=getBpsi2rho(grid.x,grid.y);
[Lp,Mp]=size(Var.x_rho);
L=Lp-1;
M=Mp-1;
% recaluculate u,v, and psi grids from rho grid;

vind=1:M;
uind=1:L;

Var.x_u=(Var.x_rho(uind,:)+Var.x_rho(uind+1,:))*.5;
Var.y_u=(Var.y_rho(uind,:)+Var.y_rho(uind+1,:))*.5;
Var.x_v=(Var.x_rho(:,vind)+Var.x_rho(:,vind+1))*.5;
Var.y_v=(Var.y_rho(:,vind)+Var.y_rho(:,vind+1))*.5;
Var.x_psi=(Var.x_u(:,vind)+Var.x_u(:,vind+1))*.5;
Var.y_psi=(Var.y_u(:,vind)+Var.y_u(:,vind+1))*.5;


% mask is on rho points
% make sure mask and depths are up to date, depths first in case mask is
% depth dependent
if ~getGUIData('depthGridState')
    setGridDepths();
    setGridUpdate('Depths');
end
if ~getGUIData('maskGridState')
    setGridMask();
    setGridUpdate('Mask');
end

Var.mask_rho=getGUIData('mask');
    
% from Arango's uvp_masks.m:
%  Land/Sea mask on U-points.
Var.mask_u=Var.mask_rho(2:Lp,1:Mp).*Var.mask_rho(1:L,1:Mp);

%  Land/Sea mask on V-points.
Var.mask_v=Var.mask_rho(1:Lp,2:Mp).*Var.mask_rho(1:Lp,1:M);

%  Land/Sea mask on PSI-points.
Var.mask_psi=Var.mask_rho(1:L,1:M ).*Var.mask_rho(2:Lp,1:M ).* ...
    Var.mask_rho(1:L,2:Mp).*Var.mask_rho(2:Lp,2:Mp);


% rawish h is based on original Interpolant
BathyInterpolant=getGUIData('BathyInterpolant');
if getGUIData('userbath')
    user_BathyInterpolant=getGUIData('user_BathyInterpolant');
    Var.hraw=user_BathyInterpolant(Var.x_rho,Var.y_rho);
    % Nan's come from outside user domain - replace missing points with
    % default etopo values - not pretty but all we got
    ind=isnan(Var.hraw);
    if any(ind(:))
        Var.hraw(ind)=BathyInterpolant(Var.x_rho(ind),Var.y_rho(ind));
    end
else   
    Var.hraw=BathyInterpolant(Var.x_rho,Var.y_rho);
end

% h is on rho points and is positive
% if using 

% depths tracks any modifications to h
Var.h=getGUIData('depths');
% set land depths to 0
%Var.h(Var.mask_rho==0)=0;

if isempty(Var.h)
    Var.h=Var.hraw;
end
Var.depthmin=min(Var.h(:));
Var.depthmax=max(Var.h(:));

% get angles
% works for Cartesian (flat) or Mercator (great circles)
switch grid.coord
    case 'cartesian'
        % Flat Earth fplane
        Var.spherical='F';
        f0=getGUIData('f0');
        if isempty(f0)
            % no rotation set
            Var.f=0;
        elseif isscalar(f0)
            % f-plane
            Var.f=f0.*ones(size(Var.x_rho));
        else
            % user defined
            Var.f=f0;
        end
        uselatlon=false;
    case 'spherical'
        % Mercator
        % coriolis
        Var.f=2*(7.292e-5)*sin(Var.y_rho*pi/180);
        Var.spherical='T';
        uselatlon=true;
end
Var.pm=grid.pm;
Var.pn=grid.pn;
Var.dndx=grid.dndx;
Var.dmde=grid.dmde;
Var.xl=grid.xl;
Var.el=grid.el;
Var.angle=grid.angle;

% design nc schema
gridschema.Name='/';
% required dimensions
[Dim.xi_rho,Dim.eta_rho]=size(Var.x_rho);
[Dim.xi_u,Dim.eta_u]=size(Var.x_u);
[Dim.xi_v,Dim.eta_v]=size(Var.x_v);
[Dim.xi_psi,Dim.eta_psi]=size(Var.x_psi);
Dim.one=1;

Dimensions=struct;
dimnames={'xi_rho','eta_rho','xi_u','eta_u',...
    'xi_v','eta_v','xi_psi','eta_psi','one'};
for idim=1:length(dimnames)
    Dimensions(idim).Name=dimnames{idim};
    Dimensions(idim).Length=Dim.(dimnames{idim});
end

dimlen=[Dimensions.Length];

gridschema.Dimensions=Dimensions;

varnames={'xl','el','depthmin','depthmax','spherical',...
    'angle','h','hraw','f',...
    'pm','pn','dndx','dmde',...
    'x_rho','x_u','x_v','x_psi',...
    'y_rho','y_u','y_v','y_psi',...
    'mask_rho','mask_u','mask_v','mask_psi'};


VA.long_names={'domain length in the XI-direction'
    'domain length in the ETA-direction'
    'Shallow bathymetry clipping depth'
    'Deep bathymetry clipping depth'
    'grid type logical switch'
    'angle between XI-axis and EAST'
    'bathymetry at RHO-points'
    'Working bathymetry at RHO-points'
    'Coriolis parameter at RHO-points'
    'curvilinear coordinate metric in XI'
    'curvilinear coordinate metric in ETA'
    'xi derivative of inverse metric factor pn'
    'eta derivative of inverse metric factor pm'
    'longitude of RHO-points'
    'longitude of U-points'
    'longitude of V-points'
    'longitude of PSI-points'
    'latitude of RHO-points'
    'latitude of U-points'
    'latitude of V-points'
    'latitude of PSI-points'
    'mask on RHO-points'
    'mask on U-points'
    'mask on V-points'
    'mask on psi-points'};

VA.units={'meter'
    'meter'
    'meter'
    'meter'
    ''
    'radians'
    'meter'
    'meter'
    'second-1'
    'meter-1'
    'meter-1'
    'meter-2'
    'meter-2'
    'degree_east'
    'degree_east'
    'degree_east'
    'degree_east'
    'degree_north'
    'degree_north'
    'degree_north'
    'degree_north'
    ''
    ''
    ''
    ''};

varatts=fieldnames(VA);


Variables=struct;
varnames_new=varnames;
for ivar=1:length(varnames)
    var0=varnames{ivar};
    if uselatlon
        var=strrep(strrep(var0,'y_','lat_'),'x_','lon_');
        varnames_new{ivar}=var;
    else
        var=var0;
    end
    
    Variables(ivar).Name=var;
    Value=Var.(var0);
    switch var0
        case {'x_rho','y_rho','mask_rho','angle','h','hraw','f','pm','pn','dndx','dmde'}
            dims={'xi_rho','eta_rho'};
            lens=[Dim.xi_rho,Dim.eta_rho];
        case {'x_u','y_u','mask_u'}
            dims={'xi_u','eta_u'};
            lens=[Dim.xi_u,Dim.eta_u];
        case {'x_v','y_v','mask_v'}
            dims={'xi_v','eta_v'};
            lens=[Dim.xi_v,Dim.eta_v];
        case {'x_psi','y_psi','mask_psi'}
            dims={'xi_psi','eta_psi'};
            lens=[Dim.xi_psi,Dim.eta_psi];
        otherwise
            if ~isvector(Value)
                s=size(Value);
            else
                s=length(Value);
            end
            for idim=1:length(s)
                ind=find(s(idim)==dimlen,1);
                dims{idim}=dimnames{ind};
                lens(idim)=s(idim);
            end            
    end
    for idim=1:length(dims)
        Variables(ivar).Dimensions(idim).Name=dims{idim};
        Variables(ivar).Dimensions(idim).Length=lens(idim);
    end
    
    for iatts=1:length(varatts)
        Variables(ivar).Attributes(iatts).Name=varatts{iatts};
        Variables(ivar).Attributes(iatts).Value=VA.(varatts{iatts}){ivar};
    end
    
    Variables(ivar).Datatype=class(Value);
    
end
gridschema.Variables=Variables;

gridschema.Attributes(1).Name='title';
gridschema.Attributes(1).Value='CustomGrid';
gridschema.Attributes(2).Name='date';
gridschema.Attributes(2).Value=datestr(now,'dd mmm yyyy');
gridschema.Attributes(3).Name='type';
gridschema.Attributes(3).Value='ROMS grid file';

gridschema.Format='64bit';
if ~exist(fname,'file')
    ncwriteschema(fname,gridschema)
end

for ivar=1:length(varnames_new)
    try
    ncwrite(fname,varnames_new{ivar},Var.(varnames{ivar}));
    catch
        pause
    end
        
end
end
