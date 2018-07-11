function imaskSelect=getMaskFeature(mask,choice)
% function imaskSelect=getMaskFeature(mask,choice)
% identifies various features of a mask that may degrade performance of
% models using the grid
% Charles James 2017
maskScore=getMaskScore(mask);
imaskSelect=false;
switch choice
    case 'Isolated Bays'
        % mask Score for Isolated Bays (1 side open)
        imaskSelect=(maskScore==7)|(maskScore==11)|(maskScore==13)|(maskScore==14);
    case 'Isolated Cells'
        imaskSelect=(maskScore==15);
    case 'Narrow Channels'
        imaskSelect=(maskScore==5)|(maskScore==10);
end
end
%%
function maskScore=getMaskScore(mask)
% function maskScore=getMaskScore(mask)
% Charles James 2017
if nargin==0
    mask=getGUIData('mask');
end
binaryMask=false([size(mask),4]);
% find number of adjacent open cells to every mask point
% N=[1 0 0 0]
% E=[0 1 0 0]
% S=[0 0 1 0]
% W=[0 0 0 1]
% cells that have a mask to the N (boundaries are considered masks)
binaryMask(1,:,1)=true;
binaryMask(2:end,:,1)=mask(1:end-1,:)==0;
% cells that have a mask to the E
binaryMask(:,end,2)=true;
binaryMask(:,1:end-1,2)=mask(:,2:end)==0;
% cells that have a mask to the S
binaryMask(end,:,3)=true;
binaryMask(1:end-1,:,3)=mask(2:end,:)==0;
% cells that have a mask to the W
binaryMask(:,1,4)=true;
binaryMask(:,2:end,4)=mask(:,1:end-1)==0;

binaryMask=double(binaryMask);
maskScore=binaryMask(:,:,1)+2.*binaryMask(:,:,2)+4.*binaryMask(:,:,3)+8.*binaryMask(:,:,4);

% cells which are masks themselves set to 16
maskScore(mask==0)=16;
end