function dataout=getGUIData(fieldname)
% function dataout=getGUIData(fieldname)
% extract data from the 0 UserData field
% Charles James 2017
UserData=get(0,'UserData');
if isfield(UserData,fieldname)
    dataout=UserData.(fieldname);
else
    dataout=[];
end