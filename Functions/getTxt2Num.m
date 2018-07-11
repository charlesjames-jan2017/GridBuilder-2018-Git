function N=getTxt2Num(hObject)
% function N=getTxt2Num(hObject)
% retrieve a number stored in an object String field
% Charles James (2017)
try
   Nstr=hObject.String;
   if ~isempty(Nstr)
       try
           N=eval(Nstr);
       catch
           N=str2double(Nstr);
       end
   end
   if ~isnumeric(N)
       N=NaN;
   end
catch
    N=NaN;
end




end