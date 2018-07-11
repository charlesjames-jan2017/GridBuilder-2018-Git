function depths=setGridFilter(depths,mask,handles)
% handles filter callback for all fiter types
order=2.^handles.puFiltOrder.Value;
rx0Max=getGUIData('rx0Max');
ind=depths>=getGUIData('shapiroDepth');
switch handles.puFilterType.String{handles.puFilterType.Value}
    case 'Positive Adjustment'
        depths=filter_adjust_positive(depths,mask,rx0Max);
    case 'Negative Adjustment'
        depths=filter_adjust_negative(depths,mask,rx0Max);    
%        depths=oldneg(depths,mask,rx0Max);
    case 'Shapiro (B.C. constant)'
        depthsf=filter_shapiro(depths,order,1);
        depths(ind)=depthsf(ind);
    case 'Shapiro (B.C. smooth)'
        depthsf=filter_shapiro(depths,order,2);
        depths(ind)=depthsf(ind);
end

end
%%
function depthsf=filter_adjust_negative(depths,mask,rx0Max)
% This program optimizes the bathymetry for the rx0 factor by decreasing it.
% based on 
% GRID_SmoothNegative_rx0(MSK, Hobs, rx0max)
% from LP_Bathymetry Toolbox. M. Sikiric
%
% ---mask is the mask of the grid
%      1 for sea
%      0 for land
% ---depths is the raw depth of the grid
% ---rx0Max is the target rx0 roughness facto

tol=0.000001;

[Lp,Mp]=size(depths);
L=Lp-1;
M=Mp-1;

sfact=(1+rx0Max)./(1-rx0Max);

depthsf=depths;
Neighbors=zeros([Lp,Mp,4]);
Nmask=Neighbors;

Nmask(1:L,:,1)=mask(2:Lp,:);
Nmask(:,1:M,2)=mask(:,2:Mp);
Nmask(2:Lp,:,3)=mask(1:L,:);
Nmask(:,2:Mp,4)=mask(:,1:M);

finished=false;

while(~finished)
    finished=true;
    Neighbors(1:L,:,1)=depthsf(2:Lp,:);
    Neighbors(:,1:M,2)=depthsf(:,2:Mp);
    Neighbors(2:Lp,:,3)=depthsf(1:L,:);
    Neighbors(:,2:Mp,4)=depthsf(:,1:M);
    Neighbors=Neighbors.*sfact;
    
    for i=1:4
        N=Neighbors(:,:,i);
        nmask=Nmask(:,:,i);
        dh=depthsf-N;
        ind=(dh>tol)&(mask==1)&(nmask==1);
        if any(ind(:))
            finished=false;
            depthsf(ind)=N(ind);
        end
    end
end


end
%%
function depthsf=filter_adjust_positive(depths,mask,rx0Max)
% This program optimizes the bathymetry for the rx0 factor by increasing it.
% based on 
% GRID_SmoothPositive_rx0(MSK, Hobs, rx0max)
% from LP_Bathymetry Toolbox. M. Sikiric
%
% ---mask is the mask of the grid
%      1 for sea
%      0 for land
% ---depths is the raw depth of the grid
% ---rx0Max is the target rx0 roughness facto

tol=0.000001;

[Lp,Mp]=size(depths);
L=Lp-1;
M=Mp-1;

sfact=(1-rx0Max)./(1+rx0Max);

depthsf=depths;
Neighbors=zeros([Lp,Mp,4]);
Nmask=Neighbors;

Nmask(1:L,:,1)=mask(2:Lp,:);
Nmask(:,1:M,2)=mask(:,2:Mp);
Nmask(2:Lp,:,3)=mask(1:L,:);
Nmask(:,2:Mp,4)=mask(:,1:M);

finished=false;

while(~finished)
    finished=true;
    Neighbors(1:L,:,1)=depthsf(2:Lp,:);
    Neighbors(:,1:M,2)=depthsf(:,2:Mp);
    Neighbors(2:Lp,:,3)=depthsf(1:L,:);
    Neighbors(:,2:Mp,4)=depthsf(:,1:M);
    Neighbors=Neighbors.*sfact;
    
    for i=1:4
        N=Neighbors(:,:,i);
        nmask=Nmask(:,:,i);
        dh=depthsf-N;
        ind=(dh<-tol)&(mask==1)&(nmask==1);
        if any(ind(:))
            finished=false;
            depthsf(ind)=N(ind);
        end
    end
end


end
%%
function depthsf=filter_shapiro(depths,order,scheme)
% modified and vectorized from shapiro2.m and shapiro2.m to use only scheme
% 1 or 2 and be faster CJ 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Hernan G. Arango %%%
%                                                                           %
% This routine applies a 2D shapiro filter to input 2D field.               %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    h        Field be filtered (2D array).                                 %
%    order       Order of the Shapiro filter (2,4,8,16,...).                %
%    scheme      Switch indicating the type of boundary scheme to use:      %
%                  scheme = 1  =>  No change at wall, constant order.       % 
%                  scheme = 2  =>  Smoothing at wall, constant order.       %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%     Fout       Filtered field (2D array).                                 %
%                                                                           %
%                                    %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fourk=[2.500000D-1   6.250000D-2    1.562500D-2    3.906250D-3     ...
    9.765625D-4   2.44140625D-4  6.103515625D-5 1.5258789063D-5 ...
    3.814697D-6   9.536743D-7    2.384186D-7    5.960464D-8     ...
    1.490116D-8   3.725290D-9    9.313226D-10   2.328306D-10    ...
    5.820766D-11  1.455192D-11   3.637979D-12   9.094947D-13];
order2=fix(order/2);



[Im,Jm]=size(depths);

depthsf=depths;


cor=zeros(Im,Jm);
for i=1:order2
%----------------------------------------------------------------------------
%  Filter all rows.
%----------------------------------------------------------------------------
cor(2:end-1,:)=2.*depthsf(2:end-1,:)-depthsf(1:end-2,:)-depthsf(3:end,:);
if (i==order2)&&(scheme==1)
    cor(1,:)=0;
    cor(end,:)=0;
else
    cor(1,:)=2.*(depthsf(1,:)-depthsf(2,:));
    cor(end,:)=2.*(depthsf(end,:)-depthsf(end-1,:));
end
end
depthsf=depthsf-cor.*fourk(order2);

for i=1:order2
%----------------------------------------------------------------------------
%  Filter all columns.
%----------------------------------------------------------------------------
cor(:,2:end-1)=2.*depthsf(:,2:end-1)-depthsf(:,1:end-2)-depthsf(:,3:end);
if (i==order2)&&(scheme==1)
    cor(:,1)=0;
    cor(:,end)=0;
else
    cor(:,1)=2.*(depthsf(:,1)-depthsf(:,2));
    cor(:,end)=2.*(depthsf(:,end)-depthsf(:,end-1));
end
end
depthsf=depthsf-cor.*fourk(order2);

end
