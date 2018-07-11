function [X,Y,Z]=getXYZ2grid(x,y,z)
% function [X,Y,Z]=getXYZ2grid(x,y,z)
% check if x,y,z are points we can map to a rectangular grid
% Charles James 2017
X=[];
Y=[];
Z=[];


[x0,~,i2]=unique(x);
[y0,~,j2]=unique(y);

M=length(x0);
N=length(y0);

% grid may be partially filled so M*N > length(z)
% but will expect more than 25% of grid to have values
if (M*N)>(4*length(z))
    return
end


ind=sub2ind([M,N],i2,j2);

if length(unique(ind))==length(z)
    Z=nan(M,N);
    Z(ind)=z;
    [X,Y]=ndgrid(x0,y0);
end

end
