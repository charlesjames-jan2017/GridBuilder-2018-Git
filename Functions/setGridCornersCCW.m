function [x,y,ind]=setGridCornersCCW(x,y)
% function [x,y,ind]=setGridCornersCCW(x,y)
% use convex hull of delauney triagulation to ensure corner points are
% a) a convex hull (box)
% b) sequenced in a counter-clockwise direction
% Charles James 2017
ind=convhull(x(:),y(:));
% last point of convex Hull is same as first point
if (ind(end)==ind(1))
    ind(end)=[];
end
% There must still be 4 corners, weirdness can happen when grid corners
% are first selected in free form definition - but gridbuilder will try and
% indicate error - can't usually get here once grid has been built.
if length(ind)<4
    % which index(es) got dropped
    missing=find(~ismember([1 2 3 4],ind));
    % this rarely happens and if it does the grid will usually show as bad
    % and need to be modified
    ind(end+1:4)=missing;
end

x=x(ind);
y=y(ind);

end