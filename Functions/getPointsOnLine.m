function [inds,dist,xpi,ypi]=getPointsOnLine(xp,yp,xline,yline)
% function idist=getPointsOnLine(xp,yp,xseg,yseg)
% calculates the 1D coordinate of a point (xp,yp) on a line defined by
% xline,yline.  The line consists of segments so unique coordinate is
% distance along line.
% point is placed on nearest segment as determined by distance from point
% to centre point of segment
% Charles James 2017

% vector line formula  x=a+sn
% d=|a-p)-((a-p).n)n|

% moving along line segments
A=xline(:)+1i*yline(:);
dA=diff(A);
dR=abs(dA);
dL=[0;cumsum(dR)];

% unit vector in direction of line
N=dA./dR;
P=xp(:)+1i*yp(:);
[Am, Pm]=meshgrid(A(1:end-1),P);
Nm=meshgrid(N,P);
DR=meshgrid(dR,P);
AmP=Am-Pm;

% calculate length of projection (A-P) along line
PROJ=real(AmP).*real(Nm)+(imag(AmP).*imag(Nm));

% direction of A-P is from P intersection to A - dot with N and reverse
% to get sign and distance from A
DP=-PROJ.*Nm;
DPP=real(DP).*real(Nm)+imag(DP).*imag(Nm);

% normalize by length of segment
R=DPP./DR;

% distance to mid point of line
zm=0.5*(xline(1:end-1)+xline(2:end)+1i*(yline(1:end-1)+yline(2:end))); 

[~,inds]=min(abs(meshgrid(zm,P)-Pm),[],2);
idist=inds+diag(R(:,inds));
dist=dL(inds)+diag(DPP(:,inds));

dist=dist./max(dL);

% lowest index distance is 1
if any(idist<1)
    dist(idist<1)=0;
    idist(idist<1)=1;
end
% highest index distance is technically length(xline)
if any(idist>length(xline))
    dist(idist>length(xline))=1;
    idist(idist>length(xline))=length(xline);
end
if nargout>2
    [xpi,ypi]=getLineCoord(xline,yline,idist);
end
end
%%
function [xpi,ypi]=getLineCoord(xline,yline,idist)
% function [xpi,ypi]=getLineCoord(xline,yline,idist)
% get cartesian position of point on line from line coordinate
% Charles James 2017

    iseg=floor(idist);
    % if point is last point on xline dx=0,dy=0
    isegp1=min(length(xline),iseg+1);
   
    resid=idist-iseg;
    
    xs=xline(iseg);
    ys=yline(iseg);
    
    dx=xline(isegp1)-xs;
    dy=yline(isegp1)-ys;
    
    xpi=xs(:)+resid(:).*dx(:);
    ypi=ys(:)+resid(:).*dy(:);

end