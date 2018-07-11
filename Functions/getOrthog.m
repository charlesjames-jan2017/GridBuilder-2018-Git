function orthogonality=getOrthog(x,y)
% function orthogonality=getOrthog(x,y)
% Charles James 2017
% derived from seagrid doorthogonality
%=======================================================================
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
%=======================================================================

if strcmpi(getGUIData('projection'),'spherical')
    % use mercator rather than default getMapCoord as it is conformal and
    % preserves angles
    x=x*pi/180;
    y=atanh(sind(y));
end

z = x + 1i*y;

dzx = nan([size(z),4]);
dzy=dzx;


% Store the maximum deviation from a right-angle

%  for each grid-crossing.
for i = 1:4
    dzx(1:end-1,1:end-1,i) = diff(z(:,1:end-1),[],1);
    dzy(1:end-1,1:end-1,i) = diff(z(1:end-1,:),[],2);
    z=rot90(z);
    dzx=rot90(dzx);
    dzy=rot90(dzy);
end

dn=abs(dzx.*dzy);
r_ang = acos((real(dzx).*real(dzy) + imag(dzx).*imag(dzy))./dn);
orthogonality = 180 * abs(max(r_ang,[],3) - pi/2) / pi;   % Error from 90 degrees.


end