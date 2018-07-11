function [filename,pathname]=getGUIfilename(varargin)

FilterSpec=varargin{1};
if nargin==2
    DialogTitle=varargin{2};
else
    DialogTitle=[];
end
ind=find(strcmpi(varargin,'MultiSelect'));
if any(ind)
    selectmode=varargin{ind+1};
else
    selectmode='off';
end


CWD=getGUIData('CWD');

if isempty(CWD)
    [filename,pathname]=uigetfile(FilterSpec,DialogTitle,'MultiSelect',selectmode);
else
    [filename,pathname]=uigetfile(FilterSpec,DialogTitle,CWD,'MultiSelect',selectmode);
end

if pathname==0
    return
end
setGUIData('CWD',pathname);



end
