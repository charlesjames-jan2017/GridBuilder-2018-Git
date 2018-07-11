function rx0=setGridRx0()
% function rx0=setGridRx0()
% Calculate the grid stiffness parameter rx0
% Charles James 2017

depths=getGUIData('depths');
mask=getGUIData('mask');
if isempty(getGUIData('depths'))
    depths=setGridDepths();
end
if isempty(getGUIData('mask'))
    mask=setGridMask();
end
% calculate gradient here
rx0=getRx0(depths,mask);
setGUIData(rx0);
end
%%
function rx0=getRx0(h,rmask)
% Based on ROMS algorithm:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    h           bathymetry at RHO-points.                                  %
%    rmask       Land/Sea masking at RHO-points.                            %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    r           R-factor.                                                  %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modified from rfactor CJ Oct 2015
[Lp,Mp]=size(h);
L=Lp-1;
M=Mp-1;

% negative depths have no meaning for this metric so this keeps values of >>1
% from appearing in the plots.
h=abs(h);

if (nargin < 2)||isempty(rmask)
  rmask=ones(size(h));
end

%  Land/Sea mask on U-points.
umask=rmask(1:L,:).*rmask(2:Lp,:);

%  Land/Sea mask on V-points.
vmask=rmask(:,1:M).*rmask(:,2:Mp);
%----------------------------------------------------------------------------
%  Compute R-factor.
%----------------------------------------------------------------------------

hx(1:L,1:Mp)=abs(h(2:Lp,1:Mp)-h(1:L,1:Mp))./(h(2:Lp,1:Mp)+h(1:L,1:Mp));
hy(1:Lp,1:M)=abs(h(1:Lp,2:Mp)-h(1:Lp,1:M))./(h(1:Lp,2:Mp)+h(1:Lp,1:M));

hx=umask.*hx;
hy=vmask.*hy;

rx0=max(max(hx(1:L,1:M),hx(1:L,2:Mp)), ...
               max(hy(1:L,1:M),hy(2:Lp,1:M)));

end
