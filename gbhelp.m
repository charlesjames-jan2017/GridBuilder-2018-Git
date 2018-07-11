%% GridBuilder v1.2
%
% <<gridbuildersplash.png>>
%
%% Introduction
% GridBuilder is intended for rapid development of grids for numerical
% ocean models with a particular emphasis on elements commonly used in
% ROMS.  The GridBuilder program has three main components:  
%%
% 
% # Grid Design and Manipulation – an updated version of the original
% SeaGrid interface that can handle modifying even very large grids
% efficiently and quickly.  
% # Land Mask Creation and Editing – creates an initial land mask using
% default GSHHG polygons or user supplied coastlines and allows editing of
% cells either individually or by groups satisfying various criteria.  
% # Bathymetry Creation and Filtering – creates bathymetry from default
% Etopo2 or user supplied bathymetry, a number of filters are available to
% smooth bathymetry to satisfy model stability requirements.  
%
% Grids are created by defining the four corners of a grid and manipulating the boundaries to satisfy individual requirements.  The grid is created to be as orthogonal as possible using essentially the same fast Poisson solver routine as the original SeaGrid program.  Other elements of the grid design will be familiar to users of SeaGrid including the application of control points to create curvature on the boundaries and spacer points to modify the local resolution of the grid.  
% By default, GridBuilder designs grids in a global, spherical coordinate system of latitudes and longitudes and uses Etopo2 global bathymetry.  However, GridBuilder can import higher resolution local bathymetry in a variety of formats.  The full resolution GSHHG coastlines are also included, however users can import and use their own coastlines if required.  GridBuilder can also build grids on a Cartesian coordinate system based on physical distances. 
% Several popular metrics are used to evaluate the grid during design.  The grid orthogonality, the Beckman and Haidvogel grid stiffness, and (if the user defines a vertical coordinate) the Haney grid stiffness parameter.
% ROMS Grids can be imported that have been developed with other software and manipulated within GridBuilder.  Existing grids can be cropped to create sub-grids in order to create efficiently nested grids or expanded to extend the model domain to other areas of interest.  GridBuilder will currently grids export to a ROMS compatible netCDF file and to SWAN compatible grid topography and coordinate files.
%% Getting Started
% *Undoing and Redoing*
%
% During this tutorial you may need to undo a mistake or investigate what
% happened between changes, the toolbar includes undo and redo buttons, you
% can also use ctrl-Z and ctrl-Y or select Undo or Redo from the “Edit”
% menu.    
%
% <<toolbar.png>>
%
% *Creating a Grid*
%
% The first step is to select the type of grid and the coordinate system.
% The default grid type is orthogonal with spherical coordinates.
% Clicking on the map and dragging a box will initially create an
% rectangular grid with North and South Boundaries parallel
% along constant latitudes and East and West Boundaries lying along lines
% of constant longitude.  The default resolution is 20x10 cells, the grid
% origin is the first point selected and indicated by a blue diamond. 
%
% <<demo1.png>>
%
% In this example the first point selected was the North-West corner but
% this will make the xi coordinate (on a ROMS grid) along the Western
% Boundary. If we want to make the origin at the South-West corner (so that
% the Southern Boundary defines the xi coordinate) we can right-click on
% the South-Western point and it will become the new origin (similar to
% “rolling” the corners in SeaGrid).
%
% <<rollcornerdemo.png>>
%
% *Increasing the Grid resolution*
%
% To increase the resolution of the grid we enter the number of cells in
% the boxes at the top left of the screen.  (Note that after changing the
% origin, the resolutions of the eta and xi axis have now switched.)  In
% this case let’s increase the resolution by a factor of 15, we can do this
% by typing in *15 after each number and the program will evaluate this as
% 150 and 300 respectively.  The font turns to a highlighted italic to
% indicate the change has been made but not implemented on the grid yet;
% the grid is only recalculated after the “Done” button is pressed.  
%
% <<gridrespanel.png>>
%
% Zoom in on the area containing the grid by selecting the zoom tool from the
% toolbar and dragging around the area of interest, the coastline and
% bathymetry resolution will automatically update to the appropriate
% resolution for the view.
%
% <<gridresdemo.png>>
%  
% <html>
% <table border=1><tr><td><em>The default grid size of 10x20 cells is too few to run anything but the
% most basic model, however it is very fast to manipulate so it is useful
% for doing the initial placement.  Also, the difference in M and L makes
% it easier to identify which axis is which.</em></td>
% </table>
% </html>
%
% *Grid Metrics*
%
% Whenever a grid is created or modified, the depths and mask are
% automatically updated for the new grid.  Notice the Grid Metrics panel at
% the bottom right hand side.  Two commonly used grid metrics are
% automatically computed – Orthogonality and rx0 (Beckman and Haidvogel
% grid stiffness).  We haven’t defined a vertical coordinate yet so rx1
% (The Haney grid stiffness) can’t be computed.         
%
% <<gridmetricspanel.png>>
%
% At the moment rx0 is red or “poor” (this will be defined below).  This is
% typical for newly defined grids because we have not restricted the depths
% to be greater than 0 or smoothed the bathymetry yet.  Currently the
% orthogonality is technically “perfect” as we have defined a rectangular
% grid with all cells aligned with lines of latitude and longitude.    
%
% This grid covers a large area of land which can be inefficient for some
% models – we can use the Rotate and Translate features of GridBuilder to
% try and align the model boundaries with the coast.  So that more of the
% grid cells are “wet”.   
%
% <html>
% <table border=1><tr><td><em>Aim for green metrics, values highlighted in red or amber indicate that
% they are outside the optimal range of values for that metric and models
% using the current grid may have stability and accuracy issues</em></td>
% </table>
% </html>
%
% *Rotating the Grid*
%
% Select Rotate from the Grid Edit panel and a new Rotation panel will appear 
%
% <<gridrotpanel.png>>
%
% The boundary of the grid is displayed and moving the slide bar or typing
% a new value into the degrees field will rotate the grid around the origin
% point we selected.  Rotate the grid to align with the coastline (about
% -32 degrees in this example), don’t worry if the grid goes off the screen
% or isn’t where you want it when you finish, we will move it back in the
% next step.
%
% <<gridrotdemo.png>>
%
% When you are happy with the rotation click Finish and continue. 
%
% *Translating the Grid*
%
% The new grid may now be partly off the display screen but this won’t
% cause any serious problems, we can either zoom out and zoom back in or
% pan the screen with the hand tool.  The main problem is that the grid is
% not where we want it.  To shift the whole grid in one go select
% “Translate”.  The corners of the grid will turn blue to show they are
% active.  You can click on any visible corner and drag it – a trace of the
% grid boundary will indicate where it is while you drag it.  Drag the grid
% to a location that matches up with the coast.   Click on the pan tool and
% drag entire map to centre of domain.        
%
% <<gridtransdemo.png>>
%
% *Grid Orthogonality*
%
% Now the grid is where we want it but although it started as a rectangular
% shaped grid, it now appears slightly distorted so what happened?  This is
% due to the map projection used for GridBuilder, it necessarily distorts
% the surface of a spherical Earth; when the grid is build in the
% Orthogonal format, GridBuilder preserves the orthogonality by doing the
% rotations and transformation in a conformal or angle preserving
% coordinate system before replotting them on the GridBuilder map.  
%
% An orthogonal grid is generally ideal from a modelling perspective but
% occasionally you may need to work with an imported curvilinear grid with
% non-orthogonal elements.  To simulate this we will continue with a grid
% that is rectangular in the map coordinates but not orthogonal and attempt
% to improve the orthogonality condition so that overall errors are under
% 10%.
% 
% If we switch to the Rectangle format GridBuilder will use the origin
% point and the opposite point to create a rectangular grid in regular map
% coordinates. This will introduce an error in the orthogonality due to the
% spherical geometry of the Earth. To see how this ortogonality error works
% select Rectangle from the Format menu, you may need to change the zoom in
% order to see the new rectangular grid.  Turn of the Mesh in the Grid
% Elements panel and select Orthogonality (% error) from the Grid Metrics
% panel.  The orthogonality error in this 
% example is quite large so adjust the colorbar limits by changing the
% value of Max in the Colorbar Limits panel to a larger number (say 30 in
% this example).     
%
% <<gridorthogdemo.png>>
%
% The source of the error is now seen – the convergence of the meridians
% at this latitude means the cells are becoming increasingly distorted
% towards the southern point.  One way to adjust this is to modify the grid
% in “Free” mode.  Select “Free” from the drop down menu Format under the
% Grid Properties panel.   Once selected, the individual corners can be
% moved independently and control points can be added to create curving
% edges. This mode of grid editing will be familiar to anyone who has used
% the original SeaGrid program.       
%
% After some trial and error, you should be able to create a reasonably
% orthogonal grid by dragging the lowest corner in a northwest direction.
% To improve plot colour resolution reset the Max Colorbar limit to 10
% again.  
%
% <html>
% <table border=1><tr><td><em>The orthogonality plot will update as you
% move the corners.  The orthogonality error will turn amber when it drops
% below 15% then turn green when it goes below 10%.  You can also add
% control points to create curvature on the sides to improve the
% orthogonality of the grid.</em></td>    
% </table>
% </html> 
%
% <<gridorthogdemo2.png>>
%
% Once the orthogonality error is acceptable (<10%) the next step is to
% tell the model which cells are “wet” and require computational solutions
% while the model runs and which cells are “dry” or land cells which
% usually do not require any calculations.    
%
% *Generating the Land/Sea Mask
%
% The next thing to generate is the land mask.  GridBuilder can generate
% masks in two ways – either through the bathymetry (which is fast) or by
% selecting points within the GSHHG coastline polygons (slower but more
% accurate).     
%
% For this example use the GSHHG polygons by selecting “Use GSHHG
% coastlines” from the Mask Settings menu; the program may take a few
% moments to define the new mask.    
%
% <<gridmaskmenu.png>>
%
% To display the current mask, click on “Mask” within the Grid Elements
% panel to display that element in the main figure.    To focus on the mask
% you can also turn off any of the other grid elements and metrics that are
% still on.   
%
% We can modify the mask to clear any anomalies that might lead to poor
% performance such as isolated cells or inlets.  Select Modify Mask from
% the Screen Mode panel.  Then select “Isolated Cells” from the “Selection
% Type” drop-down menu in the Mask Edit panel.  Red stars are plotted to
% highlight the questionable cells – these can either be edited manually by
% clicking on the cell – or filled automatically by pushing the “Fill
% Selected” button.  Next select “Isolated Bays”, these are cells       
%
% <<gridmaskdemo.png>>
% 
% with only one open boundary – you may not always want to fill these but
% they can sometimes cause problems – for now use the “Fill Selected”
% button.  After you have filled in the bays the first time you may see
% some new isolated bays have been highlighted as filling in some isolated
% bays often create new ones – the menu will return to Isolated Bays as
% long as there are isolated bays to fill.  You can also search for narrow
% channels (one cell open at either end) which can be a problem when
% connecting to isolated bodies of water but we won’t worry about them now.         
%
% There may also be inland seas which will waste the models time if they
% are not masked.  GridBuilder offers several ways to handle these cases.
% To manually mask regions, Zoom in to region and set the Land option, then
% drag the mouse over any wet cells that don’t connect to the open ocean.
% The patch will automatically follow the rows and columns of the grid.
% When the mouse button is released the highlighted cells will all be
% assigned a land mask, you can play with the settings as well – toggle
% will change land to ocean and ocean to land.   
%
% <<maskexample1.png>>
%
% Another tool which we can
% use is the “Selection Type: Contiguous”.  With this selection type, all
% cells which have a connection though the same type as the selected cell
% will be selected.  This is handy for large areas with awkward shapes that
% you want to select all the cells within.  To demonstrate this, in this
% example (not from current grid) there are some wet cells to the east of 
% Tasmania that are
% disconnected from the ocean because of the model boundary, I’ll select
% these cells with Contiguous selection.  Clicking “Modify Selected” now
% will convert all these cells to land cells.  One note of caution however,
% when using contiguous selection, clicking on the wrong cell can quickly
% select large parts of the model domain.  For example clicking on one
% square of land on Tasmania will select all the land, however, as long as
% you don’t click “Modify Selected” you can unselect by changing “Selection
% Type” to None.   Note: If you do accidently delete Tasmania you can
% always use undo to restore it.                     
%
% <<maskexample2.png>>
%
% <html>
% <table border=1><tr><td><em>When you are done filling in bays and
% channels, always check for any new isolated cells that might have been
% created during the filling process.</em></td>      
% </table>
% </html> 
%
% *Generating the Grid Bathymetry*
%
% The Final step in preparing the grid is to smooth the bathymetry.  To do
% this we select “Modify Bathymetry”.  This changes to the Depth Edit view
% and displays one of the grid bathymetry metrics (rx0 by default).   In
% this example there is no vertical coordinate so we only see the results
% of the rx0 calculation.  
%
% The first problem is highlighted by the shaded minimum depth box.  The
% topography includes land topography (land has z<0 for GridBuilder), we
% should set the minimum depth to be something greater than 0.  Enter 2.0
% into the “Set Min” box.  The grid stiffness (rx0) will probably still be
% too high (rx0>0.2), but we can use one or more of the smoothing
% algorithms to adjust this.       
%
% <<gridbathpanel.png>>
%
% <<gridbathdemo.png>>
%
% First apply a Shapiro filter to the deepest topography to soften any
% spurious sea mounts.  Select the Shapiro (B.C. constant) filter from the
% drop down menu, enter 3000.00 into the “Apply below” field so that we
% only filter depths below 3000m.  The default filter “Order” of 2 is fine
% here, select that if it is not already selected and push the “Smooth”
% button.  This may not affect the maximum rx0 value shown as those values
% typically occur near the shelf break or coastline but it will have
% created a more uniform topography in the deep ocean.    
%
% <html>
% <table border=1><tr><td><em>If the “Apply below” field is set to 0 for
% the Shapiro filter the filter is applied to every wet cell. This may
% produce too much smoothing when trying to reduce the maximum rx0
% value.</em></td>
% </table>
% </html> 
%
% Now, select the Positive Adjustment algorithm from the drop down menu if
% the default value of 0.2 is not already in the Target rx0 box enter it
% now and then select smooth.   The gradient image should change
% dramatically as the adjustment will always result in a maximum value of
% rx0=0.2.  Note that this is an image of the gradient not the topography
% itself.
%
% <<gridbathdemo2.png>>
%
% <html>
% <table border=1><tr><td><em>Sometimes applying a Shapiro filter after a
% negative or positive adjustment will filter result in an increase in the
% rx0 value so use the adjustment algorithms last.</em></td>
% </table>
% </html> 
%
% The positive and negative adjustment algorithms are fairly strong
% adjustments that force the topography to satisfy the grid stiffness
% criteria exactly so use them last to achieve the desired rx0 value. 
% Often a combination of Shapiro filter in the deep water followed by one
% of the adjustment algorithms will produce a well behaved grid.  Filters
% can be applied as many times as required and in any order, but the
% adjustment routines won’t change a grid which already satisfies the
% target rx0 value.    
%
% <html>
% <table border=1><tr><td><em>To reverse the effects of a filter, use the
% undo button, or use Reset to start over from the original
% topography.</em></td>
% </table>
% </html> 
%
% *Exporting the Grid*
%
% To Save a grid for future editing in GridBuilder select File>Save As… and
% save the Matlab file.  This file can be also imported into Matlab and
% contains all the fields needed to recreate the grid (see Recognized Data
% Formats).   
%
% To export the grid for testing in ROMS or SWAN, from the menus select
% File>Export>ROMS grid (.nc) or SWAN IDLA 4 (.grd, .bot) and save the
% file.  This file will contain the grid metrics and required variables for
% use in a ROMS numerical simulation but will not contain information about
% the control points used to generate the curvilinear boundaries.      
%
% <<gridexportmenu.png>>
%
%
%% Grid Properties Panel
%
% <<gridproppanel.png>>
%
% The Grid properties are properties that determine how the grid is created
% and edited.
%
% Format:
%
% * Orthogonal:  The grid is orthogonal but when rotated will only appear
% rectangular in Cartesian coordinates.  GridBuilder will try to preserve
% the orthogonality of the grid during any rotation or translation,
% although the grid will appear to be distorted in some cases.  Control
% points are not available in this mode and corner editing or switching to
% Orthogonal format will try and reconstruct an orthogonal grid based on
% the origin and opposite corners. 
% 
% * Rectangular:  The grid appears rectangular in all coordinate systems.
% Creation requires selecting a start point and dragging to the opposite
% corner to create the rectangular grid.  A rectangular grid is only truly
% rectangular on Cartesian coordinates, it is not rectangular on spherical
% coordinates (no grid is) but it provides a fast and easy way to lay down
% the original grid over an area of interest.  A rectangular grid can only
% have straight sides so there is no way to add control points to produce
% curvature (see Grid Edit).  However the grid resolution can be telescoped
% by using spacer points (see Grid Edit).  Editing corner positions or
% switching to Rectangular will cause the grid to resize adjacent corners
% to a new rectangle.
%
% * Free:  The grid can take on any shape and is created by selecting the 4
% corners in sequence.  This form of grid is essentially the same as the
% grid in the original SeaGrid program.  Each of the four corners can be
% moved independently allowing more complex grid creation.  In addition
% spline control points can be added to create curvature along sides and
% spacer points can be used to modify local resolution (see Grid Edit).     
%
% * Fixed:  This is not a recommended format for creating and editing grids
% although the grid corners can be defined in the same manner as a Free
% Format Grid.   This format is used to protect imported curvilinear grids
% from inadvertent modification by locking out corner and control point
% manipulation (However spacers can be added as they don’t require
% recomputing the grid).     
%
% Grids can be converted between formats but be careful converting from
% Free or Fixed to Rectangular as the grid will be recalculated based on
% the origin and opposite points to create a new Rectangular grid.  
%
% Coordinates
% 
% * Spherical:  The grid design area is laid out in terms of latitudes and
% longitudes and grid distances are always distorted to some extent by the
% curvature of the surface.  The grid design workspace includes global
% topography and coastlines by default.  Exported ROMS netCDF files will
% include the variable spherical=’T’ and grid points are defined with lon_*
% and lat_* variables.     
% * Cartesian:  The grid design area is laid out in terms of distances in
% meters.  Coastlines and bathymetry are not included by default, although
% they can be imported.  Exported ROMS files will include spherical=’F’ and
% grid points are defined as x_*and y_*.   
%
% Z Coordinate
%
% * None:  The default mode is to create a 2-dimensional grid with no
% z-coordinate.  The z-coordinate is only required for calculation of the
% Haney number, and then only if the vertical coordinate is a sigma style
% coordinate.   
% * ROMS:  Currently the only type of s-coordinate supported.  Selecting a
% ROMS z-coordinate enables the calculation of the Haney number (rx1) and
% Modify Z Coordinate under Screen Mode.
%
% The Z-Coordinate has no effect on the 2D grid created with GridBuilder
% but does allow calculation of the Haney number.  The Haney number can be
% reduced by either smoothing the Bathymetry in Modify Bathymetry or by
% modifying the vertical structure in Modify Z Coordinate, typically the
% fewer vertical levels the lower the Haney number.  Even an Exported ROMS
% grid does not contain any information about the vertical structure as
% this is defined at runtime within the ROMS initialization file, but the
% grid will satisfy the user’s rx1 requirements if the vertical structure
% defined in GridBuilder is used in the model run.     
%
% <html>
% <table border=1><tr><td><em>Creating a grid in “Free” or “Fixed” mode you
% can select the corners in any order although the first point will always
% be the origin.  The corners are reordered if required to keep sides from
% crossing.  However once a grid is created, GridBuilder will not allow you
% to drag a corner to a position that would cause sides to cross.</em></td>    
% </table>
% </html> 
%
%% Grid Resolution Panel
%
% <<gridrespanel2.png>>
%
% The Grid Resolution Panel is inactive until a grid is created or loaded.
% When it is loaded the grid resolution can be modified by entering the
% number of cells in each direction.  In keeping with standard ROMS
% notation, the xi axis is defined as the axis counter clockwise to the
% grid origin point (see grid creation) and the eta axis is defined as the
% axis clockwise to the grid origin point.  The number of cells in along
% the xi axis is indicated by L and the number of cells along the eta axis
% by M.  The centre of the cells correspond to the rho points in the ROMS
% convention, but note that in ROMS the outer rows of cells are considered
% external to the computational grid and are used for boundary conditions.
% The internal intersections of the grid correspond to the ROMS psi grid.
%
% <html>
% <table border=1><tr><td><em>When changing grid resolution you can use any
% Matlab expressions to compute the new resolution, for example 270*2 will
% produce 540, 20^2 will become 400 and 270*2-3 will evaluate to 537.  Note
% that the result will always be rounded to the nearest integer greater
% than 2 (GridBuilder requires a minimum of 3x3 cells).   This can be
% useful when trying to create a nested grid with a resolution that is an
% integer multiple of the parent grid.</em></td>
% </table>
% </html> 
%
%% Screen Mode
%
% <<screenmodepanel.png>>
%
% Screen mode determines which property of the grid is currently being
% modified.  The properties are the grid itself, the grid mask, the grid
% bathymetry, and the grid Z-Coordinate.  Note “Modify Z-Coordinate” is
% only available if you have selected a Z-Coordinate from the “Grid
% Properties” pull down menu described above.    
%
% Modify Grid/Grid Edit
% 
% <<gridmodpanel.png>>
%
% In the original SeaGrid program, corners, control and spacer points could
% all be manipulated at the same time and the program would sometimes
% misinterpret the user’s intention when points were close to each other.
% To avoid this we have separated the control of these points into separate
% functions so corners can only be manipulated when “Corners” is selected
% and so forth.
%
% * Corners:  Left mouse click on a corner allows user to drag corner to
% new location.  In “Format: Rectangle” mode the two adjacent corners are
% repositioned to form a new rectangle, in “Format: Free” mode the corner
% is moved by itself.  Right mouse click on a corner to make that corner
% the new grid origin (signified by a blue diamond shape), grid axis and
% rotations are defined relative to this point.  In Fixed mode only the
% redefinition of the origin is available so corner points can’t be dragged
% to a new position.       
% * Control:  Only available in “Format: Free” mode.  A left mouse click on
% one of the sides will create a new control point signified by a small
% blue circle.  A left mouse click on an existing control point will allow
% the control point to be moved by dragging to a new point.  The curvature
% of each side is defined by a cubic spline through the control points.  A
% right click on an existing control point will delete it and cause the
% side to be recalculated.  A “Clear” button is provided to rapidly clear
% all control points which will cause the sides to all be straight lines
% again.  For very coarse grids the control points may not lie exactly on
% the line but still define the equation of the spline through which the
% line segments are mapped.    
%
% <html>
% <table border=1><tr><td><em>With control points it is possible to create
% an invalid grid with cells outside the boundary of the grids.   This is a
% limitation of the fast Poisson solver at core of the program.  If the
% grid is invalid the colour of the grid will change from green to magenta.
% An invalid grid can often be fixed by modifying control points or
% changing the resolution but will probably still have serious
% orthogonality issues.</em></td>      
% </table>
% </html> 
%
% <<gridbad.png>>
%
% * Spacer:  By default all grids start with 5 equally spaced spacer point
% on each axis.  Spacer points are plotted as small blue squares.  A left
% mouse click on one of the sides will create a new spacer point.  A left
% mouse click on an existing spacer point will allow the user to drag the
% spacer point along the line.  A right click on a spacer point will delete
% the point and a middle mouse button click on the side will reset all
% spacer point to equidistant separations.  Spacer points work by modifying
% the width of cells according to a spline interpolation through the spacer
% point’s separation.  Where spacer points are closer together the cell
% width is smaller allowing the user to “telescope” the grid into higher
% resolutions in some locations.  The spacing algorithm is symmetric on
% opposing sides so modifying one side is the same as modifying the
% opposite side.  The “active” sides for spacer manipulation are always the
% two sides adjacent to the origin point.  Spacer points are available on
% any grid format.
% * Rotate:  A feature of GridBuilder is the ability to rotate any existing
% grid.  When selected a schematic of the border is shown as a dashed blue
% line and the Rotation panel is available for doing rotations and fine
% tuning.  The rotation can be modified quickly with the slide bar, or a
% more precise rotation can be given by editing the value in the text box.
% Once the grid is rotated into the position desired the user clicks on the
% “Finish” button to recalculate the grid at the new orientation.  Rotation
% is available for any grid format.  Note that under rotation the
% orthogonality of a grid in spherical coordinates will change due to the
% distortion of the map projection.  
%
% <<gridrotpanel.png>>
%
% * Translate:  When selected the four corners turn blue and clicking on
% one of the corners allows the entire grid to be dragged to a new location
% without altering its orientation.  When the mouse button is released the
% new grid is calculated.  Translation is available for all grid formats.
% Note that translating a non-rectangular grid on a spherical coordinate
% may change the orthogonality of the grid if translated north or south.     
% * Expand:  When selected the four sides turn blue and clicking on one of
% the sides prompts the user to add additional cells to that side (you must
% click on OK after entering the number).  The new cells are added without
% modifying the existing grid (although any control points will be removed
% from all sides).  The grid resolution panel will be updated to reflect
% the additional cells.  The depths and mask are only added for the new
% cells, but this still may change some of the metrics so the user may want
% to resmooth the depths and recheck the mask.    This feature will work on
% curvilinear grids as well with new points calculated by linear
% extrapolation, for strong curvature this may produce unacceptable
% orthogonality errors.  Curvilinear grids will also lose their control
% points so subsequent modification of corners or addition of control
% points will cause the grid to lose its original structure. Because
% the locations of the original grid elements do not change, Expand is
% available for all grid formats including Fixed.  
%
% <<gridexpandpanel.png>>
%
% <html>
% <table border=1><tr><td><em>Expand becomes contract if you enter a
% negative number, this is useful for trimming unnecessary dry rows or
% columns from an existing grid without having to recalculate the mask and
% depths as those rows or columns are deleted as well.</em></td></tr>
% <td><em>It is possible to create an invalid grid by excessive expansion
% (the linear extrapolation can cause sides to cross if opposite sides
% converge), the program will detect if the expansion will create an
% invalid grid and will give the user a message and return to expansion
% mode without executing the expansion.</em></td>
% </table>
% </html> 
%
% Modify Mask/Mask Edit
%
% <<gridmaskpanel.png>>
%
% Selecting Modify Mask brings up the Mask Edit Panel and displays the
% current mask in the grid display area.   The default mask edit mode is
% “Toggle” in this mode when the user clicks on a cell within the grid the
% mask changes status so a dry point will become a wet point and vice
% versa.   Clicking and dragging will select and highlight a rectangular
% region of the grid and all cells within that region will have their
% status modified according to the edit mode.  
%
% <<maskexample3.png>>
%
% For example, selecting a box region including wet and dry points near the
% coast with “Toggle” on will switch all point status within the box.
% With edit mode “Land” all selected points are converted to dry points and
% with edit mode “Ocean” all selected points are converted to wet points.
% The “Reset” button will recalculate the mask from scratch using the
% current mask settings (see “Mask Settings” in menu items) and the “Clear”
% button will set all points to wet.      
% It is also possible to select multiple cells that satisfy one of several
% criteria for masking.   There are currently 4 group selection types
% available (excluding the default “none”). 
%
% * Isolated Cells:  Cells with no external contacts.  Filling these cells
% simply reduces the number of cells for which calculations are done
% without affecting the model performance.  Note that this will not pick up
% isolated lakes or ponds if they contain more than one adjacent cell.   
%
% <<maskexample4.png>>
%
% * Isolated Bays:  Cells with only a single external contact.  These cells
% can sometimes lead to artefacts in model solutions and the user may want
% to consider filling them. 
% * Narrow Channels:  Cells with two external contacts on opposite sides.
% These cells may or may not need to be filled but may cause issues,
% especially with flushing of small or isolated bays.  
% * Contiguous:  A recursive search of all cells of the selected type that
% connect back to the original, useful for selecting large number of cells
% in lakes and bays that are not in contact with the ocean.  Can also be
% used to select and delete islands or large land masses.  
% 
% <<maskexample5.png>>
%
% Changes made to the mask in Modify Mask mode take effect immediately but
% can be undone with the undo options (see Undo). 
%
% Modify Bathymetry/Depth Edit
%
% <<gridbathpanel2.png>>
%
% Selecting Modify Bathymetry brings up the Depth Edit panel.  Changes here
% effect the depths on the current grid.  The main display will display
% either rx0, rx1 or Depths depending on the user’s previous selection.   
%
% * Set Min:  The value entered here will be the minimum depth over the
% entire grid.  Values less than this value will be reset to this value.
% Numerical models using sigma coordinates cannot have depths <=0 so the
% minimum depth field is highlighted in red when values above this
% threshold are entered.  Changes to the minimum depth field are applied
% immediately.     
% * Set Max:  The value entered here will be the maximum depth over the
% entire grid.  Values greater than this value will be reset to this value.
% There are no numerical limitations to the size of the maximum depth.
% Changes to the maximum depth field are applied immediately.    
% * Reset:  This resets the depths by recalculating the depths on the
% predefined grid.  It will use the original default bathymetry (etopo2)
% merged with any imported bathymetry to reproduce the original raw
% topography with no limits or smoothing.    
% * Target rx0:  For the Adjustment filters that are guaranteed to
% converge, the user can set a Target rx0 value.  The filter will
% automatically iterate until the target rx0 value is achieved.    
%
% <html>
% <table border=1><tr><td><em>If the rx1 value is too high even when the
% rx0 value is acceptable, reduce the target rx0 value by the same factor
% that you want to reduce the rx1 value by.  For a particular vertical
% structure the two numbers are proportional.</em></td>         
% </table>
% </html> 
%
% * Apply Below:  For the Shapiro filters the user can select a depth below
% which to apply the filter.  The Shapiro filters are often most effective
% on deep ocean peaks and can over-smooth in shallow water.  Selecting a
% depth of 0 will smooth everywhere, selecting a depth of 4000 will only
% smooth the topography below 4000m.    
% * Filter:  A number of filter options are available to smooth the grid:
%
% #     Negative Adjustment (default):  Modifies cells adjacent to cells
%      where the rx0 value exceeds the target by adjusting the topography
%      downwards.  This filter will converge to a target value.  Changes
%      are only applied when the Smooth button is selected.   
% #     Positive Adjustment:  Modifies cells adjacent to cells where the rx0
%      value exceeds the target by adjusting the topography upwards.  This
%      filter will converge to a target value.  Changes are only applied
%      when the Smooth button is selected.   
% #     Shapiro (B.C. constant):  Applies a Shapiro filter to the entire
%      domain with constant boundary conditions.  This filter can be run at
%      a number of different orders but is not guaranteed to converge.  It
%      can be run repeatedly by the user to achieve better rx0 values.
%      Changes are only applied when the Smooth button is selected.    
% #     Shapiro (B.C. smooth): Applies a Shapiro filter to the entire domain
%      with smooth boundary conditions.  This filter can be run at a number
%      of different orders but is not guaranteed to converge.  It can be
%      run repeatedly by the user to achieve better rx0 values.  Changes
%      are only applied when the Smooth button is selected.    
%
% * Order:  Determines the order of the Shapiro filter.
% * Smooth:  Will execute the currently selected filters.  
%
% Filtering can be applied in any order and subsequent filtering is applied
% to the current depth so the effect is cumulative.  To go back to the
% original depths use the “Reset Button”.  
%
% Modify Z Coordinate/ROMS S-Coordinate
%
% <<gridzpanel.png>>
%
% This panel is selected by choosing “Modify Z Coordinate” in the Screen
% Mode panel.  This option is only enabled if the Z-Coordinate is set to
% ROMS in the Grid Properties panel.  It displays the settings used in the
% ROMS initialization file to define the vertical structure of the
% s-coordinate.  There are 6 parameters that need to be set to determine
% the vertical structure and they can be modified by either typing in a new
% value or pulling down a setting from a drop down menu.    
%
% * N:  The total number of vertical levels
% * Vtransform:  A ROMS s-coordinate uses one of two vertical transform
% algorithms that can be specified here. 
% * Vstretching:  A ROMS s-coordinate uses one of 4 vertical stretching
% algorithms that can be specified here. 
% * Theta_S:  Specifies the degree of stretching at the surface.  The
% effect of Theta_S depends on the transform and stretching algorithms
% selected.  
% * Theta_B:  Specifies the degree of stretching at the bottom.  The effect
% of Theta_B depends on the transform and stretching algorithms selected. 
% * Tcline (hs):  Specifies the so-called critical depth, the effect of
% Tcline depends on the transform and stretching algorithms. 
% To the right of the parameters are two schematic representations of the
% s-coordinates.  The one labelled h>Tcline shows the level stretching
% for a cell with depths greater than Tcline in the current grid.  The one
% labelled h<Tcline shows the distribution of levels for a cell which has a
% depth less than Tcline.  The user can examine the distribution of the
% vertical levels as the parameters are modified.  The calculation of rx1
% is also updated after each modification.  If rx1 is still too high even
% when rx0 is adequate, it may be necessary to resmooth the bathymetry with
% a smaller target for rx0.          
%
% <html>
% <table border=1><tr><td><em>For a particular vertical structure rx1 (the
% Haney number) will be proportional to rx0 so the only way to reduce rx1
% without additional smoothing is to modify the vertical structure.
% Reducing the number of levels often helps but the other parameters also
% influence the Haney number.   ROMS users can also use this panel to
% explore the effect of the vertical structure on the Haney number an
% existing ROMS grid by importing it and playing with the
% parameters.</em></td>
% </table>
% </html> 
%
%% Map Elements
%
% <<gridmapelements.png>>
%
% For a workspace in spherical coordinates there are two elements that can
% be plotted even if no grid has been defined. 
%
% * Coastline:  Selected by default.  The coastline is presented by an
% orange line and is based on the GSHHG coastlines.  The actual resolution
% used depends on the axis limits of the workspace and will use the full
% resolution polygons for small enough regions.  If the user has loaded
% their own coastline (see import Coast Data) this will be plotted in blue
% and overlaid on the GSHHG coastline.     
% * Topography:  When selected this will show the basic Etopo2 topography
% included with GridBuilder.  If the user has loaded their own topography
% (see import Bathymetry Data) the users bathymetry is bounded by a black
% and white border and merged with the existing topography.  A new grid
% will use the user’s topography where it exists and etopo2 elsewhere.    
%
% <<gridmapelementsdemo.png>>
%
%% Grid Elements
%
% <<gridelementspanel.png>>
%
% Once a grid has been defined it automatically generates the depths on the grid and the mask.  These properties can be plotted up in the workspace by toggling these buttons on and off.
%
% * Grid:  The grid here refers to the green mesh grid which defines the
% individual cells.  For very high resolution grids the mesh itself may
% interfere with details the user may want to see so it can be unselected
% here.  There are also some editing options which will turn off the grid
% and to see the grid the user will need to turn it back on.  In most cases
% the corners and sides of the grid remain when the mesh is hidden.     
% * Depths (Grid):  The depths here refer to the depths interpolated to the
% cells of the grid rather than any user or default topography.  If the
% depths have been modified or edited the results of that will be reflected
% here.   
% * Mask:  The mask defines wet and dry points on the grid. If the mask
% has been modified with the Mask Edit controls, the changes
% will be reflected here until the grid is moved or edited.  
% These grid elements will be saved or exported with the grid.
%
%% Grid Metrics
%
% <<gridmetricspanel.png>>
%
% There are three grid metrics that can evaluate the potential stability of
% the grid when used in a numerical model.  Only one of the metrics can be
% plotted at a time as they overlay each other.  
% * Orthogonality (% error):  The error in the orthogonality of the grid is
% determined by looking at each intersection of the cell boundaries and
% measuring the maximum departure from 90O in the 4 adjoining cells.  The
% angle of intersection is calculated in spherical coordinates when they
% are selected so a rectangular grid will not, in general, be rectangular
% on a sphere, however a rectangular grid will be perfectly orthogonal (0%
% error) on a  Cartesian coordinate system.   In general grid orthogonality
% errors should be 10% or less.  If the maximum orthogonality error is less
% than or equal to 10% the value is coloured green, between 10 and 15% the
% value is coloured orange, and above 15% the value is coloured red to
% indicate a relatively high error.         
% * Gradient rx0:  The Beckmann and Haidvogel number is a measure of the
% relative change in depth in adjacent cells normalized by depth.
% Generally a maximum value of 0.2 for rx0 is considered acceptable for
% grid stability so rx0 values less than or equal to this are coloured
% green.  The value of rx0 is calculated without considering negative
% depths (above water topography) so the maximum value it can attain is
% 1.00.  The value of rx0 will change from orange to red if it is larger
% than 0.4 to indicate a relatively large rx0.       
% * Gradient rx1:   The Haney number looks at the gradient and the spacing
% between sigma levels in order to help quantify the potential for errors
% in the pressure gradient terms (gradients along constant depths as
% opposed to constant sigma surface).  The larger the Haney number the
% worse the grid performance.  Comments on the ROMS forum suggest that
% Haney numbers up to 7 are usually stable and are coloured green. Even
% Haney numbers larger than that can be used if the vertical stratification
% of the model is relatively weak.  The colour of the rx1 number changes
% from orange to red for values of maximum rx1 > 10 to indicate a
% relatively large rx1.         
%
%% Colorbar Limits
%
% <<colorbarpanel.png>>
%
% When Topography, Depth, Orthogonality, rx0, or rx1 are plotted a panel
% appears that lets the user modify the current colorbar limits.  This is
% most useful for helping identify topographic features where there is
% often a large gradient between the deep ocean and coastal areas, but it
% can also be useful for highlighting critical values in the grid metrics.    
%
% * Max: Sets the maximum value to be plotted in the display.  If this
% value is less than the Minimum value it becomes the minimum value. 
% * Min: Sets the minimum value to be plotted in the display.  If this
% value is more than the Maximum value it becomes the new maximum 
% * Max Range:  Automatically sets the limits to the maximum range of the
% current parameter being plotted. 
%
%% Menu Items
% 
%%% File
%
% New Grid:  Clears current workspace and reinitializes GridBuilder to
% create a new grid 
%
% Load Grid:  Loads a new grid from a Matlab file created by GridBuilder
%
% Save Grid:  Saves Current Grid to a Matlab file that can be read back in
% or loaded into Matlab.  If the current grid has been saved this will keep
% the same name and over-write the last file.  
%
% Save As…:  If the current grid has been saved but the user wants to save
% under a new name.
%
% Export:
%
% * ROMS grid (.nc):  This will create a netCDF file which is compatible
% with most current versions of ROMS
% * SWAN IDLA 4 (.grd,.bot):  This will create two separate files that can
% be used as the basis for a SWAN wave model.  The grids will be consistent
% with ROMS grids and can be used for two-way coupling. 
%
% Import:
%
% * ROMS:  This will import an existing ROMS netCDF grid file.  The
% imported file will be assigned to a fixed format.  If the ROMS file has
% curved sides GridBuilder will not be able to assign control points to
% match the grid shape.   
% * Coast Data:  This will import custom coast line data in a range of
% binary and text formats (see recognized data formats). 
% * Bathymetry Data:  This will import custom topographic data in a range
% of binary and text formats (see recognized data formats). 
% * Reference Points:  The user can set or import Reference x,y points from
% from a variety of binary and  text formats (see recognized data formats).
% These points can be displayed on the map to aid in new grid design (see
% toolbar items).
%
% Clear:
% 
% * User Coast Data:  Clears any imported coast data and reverts to all
% coasts to default coasts (GSHHG) 
% * User Bathymetry:  Clears any imported bathymetry data and reverts all
% bathymetry to default (etopo2) 
% * Exit:  Exits GridBuilder (same as clicking on close button)
%
%%% Edit
%
% Undo:  Will undo all steps back to grid creation or new grid
%
% Redo:  Will redo steps previously undone.
%%% Mask Settings
%
% Use Topography (Faster):  Base mask on topography where land is wherever
% depth is <0.  This is the fastest way to generate a mask but does miss
% some high resolution features.   
%
% Use GSHHG Coastlines (More Accurate):  Create mask by comparing locations
% to GSHHG polygons.  The method is slower as all polygons within the grid
% must be checked but it is much more accurate for high resolution
% coastlines.  This method will also set lakes and ponds to wet points so
% some mask editing may be required once the mask is generated.      
%
% Use Imported Coastline:  Will use the current imported coast line to
% generate the mask.  Note that only the imported coastline is used to
% create the mask so if the grid extends beyond the range of the imported
% coastline any land cells must be manually masked using the Mask Edit
% panel or they will be treated as wet cells.  This option is only
% available if the user has imported a custom coastline.
%
% Max Mask Resolution (GSHHS):  The GSHHS comes in 5 levels of resolution,
% Coarse, Low, Intermediate, High, and Full.  When using the GSHHG polygons
% to generate a mask GridBuilder selects the appropriate resolution based
% on the minimum grid spacing, but this can be overridden here and a lower
% resolution can be selected to speed up processing.  The default setting
% is automatic and lets GridBuilder decide which resolution to use.     
%
%% Toolbar Items
%
% <<toolbaritems.png>>
%
% From left to right:
%
% * Clear current grid and reinitialize Grid Builder for new grid.
% * Quick save current grid.
% * Zoom and Pan current domain.
% * Undo and Redo steps.
% * Toggle reference points (if imported).  Reference points are plotted as
% black crosses. 
% * Select a sub grid.  When selected the mouse can be used to select a
% region within the current grid by clicking and dragging on the current
% grid.  The selected region is highlighted in red and when the mouse
% button is lifted the user is prompted to clear the unselected grid.  The
% user is also prompted to save the previous grid.  The creation of a sub
% grid does not reinitialize the grid so the step can be undone.      
%
% <<selectsubgrid.png>> 
%
% * Gives information on the version number and author contact.
%
%
%% Recognized Data Formats
%
% *Input Files*
%
% Model Grids:  GridBuilder can read in grids from Matlab files created
% with GridBuilder and Seagrid (.mat) and netCDF grids created for use with
% ROMS (.nc).  
%
% Reference Points:  GridBuilder will read in the boundary rho points from
% a ROMS file (lon_rho and lat_rho) and apply them as reference points.
% GridBuilder can also read data from a two column ASCII file with
% longitudes (x data) in the first column and  latitudes (y data) in the
% second column.    
%
% Bathymetry:   GridBuilder can read in data from a variety of bathymetry
% files including netCDF, ASCII files (Seagrid, Geosciences Australia,
% etc.).   GridBuilder will also try and extract bathymetry from a wide
% array of files including ROMS grid files, Excel Files or Matlab files.
% The x, y and z coordinates will be read from any variable with one of the
% following names:     
%
% * 'X', 'x', 'xbathy', 'lon', 'Lon', 'longitude', 'Longitude', 'LON', 'x_rho', or 'lon_rho'
% * 'Y', 'y', 'ybathy', 'lat', 'Lat', 'latitude', 'Latitude', 'LAT', 'y_rho', or 'lat_rho'
% * 'Z', 'h', 'z', 'zbathy', 'depth', 'Depth', 'DEPTH', 'Elevation', 'Band1', or 'depths'
%
% Coastlines:  Grid builder can read in coastlines from two column ASCII
% files with polygons separated by NaNs or from Matlab files with any of
% the following x, y variable names  
%
% * ‘x’, ’lon’, ’Lon’, ’longitude’, ’Longitude’, or ’LON’
% * ‘y’, ‘lat’, ‘Lat’, ‘latitude’, ‘Latitude’, or ‘LAT’
% 
% *Output Files*
%
% GridBuilder:  Saves to a GridBuilder Matlab file  with the following fields:
%
% * grid:  location of grid nodes (psi points + sides) and various grid metrics.                 
% * side:  location of boundary points, control points and spacers.                 
% * corner:  location of corners starting with origin.               
% * mask:   current land/sea mask (0=land,1=sea)  on rho points of grid.               
% * depths:  current depths on rho points of grid.
% * coast:  truncated GSHHS polygons visible during last display update.                
% * bathymetry:  eTopo2 bathymetry visible during last display update           
% * limits:  x,y limits of last display update               
% * Translation:  x, y displacement from original grid origin if a translation has been done          
% * Rotation:  rotation relative to original grid, in degrees;            
% * Dtheta:  incremental change in rotation since last rotation, in degrees.               
% * projection:  Spherical or Cartesian           
% * GridType:  Rectangular, Free, or Fixed             
% * bathyInterpolant:  Matlab interpolant (gridded or scattered) generated from eTopo2     
% * userbath:  true or false if user has imported bathymetry             
% * user_BathyInterpolant:  if userbath=true contains Matlab interpolant of user bathymetry.
% * usercoast:  true or false if user has imported coastline data              
% * user_coast:  if usercoast=true, structure with user imported polygons.           
% * Z:  field exists if user has defined a Z coordinate – currently only ROMS coefficients supported.             
%
% ROMS:  GridBuilder will export to a ROMS compatible netCDF grid file
%
% SWAN:  GridBuilder will export to SWAN compatible depth and coordinate files.






