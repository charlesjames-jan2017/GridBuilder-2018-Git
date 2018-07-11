function state=getButtonState(hObject)
% function state=getButtonState(hObject)
% determine current state of a gui button
% Charles James 2017
getVarcheck('hObject',[]);
if isempty(hObject)
    hObject=getGUIData('rbHandles');
end

Value=get(hObject,'Value');
if iscell(Value)
    state=cell2mat(Value)==1;
else
    state=Value==1;
end


end