function setGridToggle(status,options)
%function setGridToggle(status,options)
% function to toggle elements of grid on and off
%
% status='on' or 'off' for visibility of elements
% default options = {'Grid','Corners','Side','Control','Spacer'}
% other options are 'Mask' and 'Depths'
% status can be either a single string: 'on' (default), 'off', 'stay', or
% 'switch'
% or a cell array equal to the length of options (if options is not
% specified the cell array is equal to the number of default options above
% when a cell array is specified then specific grid elements can be made visible and
% not visible
%    i.e. setGridToggle({'on','on','off'},{'Grid','Corners','Side'})
%    turns grid and corner visibility on and Side visibility off
% Charles James 2017

if isstruct(status)
    options=fieldnames(status);
    status=struct2cell(status);
end

getVarcheck('options',{'Grid','Corners','Side','Control','Spacer','Depths','Mask','Orthogonality','rx0','rx1'});
getVarcheck('status','on');

if iscell(status)
    if length(status)~=length(options)
        error('Status and Options lengths must match');
    else
        cstatus=status;
    end
elseif ischar(status)&&ismember(status,{'on','off'})
    cstatus=cell(size(options));
    cstatus(:)={status};
else
    error('Unrecognized Status')
end
Visible=getGUIData('Visible');
handles=getGUIData('handles');
side=getGUIData('side');
for i=1:length(options)
    status=cstatus{i};
    
    switch lower(options{i}(1:3))
        case 'gri'
            set(getGUIData('hgrid'),'visible',status);
            Visible.grid=status;
        case 'cor'
            set(getGUIData('hcorner'),'visible',status);
            Visible.corner=status;
        case 'sid'
            set(getGUIData('hside'),'visible',status);
            Visible.side=status;
        case 'con'
            con=[side.control];
            if any(ishandle([con.handle]))
                set([con.handle],'visible',status);
                %cellfun(@(x) set(x,'visible',status),{con.handle});
            end
            Visible.control=status;
        case 'spa'
            spa=[side.spacing];
            cellfun(@(x) set(x,'visible',status),{spa.handle});
            Visible.spacer=status;
        case 'mas'
            hmask=getGUIData('hmask');
            if ishandle(hmask(1))
                set(hmask,'Visible',status);
            end
            Visible.mask=status;
            if strcmp(status,'off')
                handles.rbMask.Value=0;
            else
                handles.rbMask.Value=1;
            end
        case 'dep'
            hdepths=getGUIData('hdepths');
            if ishandle(hdepths(1))
                set(hdepths,'Visible',status);
            end
            Visible.depths=status;
            if strcmp(status,'off')
                handles.rbDepths.Value=0;
            else
                handles.rbDepths.Value=1;
            end
        case 'ort'
            horthog=getGUIData('horthog');
            if ishandle(horthog)
                set(horthog,'Visible',status);
            end
            Visible.orthogonality=status;
            if strcmp(status,'off')
                handles.rbOrthog.Value=0;
            else
                handles.rbOrthog.Value=1;
            end
        case 'rx0'
            hrx0=getGUIData('hrx0');
            if ishandle(hrx0)
                set(hrx0,'Visible',status);
                set(hrx0,'HitTest','off');
            end
            Visible.rx0=status;
            if strcmp(status,'off')
                handles.rbRx0.Value=0;
            else
                handles.rbRx0.Value=1;
            end
        case 'rx1'
            hrx1=getGUIData('hrx1');
            if ishandle(hrx1)
                set(hrx0,'Visible',status);
                set(hrx0,'HitTest','off');
            end
            Visible.rx1=status;
            if strcmp(status,'off')
                handles.rbRx1.Value=0;
            else
                handles.rbRx1.Value=1;
            end
    end
end

setGUIData(Visible);


end