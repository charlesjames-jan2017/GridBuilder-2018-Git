function varargout=setExportSWANgrid(fname)
% create SWAN compatible grids
% convert to format SWAN idla format 4
% from SWAN user manual:
% idla=4 SWAN reads the map from left to right starting in the lower-left-hand 	 
%   	corner of the map. A new line in the map need not start on a new line 	 
%   	in the file. The lay-out is as follows: 	 
%   	1,1 2,1 ... mxc+1, 1 	 
%   	1,2 2,2 ... mxc+1, 2 	 
%   	... ... ... ... 	 
%   	1,myc+1 2,myc+1 ... mxc+1, myc+1 	 
getVarcheck('fname',[]);
grid=getGUIData('grid');



% grid points are on cell centres
[x,y]=getBpsi2rho(grid.x,grid.y);

% mask and depths on rho points
mask_rho=getGUIData('mask');
H=getGUIData('depths');

% find land and create exception values
land=(mask_rho==0);
H(land)=-9999;
x(land)=-9999;
y(land)=-9999;
% flip H for the .bot file
H=H';
coord=[x(:);y(:)];
[n,m]=size(x);



% save as ascii files for SWAN
if ~isempty(fname)
    [pth,nm]=fileparts(fname);
    fnco=fullfile(pth,[nm,'.grd']);
    fnbot=fullfile(pth,[nm,'.bot']);
    % convert to UNIX filesep (for SWAN apps running on UNIX machines)
    fnco=strrep(fnco,filesep,'/');
    fnbot=strrep(fnbot,filesep,'/');
    
    fnscript=fullfile(pth,[nm '_swan_script.txt']);
    fid=fopen(fnscript,'w');
    fprintf(fid,'CGRID CURVILINEAR %i %i EXC -9999\n',n-1,m-1);
    fprintf(fid,'READGRID COORDINATES 1 ''%s'' 4 0 0 FREE\n',fnco);
    fprintf(fid,'INPGRID BOTTOM CURVILINEAR 0 0 %i %i EXC -9999\n',n-1,m-1);
    fprintf(fid,'READINP BOTTOM 1 ''%s'' 4 0 FREE\n',fnbot);
    fclose(fid);
    save(fnco,'-ascii','coord');
    save(fnbot,'-ascii','H');
end
if nargout>0
    varargout{1}=H;
    if nargout==2
        varargout{2}=coord;
    end
end


end
