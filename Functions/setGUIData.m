function setGUIData(fieldname,value)
% function setGUIData(fieldname,value)
% Store Data in the 0 UserData field
% Charles James 2017
UserData=get(0,'UserData');
if (nargin==2)
    UserData.(fieldname)=value;
elseif nargin==1
    UserData.(inputname(1))=fieldname;
end
set(0,'UserData',UserData);
end

