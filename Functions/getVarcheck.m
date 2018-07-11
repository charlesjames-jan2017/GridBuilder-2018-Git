function getVarcheck(varname,default_value)
% function getVarcheck(varname,default_value)
% checks calling workspace for existence of variable var
% if it is non-existent it creates it in gives it the value default_value
% if it exists but is empty it also assigns it the value default_value
% if it exists and has any other value it is not altered.
% useful for testing optional inputs into functions 
%
% Charles James 2012
if ~exist('default_value','var')
    default_value=[];
end

if (nargin<1)||~ischar(varname)
    return;
end

a=evalin('caller',['exist(''' varname ''',''var'');']);

if (a~=0)
    var=evalin('caller',varname);
    if isempty(var)
        var=default_value;
    end
else
    var=default_value;
end
assignin('caller',varname,var);

end