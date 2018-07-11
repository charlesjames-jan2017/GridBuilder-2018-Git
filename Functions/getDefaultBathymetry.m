function [D,X,Y]=getDefaultBathymetry(axlim,res)
%function [D,X,Y]=getDefaultBathymetry(axlim,res)
% for region within axlim (or global if axlim='all')
% returns subset of  ETOPO2 (default) for res 2 (default)
% Charles James 2017
getVarcheck('res',2);
getVarcheck('axlim','all');
if ischar(axlim)&&strcmpi(axlim,'all')
    axlim=[0 360 -90 90];
end    
% do pole check
if axlim(3)<-90;axlim(3)=-90;end
if axlim(4)>90;axlim(4)=90;end


%x0=axlim(1);
res=max([res,2]);
%ETOPO defined from -180 to 180;
switch res
    case 2
        f='ETOPO2v2g_f4.nc4';
        x=ncread(f,'x');
        y=ncread(f,'y');
        varname='z';
        dx=1;
    otherwise        
        f='ETOPO2v2g_f4.nc4';
        x=ncread(f,'x');
        % lowest x=-180, largest x=180, same point!
        x(end)=[];
        y=ncread(f,'y');
        varname='z';
        dx=res;    
end
x=double(x);
y=double(y);

topolim=[-180 180 -90 90];
[topo_x,topo_y]=getAxis2xy(topolim);
% course adjustment on axlim
gridadj=0;
if axlim(2)<-180
    axlim(1:2)=axlim(1:2)+360;
    gridadj=-360;
elseif axlim(1)>180
    axlim(1:2)=axlim(1:2)-360;
    gridadj=360;
end
[ax_x, ax_y]=getAxis2xy(axlim);
ind=inpolygon(ax_x,ax_y,topo_x,topo_y);
btest=sum(ind);
ymin=axlim(3);
ymax=axlim(4);
switch btest
    case 4
    % carry on axis limits lie within topography
    ngroups=1;
    xmin=axlim(1);
    xmax=axlim(2);
    offset=0;
    case 2
    % part of the axis limits cross the +180 or -180 boundary
    % do two passes and merge results
       ngroups=2;
       i=find(ind);
       if (i(1)==1)
           % boundary is +180
           xmin=[axlim(1) -180];
           xmax=[180 axlim(2)-360];
           offset=[0 -360];
       elseif (i(1)==3)
           % boundary is -180
           xmin=[axlim(1)+360,-180];
           xmax=[180, axlim(2)];
           offset=[360 0];
       end
    case 0
        ngroups=0;
    otherwise
        disp('oops:  getDefaultBathymetry no axis limits line 79');
        ngroups=0;
end

D=[];
xp=[];
yp=[];
for ipart=1:ngroups    
%     indx1=find(x<=xmin(ipart),1,'last');
%     indx2=find(x>=xmax(ipart),1,'first');
%     indy1=find(y<=ymin,1,'last');
%     indy2=find(y>=ymin,1,'first');
%     indx=indx1:indx2;
%     indy=indy1:indy2;
    indx=find((x>=xmin(ipart))&(x<=xmax(ipart)));
    indx(1)=max([1,indx(1)-1]);
    indx(end)=min([length(x),indx(end)+1]);
    indx=indx(1):indx(end);
    indy=find((y>=ymin)&(y<=ymax));
    indy(1)=max([1,indy(1)-1]);
    indy(end)=min([length(y),indy(end)+1]);
    indy=indy(1):indy(end);
    indx0=indx(1:dx:end);
    indy0=indy(1:dx:end);
    if ~isempty(indx)
        start=[min(indx0), min(indy0)];
        count=[length(indx0),length(indy0)];
        stride=[dx, dx];
        xp=cat(1,xp,x(indx0)-offset(ipart));
        yp=y(indy0);       
        D=cat(1,D,ncread(f,varname,start,count,stride));
    end
end

% fix offsets
%dx=x0-min(xp);
xp=xp+gridadj;

% when merging -180 and +180 edges might be adjacent with diff(lon)==0 near
% these points (eliminate these points for seamless bathymetry)

ind=find(diff(xp)<=0);

xp(ind)=[];
D(ind,:)=[];

if nargout>1
 [X,Y]=ndgrid(xp,yp);
end

% ETOPO is - downwards
D=-D;


end

