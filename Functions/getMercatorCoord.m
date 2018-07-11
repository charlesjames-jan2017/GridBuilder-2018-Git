function [x,y]=getMercatorCoord(x,y,cstr)
% function [x,y]=getMercatorCoord(x,y,cstr)
% a simple transformation to and from Mercator
% Charles James 2018

projection=getGUIData('projection');
% if projection is Cartesian we don't do this
if strcmpi(projection,'Cartesian')
    return
end

switch cstr
    case 'C2M'
        % Cart. to Merc.
        x=x*pi/180;
        y=atanh(sind(y));
    case 'M2C'
        % Merc. to Cart.
        x=x*180/pi;
        y=asind(tanh(y));
    otherwise
        % do nothing!  this will return x,y unchanged
end

end
