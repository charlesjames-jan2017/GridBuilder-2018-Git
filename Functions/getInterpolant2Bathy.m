function bathy=getInterpolant2Bathy(Interpolant)
switch class(Interpolant)
    case 'griddedInterpolant'
        xvec=Interpolant.GridVectors{1};
        yvec=Interpolant.GridVectors{2};
        [xbathy,ybathy]=ndgrid(xvec,yvec);
        bathy.xbathy=xbathy(:);
        bathy.ybathy=ybathy(:);
        bathy.zbathy=Interpolant.Values(:);
    case 'scatteredInterpolant'
        bathy.xbathy=Interpolant.Points(:,1);
        bathy.ybathy=Interpolant.Points(:,2);
        bathy.zbathy=Interpolant.Values(:);
    otherwise
        bathy.xbathy=[];
        bathy.ybathy=[];
        bathy.zbathy=[];
end
end