function Z_w=getROMSsigma(h,gtype)
% function Z_w=getROMSsigma(h,gtype)
% compute vertical depths for grid sigma set-ups using depth h
% Charles James 2017
Sigcoef=getGUIData('Sigcoef');
Vtransform=Sigcoef.Vtransform;
Vstretching=Sigcoef.Vstretching;
N=Sigcoef.N;
Theta_S=Sigcoef.Theta_S;
Theta_B=Sigcoef.Theta_B;
Tcline=Sigcoef.Tcline;
sdepth=size(h);

% do for C_w,s_w (igrid=5);
[C_w, sc_w]=ROMScalcCs_w(Vstretching, Theta_S, Theta_B, N,gtype);

% create array of correct output size (put z variable last for computation)
CZ=permute(repmat(C_w(:),[1 sdepth]),[2:length(sdepth)+1 1]);
scZ=permute(repmat(sc_w(:),[1 sdepth]),[2:length(sdepth)+1 1]);
depthZ=repmat(h,[ones(size(sdepth)) length(C_w(:))]);
switch Vtransform
    case 1
        % original form
        Z_w=((scZ-CZ)*Tcline + CZ.*depthZ);
    case 2
        % modified form
        Z_w=depthZ.*((Tcline*scZ+CZ.*depthZ)./(Tcline+depthZ));
end

end
%%
function [C, s]=ROMScalcCs_w(Vstretching, theta_s, theta_b, N,gtype)
% function [C, s]=ROMScalcCs_w(Vstretching, theta_s, theta_b, N,gtype)
% compute C and s for ROMS sigma coordinate variables - based on ROMS code
% Charles James 2017

switch gtype
    case 'w'
        lev=0:N;
    case 'rho'
        lev=(1:N)-0.5;
end
s=(lev-N)/N;

%--------------------------------------------------------------------------
% Compute ROMS S-coordinates vertical stretching function
%--------------------------------------------------------------------------

switch Vstretching
    case 1
        % Original vertical stretching function (Song and Haidvogel, 1994).
        if (theta_s > 0)
            Ptheta=sinh(theta_s.*s)./sinh(theta_s);
            Rtheta=tanh(theta_s.*(s+0.5))./(2.0*tanh(0.5*theta_s))-0.5;
            C=(1.0-theta_b).*Ptheta+theta_b.*Rtheta;
        else
            C=s;
        end
    case 2
        % A. Shchepetkin (UCLA-ROMS, 2005) vertical stretching function.
        alfa=1.0;
        beta=1.0;
        if (theta_s > 0)
            Csur=(1.0-cosh(theta_s.*s))/(cosh(theta_s)-1.0);
            if (theta_b > 0)
                Cbot=-1.0+sinh(theta_b*(s+1.0))/sinh(theta_b);
                weigth=(s+1.0).^alfa.*(1.0+(alfa/beta).*(1.0-(s+1.0).^beta));
                C=weigth.*Csur+(1.0-weigth).*Cbot;
            else
                C=Csur;
            end
        else
            C=s;
        end
    case 3
        %  R. Geyer BBL vertical stretching function.
        if (theta_s > 0)
            exp_s=theta_s;      %  surface stretching exponent
            exp_b=theta_b;      %  bottom  stretching exponent
            alpha=3;            %  scale factor for all hyperbolic functions
            Cbot=log(cosh(alpha*(s+1).^exp_b))/log(cosh(alpha))-1;
            Csur=-log(cosh(alpha*abs(s).^exp_s))/log(cosh(alpha));
            weight=(1-tanh( alpha*(s+.5)))/2;
            C=weight.*Cbot+(1-weight).*Csur;
        else
            C=s;
        end
    case 4
        % A. Shchepetkin (UCLA-ROMS, 2010) double vertical stretching function
        % with bottom refinement
        if (theta_s > 0)
            Csur=(1.0-cosh(theta_s.*s))/(cosh(theta_s)-1.0);
        else
            Csur=-s.^2;
        end
        if (theta_b > 0)
            Cbot=(exp(theta_b.*Csur)-1.0)/(1.0-exp(-theta_b));
            C=Cbot;
        else
            C=Csur;
        end
    otherwise
        C=NaN;
end



end
