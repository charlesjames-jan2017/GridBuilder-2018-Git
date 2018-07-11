function trace=setTraceOutline(dx,dy)
%function trace=setTraceOutline(dx,dy)
% draws a trace of the grid outline that can be moved through user
% interaction
% Charles James 2017
getVarcheck('dx',0);
getVarcheck('dy',0);
handles=getGUIData('handles');
side=getGUIData('side');
x=[side.x];
y=[side.y];
x(end+1)=x(1);
y(end+1)=y(1);
trace=plot(handles.MainAxis,x+dx,y+dy,'b--');
drawnow
end