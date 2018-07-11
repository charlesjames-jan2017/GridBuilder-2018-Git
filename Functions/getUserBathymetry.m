function user_BathyInterpolant=getUserBathymetry(fname)
% function user_BathyInterpolant=getUserBathymetry(fname)
% loads bathymetry in old and new format and converts to new format
% Charles James 2018
xbathy=[];
ybathy=[];
zbathy=[];
xfields={'X','x','xbathy','lon','Lon','longitude','Longitude','LON','x_rho','lon_rho'};
yfields={'Y','y','ybathy','lat','Lat','latitude','Latitude','LAT','y_rho','lat_rho'};
zfields={'Z','h','z','zbathy','depth','Depth','DEPTH','Elevation','Band1','depths','topo_depth5'};
unread=true;
user_BathyInterpolant=[];
setWatch('on');
if isstruct(fname)
    s=fname;
else
    if iscell(fname)
        fnames=fname;
    else
        fnames={fname};
    end
    for ifiles=1:length(fnames)
        fname=fnames{ifiles};
        [~,~,ext]=fileparts(fname);
        switch ext
            case '.nc'
                % netCDF
                % probably ROMS but could be another netcdf file (have
                % supported for at least one CCSM grid for import)
                ni=ncinfo(fname);
                vars={ni.Variables.Name};
                ix=ismember(vars,xfields);
                iy=ismember(vars,yfields);
                iz=ismember(vars,zfields);
                if any(ix)&&any(iy)&&any(iz)
                    for ivar=1:length(vars)
                        if ismember(vars{ivar},xfields)||ismember(vars{ivar},yfields)||ismember(vars{ivar},zfields)
                            s.(vars{ivar})=ncread(fname,vars{ivar});
                        end
                    end
                    unread=false;
                end
            case '.mat'
                % Matlab File
                s=load(fname);
                flds=fieldnames(s);
                if ismember('SG',flds)
                    % this is (probably) a seagrid file
                    s=s.SG;
                    if isfield(s,'user_BathyInterpolant')&&~isempty(s.user_BathyInterpolant)
                        % we can use this one and return now!
                        user_BathyInterpolant=s.user_BathyInterpolant;
                        setWatch('off');
                        return
                    else
                        % perhaps you have some nice smoothed data here
                        % you'd like to use?
                        [s.x,s.y]=getBpsi2rho(s.grid.x,s.grid.y);
                        s.z=s.depths;
                        unread=false;
                    end
                else
                    % check necessary variables are in matlab file
                    ix=ismember(flds,xfields);
                    iy=ismember(flds,yfields);
                    iz=ismember(flds,zfields);
                    if any(ix)&&any(iy)&&any(iz)
                        unread=false;
                    end
                end
            otherwise
                % For ASCII data but will probably work with simple Excel
                % We'll try and read it with importdata and see what
                % happens
                try
                    s=importdata(fname);
                    if isstruct(s)
                        % if number of columns == number of text fields in
                        % first row then importdata returns field colheaders
                        if isfield(s,'colheaders')
                            vars=s.colheaders;
                            % assign variable names in case of lat,lon,depth
                            % format
                            for icol=1:length(vars)
                                s.(vars{icol})=s.data(:,icol);
                            end
                            unread=false;
                        elseif size(s.data,2)==3
                            % assume lon,lat,depth and see how we go
                            s.x=s.data(:,1);
                            s.y=s.data(:,2);
                            s.z=s.data(:,3);
                            unread=false;
                        end
                    elseif isnumeric(s)
                        % no column headers assume lon,lat,depth
                        if size(s.data,2)==3
                            s.x=s.data(:,1);
                            s.y=s.data(:,2);
                            s.z=s.data(:,3);
                            unread=false;
                        end
                    end
                catch
                    unread=true;
                end                
        end
    end
end
if unread
    % if we didn't find any bathymetry return empty handed
    warndlg({'No Recognised Bathymetry Formats';'Please contact us so we can add file formats to future updates'});
    user_BathyInterpolant=[];
    setWatch('off');
    return
end
% check structure for min of 3 fields (x,y,z)
if isstruct(s)
    flds=fieldnames(s);
    if length(flds)==1
        % load function assigns variables to structure for mat files
        % if only one it may be a structure itself
        s=s.(flds{1});
    end
end
switch class(s)
    case 'double'
        if size(s, 2) == 3   % Three columns.
            xbathy = s(:, 1);
            ybathy = s(:, 2);
            zbathy = s(:, 3);
        end
    case 'struct'
        flds=fieldnames(s);
        if length(flds)==1
            % mat file was probably already a structure
            s=s.(flds);
            if isstruct(s)
                flds=fieldnames(s);
                if length(flds)<3
                    setWatch('off');
                    return
                end
                
            end
        end
        for i=1:length(flds)
            var=s.(flds{i});
            switch flds{i}
                case xfields
                    xbathy=var(:);
                case yfields
                    ybathy=var(:);
                case zfields
                    zsize=size(var);
                    zbathy=var(:);
                case 'grid'
                    % probably a GridBuilder grid file
                    if ismember('bathymetry',flds)
                        if isfield(s.bathymetry,'xbathy')&&isfield(s.bathymetry,'ybathy')&&isfield(s.bathymetry,'zbathy')
                            xbathy=s.bathymetry.xbathy(:);
                            ybathy=s.bathymetry.ybathy(:);
                            zbathy=s.bathymetry.zbathy(:);
                            break
                        else
                            zbathy=var(:);
                        end
                    elseif isstruct(s.grid)&&isfield(s.grid,'x')&&isfield(s.grid,'y')
                        [xbathy,ybathy]=getBpsi2rho(s.grid.x,s.grid.y);
                        xbathy=xbathy(:);
                        ybathy=ybathy(:);
                    end
            end
        end
        
end

if isempty(zbathy)
    % if we don't find any bathymetry return empty handed
    warndlg({['Unable to read bathymetry in: ' fname];'Please contact us if you can tell us how to read bathymetry from this file!'});
    user_BathyInterpolant=[];
    setWatch('off');
    return
end
% fix sign of z here to make z+ for depth
signcoef=getDepthSign(xbathy,ybathy,zbathy);
zbathy=zbathy.*signcoef;

if getGUIData('userbath')
    setWatch('off');
    hquest=questdlg({'User bathymetry already exists';'What would you like to do?'},'Bathymetry Options','Merge','Replace','Cancel Import','Cancel Import');
    switch hquest
        case 'Merge'
            user_bathymetry=getGUIData('user_bathymetry');
            % add new x,y,z  duplicate points should be averaged by
            % interpolation routines
            user_bathymetry.xbathy=cat(1,user_bathymetry.xbathy(:),xbathy(:));
            user_bathymetry.ybathy=cat(1,user_bathymetry.ybathy(:),ybathy(:));
            user_bathymetry.zbathy=cat(1,user_bathymetry.zbathy(:),zbathy(:));
        case 'Replace'
            user_bathymetry.xbathy=xbathy;
            user_bathymetry.ybathy=ybathy;
            user_bathymetry.zbathy=zbathy;
        case 'Cancel Import'
            user_BathyInterpolant=[];
            setWatch('off');
            return
    end
else
    user_bathymetry.xbathy=xbathy;
    user_bathymetry.ybathy=ybathy;
    user_bathymetry.zbathy=zbathy;
end
setWatch('on');

xbathy=user_bathymetry.xbathy;
ybathy=user_bathymetry.ybathy;
zbathy=user_bathymetry.zbathy;


% if x,y variables are in vector form we want to form a grid
if isvector(zbathy)
    if length(xbathy)*length(ybathy)==length(zbathy)
        if length(xbathy)==zsize(2)
            [xbathy,ybathy]=meshgrid(xbathy,ybathy);
            zbathy=reshape(zbathy,zsize);
            xbathy=xbathy';
            ybathy=ybathy';
            zbathy=zbathy';
            xbathy=xbathy(:);
            ybathy=ybathy(:);
            zbathy=zbathy(:);
        elseif length(xbathy)==zsize(1)
            [xbathy,ybathy]=ndgrid(xbathy,ybathy);
        end
        xbathy=xbathy(:);
        ybathy=ybathy(:);
    end
    

    
    [X,Y,Z]=getXYZ2grid(xbathy,ybathy,zbathy);
    
    if isempty(Z)
        % have to do scattered interpolation (may be slow)
        igood=~isnan(zbathy.*xbathy.*ybathy);        
        if length(xbathy(igood))>1000000
            dquest=questdlg({['Caution, Large Number of Scattered Data: '...
                int2str(length(xbathy)) ' elements'];'Gridding May Freeze System'},...
                'Gridding Caution','Continue Importing','Cancel Importing','Cancel Importing');
            if strcmpi(dquest,'Cancel Importing')
                user_BathyInterpolant=[];
                setWatch('off');
                return
            end
        end
               
        hwait=waitdlg('Gridding: Please Wait');
        user_BathyInterpolant=scatteredInterpolant(xbathy(igood),ybathy(igood),zbathy(igood),'linear','none');
        delete(hwait);
    else
        % replace NaN's with best available bathymetry (will be slower if
        % region is large!)
        if any(isnan(Z(:)))
            [bathymetry.zbathy,bathymetry.xbathy,bathymetry.ybathy]=getDefaultBathymetry([min(X(:)),max(X(:)),min(Y(:)),max(Y(:))],2);
            BathyInterpolant=griddedInterpolant(bathymetry.xbathy,bathymetry.ybathy,bathymetry.zbathy,'linear','none');
            ibad=isnan(Z);
            Z(ibad)=BathyInterpolant(X(ibad),Y(ibad));
        end
        user_BathyInterpolant=griddedInterpolant(X,Y,Z,'linear','none');
    end
else
    try
        user_BathyInterpolant=griddedInterpolant(xbathy,ybathy,zbathy,'linear','none');
    catch
        user_BathyInterpolant=scatteredInterpolant(xbathy(:),ybathy(:),zbathy(:),'linear','none');
    end
end

setWatch('off');

setGUIData(user_bathymetry);
setGUIData('minDepth',min(Z(:)));
setGUIData('maxDepth',max(Z(:)));

end
%%
function h=waitdlg(varargin)
% function h=waitdlg(varargin)
% Charles James 2017
h=msgbox(varargin{:});
% remove ok button
k=h.Children;
iok=strcmpi(get(k,'Tag'),'OKButton');
delete(k(iok));
end