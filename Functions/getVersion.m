function [id,datenumber]=getVersion()
%function [id,datenumber]=getVersion()
% GridBuilder version tracker
% Charles James 2017

% update when updating GridBuilder version
id='1.2';
datenumber=datenum(2018,7,4);

% 0.90:  First stable release
% versions 0.91-0.94 updates still maintained under 0.91 release
% 0.91:  Fixed corrupted v and psi grids in ROMS output netCDF file
%        (ROMS doesn't use these grids for computation but passes them
%        through to output file for plotting)
% 0.92:  Added import reference points (unstable version)
% 0.93:  Changed Orhogonality test for spherical coordinates (unstable version)
% 0.94:  Fixed bugs, updated Cartesian mapping and changed Orthogonaity units to %
% 0.95:  Added Grid subset feature
% 0.99:  New Layout, New Grid Metrics Panel with Orthogonality and
%        Gradient factors rx0. Added New Depth filtering routines for Shapiro and
%        +/- Adjustments, faster plotting routines and new optional fast mask
%        routines using topography instead of GHSHH coastlines.  Added
%        support for ROMS vertical s-coordinates and can now compute rx1
%        for different s-coordinate options.
% 0.99.1 fix 3-axis alignment bug - zoom topography update bug - topography
%        and mask computed based on grid resolution not view.  Fix Bug in
%        large grids that can leave a row of NaN's in depth field.
% 0.99.2 user topography now used for fast mask when loaded - separate
%        buttons to display user and default coastlines, a few minor bug
%        fixes (3/2/2016)
% 0.99.3 bug in pan and zoom when in Cartesian mode, limits now set
%        properly upon exit from pan and zoom (18/7/2016). 
% 0.99.4 Inverted color for bathymetry (dark is deep now) as mask looked confusing
%        when topography also on.  Fixed bug for imported topography, sign
%        of topography is set + down before filling any nans with etopo data.
%        Added new mask editing selection feature - Contiguous Type -
%        usefull for filling in bays and large inland features - selection
%        occurs for all touching grid points of the same type (land or sea)
%        unlike other selections, points can made land or sea or toggled -
%        selection remains after modification so can be reversed without
%        undoing - button renamed "Modify Selection" (27/7/2016)
% 0.99.5 Fixed marker delete when leaving modmask mode. Changed mask
%        selection from rbbox to grid oriented selection using common
%        selection routine for subgrid (on rho instead of psi).  changed
%        file separator for SWAN text file from \ to / for more unix based
%        swan runs.
% 1.00   Tested with Matlab 2017a packaged as 
% 1.01   Tidy up and creating consistent file names - place functions
%        only called once inside calling functions 
% 1.02   Added merging for multiple user bathymetry, tested with geosci Aus
%        tiles. 
% 1.03   Added support for .xyz bathymetry tiles and new Grid Format
%        'Orthogonal' based on suggestions from John Wilkin.  Orthogonal
%        format preserves orthogonality rather than 'apparent' shape when
%        grid is translated and rotated.
% 1.1    Final update for toolbox export, new documentation and contact
%        information
% 1.2    First Public Release of Toolbox - all bugs fixed (hopefully)
end