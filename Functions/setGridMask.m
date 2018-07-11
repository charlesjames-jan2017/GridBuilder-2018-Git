function mask=setGridMask()
% function mask=setGridMask()
% generates land mask for current grid in various ways
% Charles James 2017

if getGUIData('maskGridState')
    mask=getGUIData('mask');
    return
end

grid=getGUIData('grid');
FastMask=getGUIData('FastMask');
if FastMask
    if getGUIData('userbath')
        % it is up to user to ensure there is bathymetry data where the
        % grid exists
        BathyInterpolant=getGUIData('user_BathyInterpolant');
    elseif strcmpi(grid.coord,'spherical')
        % use etopo2
        BathyInterpolant=getGUIData('BathyInterpolant');
    elseif strcmpi(grid.coord,'cartesian')
        BathyInterpolant=getGUIData('cart_BathyInterpolant');
    end
    [x,y]=getBpsi2rho(grid.x,grid.y);
    depths=BathyInterpolant(x,y);
    mask=double(depths>=0);
else
    if strcmpi(grid.coord,'spherical')
        if getGUIData('usercoast')&&getGUIData('userMask')
            % it is up to user to ensure there is coastline data where the grid
            coast=getGUIData('user_coast');
        else
            % generate appropriate resoution coastline to create mask
            minspacing=grid.minspacing/1000;
            glimits=[min(grid.x(:)) max(grid.x(:)) min(grid.y(:)) max(grid.y(:))];
            % base ideal coastal resolution on model grid resolution (in km)
            if minspacing<2
                res=5;
            elseif minspacing<5
                res=4;
            elseif minspacing<20
                res=3;
            elseif minspacing<50
                res=2;
            else
                res=1;
            end
            % no need to make resolution higher than necessary for grid!
            maskres=getGUIData('maskres');
            if maskres~=0
                res=min(getGUIData('maskres'),res);
            end
            setGUIData('currentRes',res);
            [coast.lon,coast.lat]=getCoastline(glimits,[],res);
        end
    else
        % for cartesean coordinates
        % only user coast is available
        if getGUIData('usercoast')
            coast=getGUIData('user_coast');
        else
            coast=[];
        end
    end
    
    % mask and depths are computed on mid points of cells (rho points in ROMS)
    % grid is on augmented psi grid.
    [X,Y]=getBpsi2rho(grid.x,grid.y);
    
    if ~isempty(coast)
        lon=coast.lon(:);
        lat=coast.lat(:);
        mask=~coast2mask(X,Y,lon,lat);
    else
        mask=true(size(X));
    end
    mask=double(mask);
end

omask=zeros(size(mask)+1);
omask(1:end-1,1:end-1)=mask;
omask(2:end,1:end-1)=omask(2:end,1:end-1)+mask;
omask(2:end,2:end)=omask(2:end,2:end)+mask;
omask(1:end-1,2:end)=omask(1:end-1,2:end)+mask;
omask(omask>=1)=1;
setGUIData(omask);
setGUIData(mask);

setGUIData('maskGridState',true);
end
%%
function Mask=coast2mask(X,Y,bx,by)
% selects ROI within M based on boundary defined by bx and by
bx=bx(:);
by=by(:);
N=numel(X);
segs=[1;find(isnan(bx));length(bx)];
Mask=false(size(X));
allsegs=sum(~isnan(bx))-sum(isnan(bx));
setWatch('on');
if allsegs>1000
    count=0;
    h=waitbar(count,'Generating Mask, Please Wait');
    usebar=true;
else
    usebar=false;
end
if N<10000
    useinpoly=true;
else
    useinpoly=false;
end
for iseg=1:length(segs)-1
    I=false(size(X));
    ind=segs(iseg):segs(iseg+1);
    x=bx(ind);
    y=by(ind);
    xp=x(~isnan(x));
    yp=y(~isnan(y));
    if length(xp)<3
        if usebar
            count=count+1;
            waitbar(count./allsegs,h);
        end
    else
        if useinpoly
            I=inpolygon(X,Y,x,y);
            if usebar
                count=count+length(xp);
                waitbar(count./allsegs,h);
            end
        else
            xp=xp(:);
            yp=yp(:);
            % make sure polygon closes
            if(xp(end)~=xp(1))||(yp(end)~=yp(1))
                xp(end+1)=xp(1);
                yp(end+1)=yp(1);
            end
            
            mnX=min(X(:));
            mxX=max(X(:));
            
            segx=[xp(1:end-1),xp(2:end)];
            segy=[yp(1:end-1),yp(2:end)];
            mxx=max(segx,[],2);
            mnx=min(segx,[],2);
            
            % don't use segments that are outside range of X values
            outside=(mxx<mnX)|(mnx>mxX);
            %outside=false;
            allsegs=allsegs-sum(outside);
            segx(outside,:)=[];
            segy(outside,:)=[];
            if length(segx)>1
                dx=diff(segx,[],2);
                dy=diff(segy,[],2);
                m=dy./dx;
                sx=sum(segx,2);
                sy=sum(segy,2);
                b=(sy-m.*sx)./2;
                
                pp=[m(:),b(:)];
                for i=1:length(pp)
                    if usebar
                        count=count+1;
                        waitbar(count./allsegs,h);
                    end
                    above=Y>polyval(pp(i,:),X);
                    between=(X>=min(segx(i,:)))&(X<=max(segx(i,:)));
                    I(above&between)=~I(above&between);
                end
            else               
                if usebar
                    count=count+1;
                    waitbar(count./allsegs,h);
                end
            end
        end
    end
    Mask(I)=~Mask(I);
end

if usebar
    delete(h);
end

setWatch('off');
end