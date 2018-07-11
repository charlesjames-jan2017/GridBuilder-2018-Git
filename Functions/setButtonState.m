function setButtonState(state,hObject)
% function setButtonState(state,hObject)
% set the state of a GUI button
% Charles James 2017
getVarcheck('hObject',[]);
if isempty(hObject)
    hObject=getGUIData('rbHandles');
end
if length(state)~=length(hObject)
    return
end
for ih=1:length(hObject)
    hObject(ih).Value=double(state(ih));
end
end