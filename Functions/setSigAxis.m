function setSigAxis(handles)
% function setSigAxis(handles)
% set axis for sigma level plots
% Charles James 2017
Sigcoef=getGUIData('Sigcoef');
Tcline=Sigcoef.Tcline;
hmax=4*Tcline;

h=[hmax,Tcline];

Zr=squeeze(getROMSsigma(h,'rho'));

ytick1=sort(-Zr(1,:));
ytick2=sort(-Zr(2,:));

ylim(handles.axSigmaDeep,[0 hmax]);
handles.axSigmaDeep.YTick=ytick1;
handles.axSigmaDeep.YTickLabel=[];
handles.axSigmaDeep.XTick=[];
xlabel(handles.axSigmaDeep,'h>Tcline');

ylim(handles.axSigmaShallow,[0 Tcline]);
handles.axSigmaShallow.YTick=ytick2;
handles.axSigmaShallow.YTickLabel=[];
handles.axSigmaShallow.XTick=[];
xlabel(handles.axSigmaShallow,'h<Tcline');



end