function imaskSelect=getMaskContig(mask)
% function imaskSelect=getMaskContig(mask)
% Charles James 2017
currentpoint=getGUIData('CurrentDownPoint');
grid=getGUIData('grid');
x=currentpoint(1,1);y=currentpoint(1,2);
[X,Y]=getBpsi2rho(grid.x,grid.y);
switch grid.coord
    case 'spherical'
        D=getMapDistArray(X,Y,x,y);
    case 'cartesian'
        D=sqrt((X-x).^2+(Y-y).^2);
end
[~,ind]=min(D(:));
[i,j]=ind2sub(size(X),ind);
imaskSelect=getGridContigCells(mask,i,j);
end

%%
function Mcont=getGridContigCells(M,i,j)
% function ind=getGridContigCells(M,i,j)
% given a Matrix (M) and the location of an entry in the Matrix (i,j)
% find all contiguous points in M with the same value as that entry
% Charles James 2017
foundall=false;

val=M(i,j);
Mpos=M==val;
Madjacent=getGridAdjacent(M,i,j)&Mpos;
Mcont=false(size(M));
Mcont(i,j)=true;
Mcont=Mcont|Madjacent;

while ~foundall
    % ignore already found points
    Mold=Mcont;
    [i,j]=find(Madjacent);
    Madjacent=getGridAdjacent(M,i,j)&Mpos&~Mcont;
    Mcont=Mcont|Madjacent;
    foundall=all(Mcont(:)==Mold(:));
end


end
%%
function mask=getGridAdjacent(M,i,j)
% function ind=getGridAdjacent(M,i,j)
% given a Matrix (M) and the location of an entry in the Matrix (i,j)
% find index of all Adjacent points in M
% Charles James 2017
[n,m]=size(M);
mask=false(n,m);
% max of 4 adjacent cells
I=[i(:) i(:)-1 i(:)+1 i(:) i(:)];
J=[j(:) j(:) j(:) j(:)-1 j(:)+1];

I(I<1)=1;
I(I>n)=n;
J(J<1)=1;
J(J>m)=m;

mask((J-1)*n+I)=true;
end
%%
function D=getMapDistArray(LON,LAT,lon,lat)
% function D=getMapDistArray(LON,LAT,lon,lat)
% returns Array of distances from LON,LAT to lon,lat
% LON and LAT assumed to be matricies, lon, lat
% vectors or scalars
% Charles James 2017

% make all inputs same size

if ~isvector(lon)
    error('Input lon and lat in vector form');
end

s=size(LON);

if isscalar(LON)
    dimin=1;
else
    dimin=ones(1,length(s));
end

n=length(lon);


LONin=repmat(LON,[dimin,n]);
LATin=repmat(LAT,[dimin,n]);

if isscalar(LONin)
    lonin=lon;
    latin=lat;
else
    lonin=repmat(lon,[1 s]);
    latin=repmat(lat,[1 s]);
    pvec=1:ndims(lonin);
    pvec=[pvec(2:end),pvec(1)];
    lonin=permute(lonin,pvec);
    latin=permute(latin,pvec);
end

pi180=pi/180;
earth_radius=6378.137;

LONin=LONin*pi180;
LATin=LATin*pi180;
lonin=lonin*pi180;
latin=latin*pi180;

dlon = (lonin - LONin); 
dlat = latin - LATin; 
a = (sin(dlat/2)).^2 + cos(LATin) .* cos(latin) .* (sin(dlon/2)).^2;
angles = 2 * atan2( sqrt(a), sqrt(1-a) );
D = earth_radius * angles;

end