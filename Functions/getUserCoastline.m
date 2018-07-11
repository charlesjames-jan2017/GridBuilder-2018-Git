function coast=getUserCoastline(fname)
% loads bathymetry in old and new format and converts to new format
coast=[];
lon=[];
lat=[];
s=load(fname);
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
        if size(s, 2) >= 2   % use first 2 columns.
            lon = s(:, 1);
            lat = s(:, 2);
        end
    case 'struct'
        flds=fieldnames(s);
        for i=1:length(flds)
            switch(flds{i})
                case {'x','lon','Lon','longitude','Longitude','LON'}
                    lon=s.(flds{i});
                case {'y','lat','Lat','latitude','Latitude','LAT'}
                    lat=s.(flds{i});
            end
        end
end

if ~isempty(lon)&&~isempty(lat)
    % create consistent size
    lon=lon(:)';
    lat=lat(:)';
    
    coast.lon=lon;
    coast.lat=lat;
end

end
