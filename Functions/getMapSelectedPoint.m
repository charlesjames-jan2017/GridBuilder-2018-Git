function CurrentPoint=getMapSelectedPoint(buttonstate)
% function CurrentPoint=getMapSelectedPoint(buttonstate)
% uses figure window callbacks to determine point location on button down
% or button up
% Charles James 2017
ButtonDown=getGUIData('ButtonDown');
switch lower(buttonstate)
    case 'down' 
        while ~ButtonDown
            drawnow
            ButtonDown=getGUIData('ButtonDown');
        end
        CurrentPoint=getGUIData('CurrentDownPoint');
    case 'up'
        while ButtonDown
            drawnow
            ButtonDown=getGUIData('ButtonDown');
        end
        CurrentPoint=getGUIData('CurrentUpPoint');
end
end