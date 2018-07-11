function setGridResDisplay(handles)
% function setGridResDisplay(handles)
% set grid resolution display stats to metres or kilometres depending on
% size of grid
% Charles James 2017
grid=getGUIData('grid');
if isfield(grid,'mdx')&&isfield(grid,'mdy')
    if grid.mdx<1000
        handles.dispMDxi.String=[num2str(grid.mdx,'%4.0f') 'm'];
    else
        handles.dispMDxi.String=[num2str(grid.mdx/1000,'%4.1f'),'km'];
    end
    if grid.mdy<1000
        handles.dispMDeta.String=[num2str(grid.mdy,'%4.0f') 'm'];
    else
        handles.dispMDeta.String=[num2str(grid.mdy/1000,'%4.1f'),'km'];
    end
end
end