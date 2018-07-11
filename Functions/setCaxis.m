function [Caxis,haxis]=setCaxis(handles,setting)
getVarcheck('setting','none');
% what is displayed
if (handles.rbOrthog.Value==1)
    haxis=handles.ColAxis;
    axname='orthog_caxis';
elseif (handles.rbRx0.Value==1)
    haxis=handles.ColAxis;
    axname='rx0_caxis';
elseif (handles.rbRx1.Value==1)
    haxis=handles.ColAxis;
    axname='rx1_caxis';
elseif (handles.rbDepths.Value==1)||(handles.rbBath.Value==1)
    haxis=handles.BWAxis;
    axname='bath_caxis';
end
switch setting
    case 'auto'
        caxis(haxis,setting);
end
    Caxis=caxis(haxis);
if nargout==0
    setGUIData(axname,Caxis);
end
end
