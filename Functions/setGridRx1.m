function rx1=setGridRx1()
% function rx1=setGridRx1()
% Calculate the grid stiffness parameter rx1
% Charles James 2017
depths=getGUIData('depths');
mask=getGUIData('mask');
if isempty(getGUIData('depths'))
    depths=setGridDepths();
end
if isempty(getGUIData('mask'))
    mask=setGridMask();
end
zw=getROMSsigma(depths,'w');
% calculate gradient here
rx1=getRx1(zw,mask);
setGUIData(rx1);
end
%%
function Rx1=getRx1(zw,rmask)
% my vectorized version of  
% GRID_ComputeMatrixRx1_V2 from the LP_Bathymetry toolbox
[Lp,Mp,Np]=size(zw);
Neighbors=zeros([Lp,Mp,Np,4]);
L=Lp-1;
M=Mp-1;
N=Np-1;
Zw=repmat(zw,[1 1 1 4]);
Mask=repmat(rmask,[1 1 N,4]);
Nmask=zeros(size(Mask));

Neighbors(1:L,:,:,1)=zw(2:Lp,:,:);
Neighbors(:,1:M,:,2)=zw(:,2:Mp,:);
Neighbors(2:Lp,:,:,3)=zw(1:L,:,:);
Neighbors(:,2:Mp,:,4)=zw(:,1:M,:);

Nmask(1:L,:,:,1)=Mask(2:Lp,:,:,1);
Nmask(:,1:M,:,2)=Mask(:,2:Mp,:,2);
Nmask(2:Lp,:,:,3)=Mask(1:L,:,:,3);
Nmask(:,2:Mp,:,4)=Mask(:,1:M,:,4);

IND=(Nmask==0)|(Mask==0);

a1=abs((Zw(:,:,2:end,:)-Neighbors(:,:,2:end,:))+(Zw(:,:,1:end-1,:)-Neighbors(:,:,1:end-1,:)));
b1=abs((Zw(:,:,2:end,:)+Neighbors(:,:,2:end,:))-(Zw(:,:,1:end-1,:)+Neighbors(:,:,1:end-1,:)));

quot=a1./b1;
quot(IND)=nan;

Rx1=max(max(quot,[],4),[],3);
Rx1(isnan(Rx1))=0;

end