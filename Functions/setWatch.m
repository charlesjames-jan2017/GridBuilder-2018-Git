function setWatch(state)
% function setWatch(state)
% manages the cursor state to turn on and off the waiting animation 
% Charles James 2017
handles=getGUIData('handles');

switch state
    case 'on'
        if getGUIData('watchState')
            return
        else
            setGUIData('watchState',true);
        end
        setGUIData('CurrentPointer',handles.MainFigure.Pointer);
        handles.MainFigure.Pointer='watch';
    case 'off'
        if ~getGUIData('watchState')
            return
        else
            setGUIData('watchState',false);
        end
        handles.MainFigure.Pointer=getGUIData('CurrentPointer');      
end
drawnow;
end