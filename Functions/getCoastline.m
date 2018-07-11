function [lon,lat]=getCoastline(limits,haxis,res)
% function [lon, lat]=getCoastline([limits],[haxis],[res])
% adds a GSHHG polygon coastline to cartesian plot
% will use a subset of full GSHHG polygons created with makeGSHHGsubset but
% binary files and indices must be on the current path
% note:
% no transformation to mercator here - use setMapProjection for that
% Inspired by Rich Pawlowicz m_map toolbox
% Charles Jamess 2017


getVarcheck('haxis',gca);
getVarcheck('limits',[haxis.XLim,haxis.YLim]);
getVarcheck('res',[]);

% using complete GSHHG polygons version 2.2.4
fstr='gshhs_';

% check for poles
if limits(3)<-90
    limits(3)=-90;
end
if limits(4)>90
    limits(4)=90;
end

% check limits (we expect lat lon limits)
minx=limits(1);
maxx=limits(2);
miny=limits(3);
maxy=limits(4);

% pick a sensible res (need lat lon for correct areas)
if isempty(res)
    res=getGSHHGres([minx maxx miny maxy]);
end

switch res
    case 1
        res='c';
    case 2
        res='l';
    case 3
        res='i';
    case 4
        res='h';
    case 5
        res='f';
end

% use memmapfile - not noticeably faster than fopen but simpler to access
% file and no danger of leaving it open if routine fails
GSHHS=getGUIData('GSHHS');
if isempty(GSHHS)
    file=[fstr res '.b'];
    m=memmapfile(file);
    % index files created with getgshhsPolyIndex allow for rapid access to
    % start of polygon header information
    indfile=[fstr 'ind_' res '.mat'];
    ind=load(indfile);
    ind=ind.ind;
else
    ind=GSHHS.(res).ind;
    m.Data=GSHHS.(res).bin;
end

% byte offsets for GSHHG version 2.2
os_west=12;
os_east=16;
os_south=20;
os_north=24;
os_flag=8;
os_id=0;
os_container=36;

% get polygon limits and polygon level
W=double(get_GSHHGBinData(m,ind,os_west))/1e6;
E=double(get_GSHHGBinData(m,ind,os_east))/1e6;
S=double(get_GSHHGBinData(m,ind,os_south))/1e6;
N=double(get_GSHHGBinData(m,ind,os_north))/1e6;
polyid=double(get_GSHHGBinData(m,ind,os_id));
flag=typecast(get_GSHHGBinData(m,ind,os_flag),'uint8');
p_greenwich=logical(bitand(flag(3:4:end),uint8(1)));
containers=double(get_GSHHGBinData(m,ind,os_container));
gcontainers=polyid(p_greenwich);

% find polygons required for plot
usepoly=select_GSHHGPoly(minx,maxx,miny,maxy,W,E,S,N);

% subset to only required polygons
ind=ind(usepoly);
nseg=get_GSHHGBinData(m,ind,4);
p_greenwich=p_greenwich(usepoly);
polyid=polyid(usepoly);
containers=containers(usepoly);
[x,y]=get_GSHHGPoly(m,ind,nseg,p_greenwich,polyid,containers,gcontainers);
set(gcf,'CurrentAxes',haxis);
hold on
lon=[];
lat=[];
xv=[minx minx maxx maxx];
yv=[miny maxy maxy miny];
for ipoly=1:length(x)
    [xmap,ymap]=shape_GSHHGPoly(x{ipoly},y{ipoly},minx,maxx,miny,maxy,polyid(ipoly));
    for idopple=1:length(xmap)
        xplot=xmap{idopple};
        yplot=ymap{idopple};
        % polygon can be selected if its bounding box lies within plot
        % boundaries - but there may not actually be any points within plot
        % boundaries. Only plot if points lie within boundaries.
        if any(inpolygon(xplot,yplot,xv,yv))
            if ~isempty(xplot)
                lon=cat(1,lon,[xplot;nan]);
                lat=cat(1,lat,[yplot;nan]);
            end
        end
    end
end

end
%%
function data=get_GSHHGBinData(m,ind,offset)
% function data=get_GSHHGBinData(m,ind,offset)
% gets bigendian 4 bytes to int32 at offset from polygon index, vectorized
% for multiple ind
% Charles James 2017
[os, I]=meshgrid(ind,0:3);
Bind=I+os;
Bind=Bind(:);
data=swapbytes(typecast(m.Data(offset+Bind),'int32'));
end
%%
function [x,y]=get_GSHHGPoly(m,ind,nseg,p_greenwich,polyid,containers,gcontainers)
% function [x,y]=get_GSHHGPoly(m,ind,nseg,p_greenwich,polyid,containers,gcontainers)
% get segments from GSHHG version 2.2 (44 byte header)
% Charles James 2017
h_bytes=44;
x=cell(size(nseg));
y=x;
% could this loop be vectorized??
for i=1:length(nseg)
    segoffset=h_bytes+(1:nseg(i)*2*4)-1;
    data=swapbytes(typecast(m.Data(ind(i)+segoffset),'int32'));
    lon=double(data(1:2:end-1))*1e-6;
    lat=double(data(2:2:end))*1e-6;
    % special cases
    if p_greenwich(i)||ismember(containers(i),gcontainers)
        if (polyid(i)==4)
            % Special Antartica Case - box in polygon -only doing Merc. proj.
            % set coast line from -360 to 360
            lon2=[lon+360;lon;lon-360];
            lat2=[lat;lat;lat];
            ind2=(lon2>=-360)&(lon2<=360);
            lon2=lon2(ind2);
            lat2=lat2(ind2);
            lonbox=[-360;-360;360;360];
            latbox=[lat2(1);-90-eps;-90+eps;lat2(end)];
            x{i}=[lon2;lonbox];
            y{i}=[lat2;latbox];
        else
            % shift other greenwich crossers back to 0
            lon(lon>300)=lon(lon>300)-360;
            x{i}=lon;
            y{i}=lat;
        end
    else
        x{i}=lon;
        y{i}=lat;
    end
end

end
%%
function res=getGSHHGres(limits)
% function res=getGSHHGres(limits)
% picks an appropriate GSHHG resolution for area of map
% Charles James 2017
getVarcheck('limits',axis);
minx=limits(1);
maxx=limits(2);
% can't go to poles in mercator proj!
miny=max(-89,limits(3));
maxy=min(89,limits(4));

% distance accross diagonal of map plot
dist=getMapDistance(minx,miny,maxx,maxy);
if dist<250
    res='f';
elseif dist<1500
    res='h';
elseif dist<5000
    res='i';
elseif dist<15000
    res='l';
else
    res='c';
end
end
%%
function usepoly=select_GSHHGPoly(minx,maxx,miny,maxy,W,E,S,N)
% function usepoly=selectPolygons(minx,maxx,miny,maxy,W,E,S,N)
% selects polygon based on bounding box and axis limits
% 
% check for 360 offset to west and east so no polygons get left behind!
% Charles James
minxW=minx-360;
maxxW=maxx-360;
% and to the east
minxE=minx+360;
maxxE=maxx+360;

% use polygon if region lies entirely within polygon
usepoly=(W<=minx)&(E>=maxx)&(S<=miny)&(N>=maxy);
usepoly=usepoly|(W<=minxW)&(E>=maxxW)&(S<=miny)&(N>=maxy);
usepoly=usepoly|(W<=minxE)&(E>=maxxE)&(S<=miny)&(N>=maxy);

% check for polygons lying within longitude or latitude zone
inlat=((S>=miny)&(S<=maxy))|((N>=miny)&(N<=maxy))|((S<=miny)&(N>=maxy));
inlon=((W>=minx)&(W<=maxx))|((E>=minx)&(E<=maxx))|((W<=minx)&(E>=maxx));
inlon=inlon|((W>=minxW)&(W<=maxxW))|((E>=minxW)&(E<=maxxW))|((W<=minxW)&(E>=maxxW));
inlon=inlon|((W>=minxE)&(W<=maxxE))|((E>=minxE)&(E<=maxxE))|((W<=minxE)&(E>=maxxE));
usepoly=usepoly|(inlat&inlon);

end
%%
function [xmap,ymap]=shape_GSHHGPoly(xpoly,ypoly,minx,maxx,miny,maxy,polyid)
% function [xmap,ymap]=shape_GSHHGPoly(xpoly,ypoly,minx,maxx,miny,maxy)
% reshapes polygons to fit plot axis
% checks for repeat polygons at +/- 360 depending on plot domain.
% Charles James 2017

% other polygons defined on different grid
% check if echoes of polygon exist within minx and maxx
echo=true;
brep=1;
frep=1;
reps=1;
xmap=cell(0);
ymap=cell(0);
xmap{1}=xpoly;
ymap{1}=ypoly;
%rectx=[minx minx maxx maxx];
%recty=[miny maxy maxy miny];
if polyid==4
    isAA=true;
    % Antartica is special as it goes from 360 to -360
    dlon=720;
else
    isAA=false;
    dlon=360;
end

while echo
    xlow=xpoly-dlon*(brep);
    xhigh=xpoly+dlon*(frep);
    echo=false;
    if any((xlow>=minx)&(xlow<=maxx))
        brep=brep+1;
        reps=reps+1;
        xmap{reps}=xlow;
        ymap{reps}=ypoly;
        echo=true;
    end
    if any((xhigh>=minx)&(xhigh<=maxx))
        frep=frep+1;
        reps=reps+1;
        xmap{reps}=xhigh;
        ymap{reps}=ypoly;
        echo=true;
    end
end
%truncate at plot limits
for i=1:reps
    % only do if necessary
    if any(xmap{i}<minx|xmap{i}>maxx|ymap{i}<miny|ymap{i}>maxy)
        [xmap{i},ymap{i}]=getPolyTrim(xmap{i},ymap{i},minx, maxx, miny, maxy,isAA);
    end
end
end



%%
function [xout,yout,xin,yin]=getPolyTrim(xin,yin,minx,maxx,miny,maxy,isAA)
% function [xout,yout,xin,yin]=getPolyTrim(xin,yin,minx,maxx,miny,maxy,isAA)
% trim polygons to save memory and speed up plotting
% Charles James 2017

% add a little wiggle room to allow for artefacts along boundaries
dx=(maxx-minx)/20;
dy=(maxy-miny)/20;

xp=[minx-dx minx-dx maxx+dx maxx+dx];
yp=[miny-dy maxy+dy maxy+dy miny-dy];

xout=xin;
yout=yin;

% bounding points inside main polygon
% edgepoints=inpolygon(xp,yp,xin,yin);
outside=~inpolygon(xin,yin,xp,yp);

% reduce polygon points outside boundaries to ~900
ind=find(outside);
if (length(ind)>900)
    idec=true(size(ind));
    ikeep=round(linspace(1,length(ind),900));
    if isAA
        % need to keep special points at -90 so polygon fills properly!
        ikeep=unique([ikeep(:);find(yin(ind)<-89)]);
    end
    idec(ikeep)=false;
    inddel=ind(idec);
    
    
else
    inddel=[];
end

xout(inddel)=[];
yout(inddel)=[];

end
%%
function dist=getMapDistance(long1,lat1,long2,lat2)
% function dist=getMapDistance(lon1,lat1,[lon2,lat2]);
% gives distances in km on a map between 2 vectors of lat and lon
% or if only one pair of vectors is given the distance between points (like
% sw_dist used to) note order lon first lat second!
% Charles James 2017

if nargin==2
    long2=long1(2:end);
    lat2=lat1(2:end);
    long1=long1(1:end-1);
    lat1=lat1(1:end-1);
end

pi180=pi/180;
earth_radius=6378.137;


long1=long1(:)*pi180;
long2=long2(:)*pi180;
lat1= lat1(:)*pi180;
lat2= lat2(:)*pi180;

dlon = long2 - long1; 
dlat = lat2 - lat1; 
a = (sin(dlat/2)).^2 + cos(lat1) .* cos(lat2) .* (sin(dlon/2)).^2;
angles = 2 * atan2( sqrt(a), sqrt(1-a) );
dist = earth_radius * angles;
end