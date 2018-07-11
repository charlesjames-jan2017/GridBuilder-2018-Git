function [filename,pathname]=putGBfilename(varargin)

FilterSpec=varargin{1};
if nargin==2
    DialogTitle=varargin{2};
else
    DialogTitle=[];
end


CWD=getGUIData('CWD');

if isempty(CWD)
    [filename,pathname]=uiputfile(FilterSpec,DialogTitle);
else
    if nargin==3
        def=[CWD,varargin{3}];
    else
        def=CWD;
    end
    [filename,pathname]=uiputfile(FilterSpec,DialogTitle,def);
end

if pathname==0
    return
end
setGUIData('CWD',pathname);



end
