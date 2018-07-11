function [x,y]=getMapCoord(xin,yin,method,x0,y0)
% function [x,y]=getMapCoord(xin,yin,method,x0,y0)
% conversion between lat,lon and distances
% Charles James 2017
getVarcheck('x0',0);
getVarcheck('y0',0);

deg2rad=pi/180;
radius  = 6371315;
switch method
    case 'll2xy'
        xref=x0*deg2rad.*cosd(y0)*radius;
        x=(xin-x0)*deg2rad.*cosd(yin)*radius;
        y=yin*deg2rad*radius;        
    case 'xy2ll'
        y0=y0./(deg2rad*radius);
        y=yin/(deg2rad*radius);
        x=(xin-x0)./(deg2rad*cosd(y)*radius);
        xref=x0./(deg2rad*cosd(y0)*radius);
end

    x=x+xref;

end