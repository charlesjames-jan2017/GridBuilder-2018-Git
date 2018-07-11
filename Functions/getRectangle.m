function [x,y]=getRectangle()
% function [x,y]=getRectangle()
% Interactive User Function to define rectangle from2 points and return
% corners in counter-clockwise order
% Charles James 2017
x=[];
y=[];
a=gca;
startpoint=a.CurrentPoint;
rbbox;
endpoint=a.CurrentPoint;
startpoint=startpoint(1,1:2);
endpoint=endpoint(1,1:2);
if any(startpoint==endpoint)
    return
end

p1=startpoint;
offset=endpoint-startpoint;

x1=p1(1);
x2=p1(1)+offset(1);
y1=p1(2);
y2=p1(2)+offset(2);

x=[x1 x2 x2 x1];
y=[y1 y1 y2 y2];

[x,y]=setGridCornersCCW(x,y);

end
