function h=setPlotImage(hax,X,Y,Z)
% function h=setPlotImage(h_axis,X,Y,C)
% h_axis:  optional axis handle
% X, Y:  coordinates of image points
% C:     value of image at X and Y
% plots pixels on X,Y not between like pcolor
% usually does.
% Charles James 2017

% get new pixel coordinates
[XI,YI,ZI]=cell2vertex(X,Y,Z);

h=pcolor(hax,XI,YI,ZI);
h.LineStyle='none';

end
%%
function [XI,YI,ZI]=cell2vertex(X,Y,Z)
% function [XI,YI,ZI]=cell2vertex(X,Y,Z)
% create data will plot vertex values with pcolor
% X, Y:  coordinates of image points
% Z:     value of image at X and Y
% Charles James 2017

% make sure no nans in X and Y grid for gradient calculation
if ~any(isnan(X(:)))&&(~any(isnan(Y(:))))
    [XX,XY]=gradient(X);
    XI=X-XX/2-XY/2;
    XI=[XI, XI(:,end)+XX(:,end);
        XI(end,:)+XY(end,:),(XI(end,end)+(XY(end,end)+XX(end,end)))];
    [YX,YY]=gradient(Y);
    YI=Y-YX/2-YY/2;
    YI=[YI,YI(:,end)+YX(:,end);
        YI(end,:)+YY(end,:),(YI(end,end)+(YY(end,end)+YX(end,end)))];
else
    X=.5*(X(2:end,2:end)+X(1:end-1,1:end-1));
    Y=.5*(Y(2:end,2:end)+Y(1:end-1,1:end-1));
    XI=[X(1,1),X(1,:),X(1,end);
        X(:,1),X,X(:,end);
        X(end,1),X(end,:),X(end,end)];
    YI=[Y(1,1),Y(1,:),Y(1,end);
        Y(:,1),Y,Y(:,end);
        Y(end,1),Y(end,:),Y(end,end)];
end

    ZI=[Z, Z(:,end);
        Z(end,:),Z(end,end)];
end