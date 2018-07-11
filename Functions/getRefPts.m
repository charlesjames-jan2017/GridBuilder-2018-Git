function [Ref,unread]=getRefPts(Ref)
% function [Ref,unread]=getRefPts(Ref)
% Function to extract 2D data from a variety of formats
% Charles James 2018
unread=true;
[filename,pathname]=getGUIfilename({'*.*','All Files';'*.nc','ROMS grid file';'*.txt','XY data file'});
if filename~=0
    [~,~,ext]=fileparts(filename);
    filename=fullfile(pathname,filename);
    if strcmp(ext,'.nc')
        xfields={'x','lon','lon_rho','x_rho'};
        yfields={'y','lat','lat_rho','y_rho'};
        ni=ncinfo(filename);
        ncvars={ni.Variables.Name};
        ix=ismember(xfields,ncvars);
        iy=ismember(yfields,ncvars);
        if any(ix)&&any(iy)
            xvars=xfields(ix);
            yvars=yfields(iy);
            x=ncread(filename,xvars{1});
            y=ncread(filename,yvars{1});
            % only use boundaries of grid
            x(2:end-1,2:end-1)=NaN;
            y(2:end-1,2:end-1)=NaN;
            
            Ref.x=x(~isnan(x));
            Ref.y=y(~isnan(y));
            unread=false;
        end
    else
        try
            s=importdata(filename);
            if isstruct(s)
                if isfield(s,'data')
                    if size(s.data,2)==2
                        Ref.x=s.data(:,1);
                        Ref.y=s.data(:,2);
                        unread=false;
                    end
                elseif isfield(s,'x')&&isfield(s,'y')
                    Ref.x=s.x;
                    Ref.y=s.y;
                    unread=false;
                elseif isfield(s,'lon')&&isfield(s,'lat')
                    Ref.x=s.lon;
                    Ref.y=s.lat;
                    unread=false;
                end
            elseif isnumeric(s)&&(size(s,2)==2)
                Ref.x=s(:,1);
                Ref.y=s(:,2);
                unread=false;
            end
        catch
            unread=true;
        end
    end
end
end