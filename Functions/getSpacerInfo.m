function s=getSpacerInfo(side,k)
% function s=getSpacerInfo(side,k)
% determines spacer information for grid editing
% Charles James 2017
N=length(side(k).x);
active=side(k).spacing.active;
if active
    spind=side(k).spacing.spindex;
else
    oside=getOppositeSide(k);
    spind=side(oside).spacing.spindex;  
end
    
sx = linspace(0, 1, length(spind));
sxi=linspace(0,1,N);
s=interp1(sx,spind,sxi,'pchip');
if ~active
    s=1-s;
end


end
%%
function oside=getOppositeSide(iside)
opposite=circshift((1:4),2,2);
oside=opposite(iside);
end