function setGridUpdate(varargin)
% function setGridUpdate(varargin)
% will refresh by replotting the current visual elements of grid after grid
% has been updated.
% Charles James 2017

% for multiple arguments set following order
ivars={'bathymetry','depths','grid','mask','coast'};
[~,i1]=ismember(lower(varargin),ivars);
[~,i2]=sort(i1);
varargin=varargin(i2);

handles=getGUIData('handles');
setWatch('on');  
set(0,'CurrentFigure',handles.MainFigure);
for iarg=1:nargin
    section=varargin{iarg};
    switch lower(section)
        case 'coast'
            coast=getGUIData('coast');
            hcoast=getGUIData('hcoast');
            set(hcoast,'XData',coast.lon,'YData',coast.lat);
            axlims=getGUIData('limits');
            axis(handles.MainAxis,axlims);
            
            if strcmpi(getGUIData('projection'),'Spherical')
                ym=mean(axlims(3:4));
                aspectrat=[1 cosd(ym) 1];
            else
                aspectrat=[1 1 1];
            end
            
            handles.MainAxis.DataAspectRatio=aspectrat;
            handles.ColAxis.DataAspectRatio=aspectrat;
            handles.BWAxis.DataAspectRatio=aspectrat;
            user_coast=getGUIData('user_coast');
            if getGUIData('usercoast')
                user_hcoast=getGUIData('user_hcoast');
                if ishandle(user_hcoast)
                    set(user_hcoast,'XData',user_coast.lon,'YData',user_coast.lat);
                end
            end
        case 'bathymetry'    
            hbath=getGUIData('hbath');
            bathymetry=getGUIData('bathymetry');
            set(hbath,'XData',bathymetry.xbathy,'YData',bathymetry.ybathy,'ZData',zeros(size(bathymetry.zbathy)),'CData',bathymetry.zbathy);
            if getGUIData('userbath')
                % create a nice looking schematic representing the user
                % loaded data
                user_BathyInterpolant=getGUIData('user_BathyInterpolant');
                switch class(user_BathyInterpolant)
                    case 'scatteredInterpolant'
                        x=user_BathyInterpolant.Points(:,1);
                        y=user_BathyInterpolant.Points(:,2);
                        x1=min(x);x2=max(x);
                        y1=min(y);y2=max(y);
                        k=convhull(x,y);
                        xb=x(k);
                        yb=y(k);
                    case 'griddedInterpolant'
                        x1=min(user_BathyInterpolant.GridVectors{1});
                        x2=max(user_BathyInterpolant.GridVectors{1});
                        y1=min(user_BathyInterpolant.GridVectors{2});
                        y2=max(user_BathyInterpolant.GridVectors{2});
                        xb=[x1 x1 x2 x2 x1];
                        yb=[y1 y2 y2 y1 y1];
                end
                [XB,YB]=ndgrid(linspace(x1,x2,400),linspace(y1,y2,400));
                tic
                ZB=user_BathyInterpolant(XB,YB);
                toc
                tic
                ind=fastinpoly(XB,YB,xb,yb);
                toc
                ZB(~ind)=nan;
                user_hbath=getGUIData('user_hbath');
                user_hbath_bound=getGUIData('user_hbath_bound');
                set(user_hbath,'XData',XB,'YData',YB,'ZData',zeros(size(ZB)),'CData',ZB);
                set(user_hbath_bound,'XData',xb,'YData',yb);
            end
            if strcmp(hbath.Visible,'on')
                caxis(handles.MainAxis,getGUIData('bath_caxis'));
            end
        case 'grid'    
            grid=getGUIData('grid');
            hgrid=getGUIData('hgrid');
            
            griderror=getGridError(getGUIData('grid'));
            if griderror==-1
                set(hgrid,'Color','m');
            else
                set(hgrid,'Color','g');
            end
            
            
            hside=getGUIData('hside');
            corner=getGUIData('corner');
            hcorner=getGUIData('hcorner');
            side=getGUIData('side');
            Visible=getGUIData('Visible');
            
            % update resolution
            set(handles.Nedit,'String',int2str(grid.n-1));
            set(handles.Medit,'String',int2str(grid.m-1));
            
            % orthogonality mesh is under grid
            orthogonality=grid.orthogonality;
%           Possibly not count dry cells in orthogonality measurement?
            if handles.rbMask.Value==1
                omask=getGUIData('omask');
                orthogonality(omask==0)=nan;
            end
            horthog=getGUIData('horthog');
            [XI,YI]=getRho2Bpsi(grid.x,grid.y);
            horthog=setPropertyPlot(XI,YI,100*orthogonality/90,horthog);
            set(horthog,'EdgeColor','none','hittest','off','tag','orthog');
            setGUIData(horthog);
            maxOrth=max(orthogonality(:));
            handles.txtOrth.String=num2str(maxOrth,'%2.2f');
            if maxOrth>10
                handles.txtOrth.ForegroundColor='r';
            else
                handles.txtOrth.ForegroundColor='w';
            end
            
            
            %plot grid
            Xg=grid.x;
            L=size(Xg,2);
            M=size(Xg,1);
            Yg=grid.y; 
            Xgp=Xg';
            Ygp=Yg';
            Xg(M+1,:)=nan;
            Yg(M+1,:)=nan;           
            Xgp(L+1,:)=nan;
            Ygp(L+1,:)=nan;
            xg=[Xg(:);NaN;Xgp(:)];
            yg=[Yg(:);NaN;Ygp(:)];
            set(hgrid,'XData',xg,'YData',yg);
            set(hgrid,'tag','grid','Visible',Visible.grid,'hittest','off');
            cornermarker={'d','o','o','o'};
            cornercolor={'b','r','r','r'};
            edgecolor={'r','b','b','b'};
            for iside=1:4
                X=side(iside).x;
                Y=side(iside).y;
                set(hside(iside),'XData',X,'YData',Y);
                set(hside(iside),'UserData',iside,'Visible',Visible.side);
                set(hside(iside),'ButtonDownFcn','setGridModify(''Sides'')','tag','side');
                
                
                if ishandle(side(iside).control.handle)
                    delete(side(iside).control.handle);
                end
                for icontrol=1:length(side(iside).control.x)
                    X=side(iside).control.x(icontrol);
                    Y=side(iside).control.y(icontrol);
                    side(iside).control.handle(icontrol)=...
                        plot(X,Y,'bo',...
                        'ButtonDownFcn','setGridModify(''Control'')',...
                        'Visible',Visible.control,'UserData',iside,'tag','control');
                end

                if side(iside).spacing.active
                    
                    xline=side(iside).x;
                    yline=side(iside).y;
                    % spacers are distributed along side but only a subset of 5
                    % by default

                    if ishandle(side(iside).spacing.handle)
                        delete(side(iside).spacing.handle);
                    end
                    % create spacers
                    sp=side(iside).spacing.spindex;
                    s=getSpacerInfo(side,iside);
                    xp=interp1(s,xline,sp);
                    yp=interp1(s,yline,sp);
                    xp=xp(2:end-1);
                    yp=yp(2:end-1);
                    for i=1:length(xp)
                        side(iside).spacing.handle(i)=...
                            handle(plot(xp(i),yp(i),'bs',...
                            'ButtonDownFcn','setGridModify(''Spacers'')',...
                            'UserData',iside,'Visible',Visible.spacer,'tag','spacer'));
                    end
                end
            end
            % corners need to be plotted on top
            for icorner=1:4                
                if (handles.rbTranslate.Value==1)
                    facecolor='b';
                else
                    facecolor=cornercolor{icorner};
                end
                set(hcorner(icorner),'XData',corner(icorner).x,'YData',corner(icorner).y,'markerfacecolor',facecolor,...
                    'Marker',cornermarker{icorner},'Color',edgecolor{icorner},'Visible',Visible.corner);
            end
            set(hcorner,'ButtonDownFcn','setGridModify(''Corner'')','markersize',8)
            % update control points
            setGUIData(side);
            setGUIData(corner);
            setGUIData(grid);
        case 'mask'
            grid=getGUIData('grid');
            hmask=getGUIData('hmask');
            hmaskSelect=getGUIData('hmaskSelect');
            dispmask=getGUIData('mask');
            imaskSelect=getGUIData('imaskSelect');
            
            dispmask(dispmask==1)=inf;
            dispmask(dispmask==0)=-inf;
            if ishandle(hmaskSelect)
                delete(hmaskSelect)
            end
            hmask=setPropertyPlot(grid.x,grid.y,dispmask,hmask);
            if any(imaskSelect(:))
                [xm,ym]=getBpsi2rho(grid.x,grid.y);
                hmaskSelect=plot(xm(imaskSelect),ym(imaskSelect),'r*','HitTest','off','PickableParts','None');
                setGUIData(hmaskSelect);
            end
            set(hmask,'ButtonDownFcn','setGridModify(''Mask'')','EdgeColor','none','tag','mask');
            setGUIData(hmask);
            if ishandle(hmask)
                set(handles.rbModMask,'enable','on');
            end
        case 'depths'
            % includes rx0 update as both are related
            setGridRx0();
            if getGUIData('SigmaCoord')
                setGridRx1();
            end
            grid=getGUIData('grid');
            hdepths=getGUIData('hdepths');
            hrx0=getGUIData('hrx0');
            rx0=getGUIData('rx0');
            hrx1=getGUIData('hrx1');
            rx1=getGUIData('rx1');
            depths=getGUIData('depths');
            hdepths=setPropertyPlot(grid.x,grid.y,depths,hdepths);
            % I know we are going from rho to interior psi but routine from
            % boundary psi to rho does the same thing and reduces each
            % dimension by 1
            [xpsi,ypsi]=getBpsi2rho(grid.x,grid.y);
            hrx0=setPropertyPlot(xpsi,ypsi,rx0,hrx0);            
            set(hrx0,'EdgeColor','none','HitTest','off');
            setGUIData(hrx0);
            if getGUIData('SigmaCoord')
            hrx1=setPropertyPlot(grid.x,grid.y,rx1,hrx1);
            set(hrx1,'EdgeColor','none','HitTest','off');
            setGUIData(hrx1);               
            end
            set(hdepths,'ButtonDownFcn','setGridModify(''Depths'')','EdgeColor','none');
            setGUIData(hdepths);
            if ishandle(hdepths)
                set(handles.rbModBath,'enable','on');
            end
            set(hrx0,'EdgeColor','none','HitTest','off');
            setGUIData(hrx0);
    end

end
setWatch('off');
end
%%
function Mask=fastinpoly(X,Y,bx,by)
% selects ROI within M based on boundary defined by bx and by
bx=bx(:);
by=by(:);

%Mask=false(size(X));

N=length(bx);
i2=1:N;
i1=[N,1:N-1];

m=(by(i2)-by(i1))./(bx(i2)-bx(i1));
b=by-m.*bx;
x0=[bx(i1),bx(i2)];
xmin=min(x0,[],2);
xmax=max(x0,[],2);

N=numel(X);
s=length(m);

B=repmat(X(:),[1 s])';
IND=reshape(sum((repmat(Y(:),[1 s])'<=(m*X(:)'+repmat(b,[1 N])))&(B>=repmat(xmin,[1 N]))&(B<=repmat(xmax,[1 N]))),size(X));

Mask=IND~=2*fix(IND/2);

end