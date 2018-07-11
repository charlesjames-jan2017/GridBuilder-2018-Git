function varargout = GridBuilder(varargin)
% GRIDBUILDER MATLAB code for GridBuilder.fig
%      GRIDBUILDER, by itself, creates a new GRIDBUILDER or raises the existing
%      singleton*.
%
%      H = GRIDBUILDER returns the handle to a new GRIDBUILDER or the handle to
%      the existing singleton*.
%
%      GRIDBUILDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRIDBUILDER.M with the given input arguments.
%
%      GRIDBUILDER('Property','Value',...) creates a new GRIDBUILDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GridBuilder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GridBuilder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GridBuilder

% Last Modified by GUIDE v2.5 03-Jul-2018 10:31:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GridBuilder_OpeningFcn, ...
                   'gui_OutputFcn',  @GridBuilder_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GridBuilder is made visible.
function GridBuilder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GridBuilder (see VARARGIN)

% Choose default command line output for GridBuilder
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GridBuilder wait for user response (see UIRESUME)
% uiwait(handles.MainFigure);
% make gui reasonable size for screen
s=get(0,'ScreenSize');
hres=s(3);
vres=s(4);

hdef=floor(.75*hres);
vdef=floor(.75*vres);

x0=floor(hres/2-hdef/2);
y0=floor(vres/2-vdef/2);

handles.MainFigure.Position=[x0 y0 hdef vdef];
GridBuilderCallbacks('Initialize',eventdata,handles);



% --- Outputs from this function are returned to the command line.
function varargout = GridBuilder_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function MainAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MainAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate MainAxis
% --- Executes on mouse press over axes background.
function MainAxis_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MainAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function MainFigure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setGUIData('ButtonDown',true);
setGUIData('CurrentDownPoint',handles.MainAxis.CurrentPoint);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function MainFigure_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setGUIData('ButtonDown',false);
setGUIData('CurrentUpPoint',handles.MainAxis.CurrentPoint);

% --- Executes on mouse motion over figure - except title and menu.
function MainFigure_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on selection change in puCoord.

function puCoord_Callback(hObject, eventdata, handles)
% hObject    handle to puCoord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns puCoord contents as cell array
%        contents{get(hObject,'Value')} returns selected item from puCoord
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function puCoord_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puCoord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in puGtype.
function puGtype_Callback(hObject, eventdata, handles)
% hObject    handle to puGtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns puGtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from puGtype
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function puGtype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puGtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in rbCoast.
function rbCoast_Callback(hObject, eventdata, handles)
% hObject    handle to rbCoast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbCoast
GridBuilderCallbacks(hObject,eventdata,handles);

% --- Executes on button press in rbDepths.
function rbDepths_Callback(hObject, eventdata, handles)
% hObject    handle to rbDepths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbDepths
GridBuilderCallbacks(hObject,eventdata,handles);


function Nedit_Callback(hObject, eventdata, handles)
% hObject    handle to Nedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nedit as text
%        str2double(get(hObject,'String')) returns contents of Nedit as a double
GridBuilderCallbacks(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function Nedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Medit_Callback(hObject, eventdata, handles)
% hObject    handle to Medit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Medit as text
%        str2double(get(hObject,'String')) returns contents of Medit as a double
GridBuilderCallbacks(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function Medit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Medit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when selected object is changed in panMode0.
function panMode_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panMode0 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(handles.panMode0,eventdata,handles);

% --- Executes when selected object is changed in panGrid0.
function panGrid_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panGrid0 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(handles.panGrid0,eventdata,handles);
    

% --------------------------------------------------------------------
function mG_Callback(hObject, eventdata, handles)
% hObject    handle to mG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mSG_Load_Bath_Callback(hObject, eventdata, handles)
% hObject    handle to mSG_Load_Bath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles);

% --------------------------------------------------------------------
function mSG_Load_Coast_Callback(hObject, eventdata, handles)
% hObject    handle to mSG_Load_Coast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles);


% --------------------------------------------------------------------
function mSG_LoadSG_Callback(hObject, eventdata, handles)
% hObject    handle to mSG_LoadSG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles);


% --------------------------------------------------------------------
function mSG_Save_Grid_Callback(hObject, eventdata, handles)
% hObject    handle to mSG_Save_Grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles);


% --------------------------------------------------------------------
function mSG_Save_As_Callback(hObject, eventdata, handles)
% hObject    handle to mSG_Save_As (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles);


% --------------------------------------------------------------------
function mSG_Clear_Grid_Callback(hObject, eventdata, handles)
% hObject    handle to mSG_Clear_Grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles);


% --------------------------------------------------------------------
function tbSaveGrid_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tbSaveGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles);


% --------------------------------------------------------------------
function mLoad_Callback(hObject, eventdata, handles)
% hObject    handle to mLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbMask.
function rbMask_Callback(hObject, eventdata, handles)
% hObject    handle to rbMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbMask
GridBuilderCallbacks(hObject,eventdata,handles);


% --------------------------------------------------------------------
function tbReset_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tbReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on slider movement.
function sbRot_Callback(hObject, eventdata, handles)
% hObject    handle to sbRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes during object creation, after setting all properties.
function sbRot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sbRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editRot_Callback(hObject, eventdata, handles)
% hObject    handle to editRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRot as text
%        str2double(get(hObject,'String')) returns contents of editRot as a double
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function editRot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbTranslate0.
function rbTranslate0_Callback(hObject, eventdata, handles)
% hObject    handle to rbTranslate0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbTranslate0
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in rbBath.
function rbBath_Callback(hObject, eventdata, handles)
% hObject    handle to rbBath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbBath
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mExport_Callback(hObject, eventdata, handles)
% hObject    handle to mExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function mImport_Callback(hObject, eventdata, handles)
% hObject    handle to mImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mImROMS_Callback(hObject, eventdata, handles)
% hObject    handle to mImROMS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)

% --------------------------------------------------------------------
function mExROMS_Callback(hObject, eventdata, handles)
% hObject    handle to mExROMS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)

% --------------------------------------------------------------------
function mExSWAN_Callback(hObject, eventdata, handles)
% hObject    handle to mExSWAN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbZoomIn_OnCallback(hObject, eventdata, handles)
% hObject    handle to tbZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbZoomIn_OffCallback(hObject, eventdata, handles)
% hObject    handle to tbZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbZoomOut_OffCallback(hObject, eventdata, handles)
% hObject    handle to tbZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbZoomOut_OnCallback(hObject, eventdata, handles)
% hObject    handle to tbZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbUndo_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tbUndo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbRedo_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tbRedo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in rbOrthog.
function rbOrthog_Callback(hObject, eventdata, handles)
% hObject    handle to rbOrthog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in pbClearMask.
function pbClearMask_Callback(hObject, eventdata, handles)
% hObject    handle to pbClearMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in pbResetMask.
function pbResetMask_Callback(hObject, eventdata, handles)
% hObject    handle to pbResetMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes when selected object is changed in panMaskEdit.
function panMaskEdit_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panMaskEdit 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbGrid.
function rbGrid_Callback(hObject, eventdata, handles)
% hObject    handle to rbGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in pbRotFinish.
function pbRotFinish_Callback(hObject, eventdata, handles)
% hObject    handle to pbRotFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in cbUserCoast.
function cbUserCoast_Callback(hObject, eventdata, handles)
% hObject    handle to cbUserCoast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbUserCoast
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in cbUserBath.
function cbUserBath_Callback(hObject, eventdata, handles)
% hObject    handle to cbUserBath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbUserBath
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbPan_OffCallback(hObject, eventdata, handles)
% hObject    handle to tbPan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbPan_OnCallback(hObject, eventdata, handles)
% hObject    handle to tbPan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in pbResDone.
function pbResDone_Callback(hObject, eventdata, handles)
% hObject    handle to pbResDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)



function minDepthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to minDepthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minDepthEdit as text
%        str2double(get(hObject,'String')) returns contents of minDepthEdit as a double
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes during object creation, after setting all properties.
function minDepthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minDepthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxDepthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxDepthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxDepthEdit as text
%        str2double(get(hObject,'String')) returns contents of maxDepthEdit as a double
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes during object creation, after setting all properties.
function maxDepthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxDepthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMinCaxis_Callback(hObject, eventdata, handles)
% hObject    handle to editMinCaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMinCaxis as text
%        str2double(get(hObject,'String')) returns contents of editMinCaxis as a double
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function editMinCaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMinCaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMaxCaxis_Callback(hObject, eventdata, handles)
% hObject    handle to editMaxCaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaxCaxis as text
%        str2double(get(hObject,'String')) returns contents of editMaxCaxis as a double
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function editMaxCaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaxCaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbAutoCaxis.
function pbAutoCaxis_Callback(hObject, eventdata, handles)
% hObject    handle to pbAutoCaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function selectZone_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to selectZone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes when user attempts to close MainFigure.
function MainFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
k=get(0,'Children');
imains=strcmp({k.Tag},'MainFigure');
delete(k(imains));



% --- Executes on button press in pbClearCP0.
function pbClearCP0_Callback(hObject, eventdata, handles)
% hObject    handle to pbClearCP0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbAbout_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tbAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mClear_Callback(hObject, eventdata, handles)
% hObject    handle to mClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mClearCoast_Callback(hObject, eventdata, handles)
% hObject    handle to mClearCoast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)

% --------------------------------------------------------------------
function mClearDepths_Callback(hObject, eventdata, handles)
% hObject    handle to mClearDepths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)

% --------------------------------------------------------------------
function mClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to mClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mmEdit_Callback(hObject, eventdata, handles)
% hObject    handle to mmEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mUndo_Callback(hObject, eventdata, handles)
% hObject    handle to mUndo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mRedo_Callback(hObject, eventdata, handles)
% hObject    handle to mRedo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mExit_Callback(hObject, eventdata, handles)
% hObject    handle to mExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)clearUserData;
k=get(0,'Children');
imains=strcmp({k.Tag},'MainFigure');
delete(k(imains));


% --------------------------------------------------------------------
function mView_Callback(hObject, eventdata, handles)
% hObject    handle to mView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function mMaskRes_Callback(hObject, eventdata, handles)
% hObject    handle to mMaskRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function mFullRes_Callback(hObject, eventdata, handles)
% hObject    handle to mFullRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setGUIData('maskres',5);
GridBuilderCallbacks(hObject,eventdata,handles)

% --------------------------------------------------------------------
function mHighRes_Callback(hObject, eventdata, handles)
% hObject    handle to mHighRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setGUIData('maskres',4);
GridBuilderCallbacks(hObject,eventdata,handles)

% --------------------------------------------------------------------
function mIntRes_Callback(hObject, eventdata, handles)
% hObject    handle to mIntRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setGUIData('maskres',3);
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mLowRes_Callback(hObject, eventdata, handles)
% hObject    handle to mLowRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setGUIData('maskres',2);
GridBuilderCallbacks(hObject,eventdata,handles)

% --------------------------------------------------------------------
function mCoarseRes_Callback(hObject, eventdata, handles)
% hObject    handle to mCoarseRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setGUIData('maskres',1);
GridBuilderCallbacks(hObject,eventdata,handles)
% --------------------------------------------------------------------
function mAutoRes_Callback(hObject, eventdata, handles)
% hObject    handle to mCoarseRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setGUIData('maskres',0);
GridBuilderCallbacks(hObject,eventdata,handles)

% --------------------------------------------------------------------
function tbZoomMan_OffCallback(hObject, eventdata, handles)
% hObject    handle to tbZoomMan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)

% --------------------------------------------------------------------
function tbZoomMan_OnCallback(hObject, eventdata, handles)
% hObject    handle to tbZoomMan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbZoomMan_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tbZoomMan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbZoomOutMan_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tbZoomOutMan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbOverlay_OnCallback(hObject, eventdata, handles)
% hObject    handle to tbOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbOverlay_OffCallback(hObject, eventdata, handles)
% hObject    handle to tbOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mRefPoints_Callback(hObject, eventdata, handles)
% hObject    handle to mRefPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function tbSubGrid_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tbSubGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on selection change in puFiltOrder.
function puFiltOrder_Callback(hObject, eventdata, handles)
% hObject    handle to puFiltOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns puFiltOrder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from puFiltOrder


% --- Executes during object creation, after setting all properties.
function puFiltOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puFiltOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function txtR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pbSmoothDepth.
function pbSmoothDepth_Callback(hObject, eventdata, handles)
% hObject    handle to pbSmoothDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on selection change in puFilterType.
function puFilterType_Callback(hObject, eventdata, handles)
% hObject    handle to puFilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns puFilterType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from puFilterType
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes during object creation, after setting all properties.
function puFilterType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puFilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in rbRx0.
function rbRx0_Callback(hObject, eventdata, handles)
% hObject    handle to rbRx0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbRx0
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in pbFilterDepths.
function pbFilterDepths_Callback(hObject, eventdata, handles)
% hObject    handle to pbFilterDepths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in pbSetDepths.
function pbSetDepths_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetDepths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in pbResetDepths.
function pbResetDepths_Callback(hObject, eventdata, handles)
% hObject    handle to pbResetDepths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in pbFillSelectedMask.
function pbFillSelectedMask_Callback(hObject, eventdata, handles)
% hObject    handle to pbFillSelectedMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function puSelectMask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puSelectMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end% --- Executes on button press in pbFillSelectedMask.

function puSelectMask_Callback(hObject, eventdata, handles)
% hObject    handle to pbFillSelectedMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mMaskTopo_Callback(hObject, eventdata, handles)
% hObject    handle to mMaskTopo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mMaskGSHHG_Callback(hObject, eventdata, handles)
% hObject    handle to mMaskGSHHG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)



function edTargetRx0_Callback(hObject, eventdata, handles)
% hObject    handle to edTargetRx0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edTargetRx0 as text
%        str2double(get(hObject,'String')) returns contents of edTargetRx0 as a double
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes during object creation, after setting all properties.
function edTargetRx0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edTargetRx0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in puVertType.
function puVertType_Callback(hObject, eventdata, handles)
% hObject    handle to puVertType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns puVertType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from puVertType
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function puVertType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puVertType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in puVtrans.
function puVtrans_Callback(hObject, eventdata, handles)
% hObject    handle to puVtrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns puVtrans contents as cell array
%        contents{get(hObject,'Value')} returns selected item from puVtrans
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes during object creation, after setting all properties.
function puVtrans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puVtrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in puVstretch.
function puVstretch_Callback(hObject, eventdata, handles)
% hObject    handle to puVstretch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns puVstretch contents as cell array
%        contents{get(hObject,'Value')} returns selected item from puVstretch
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes during object creation, after setting all properties.
function puVstretch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puVstretch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edTcline_Callback(hObject, eventdata, handles)
% hObject    handle to edTcline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edTcline as text
%        str2double(get(hObject,'String')) returns contents of edTcline as a double
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes during object creation, after setting all properties.
function edTcline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edTcline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edThetaB_Callback(hObject, eventdata, handles)
% hObject    handle to edThetaB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edThetaB as text
%        str2double(get(hObject,'String')) returns contents of edThetaB as a double
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function edThetaB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edThetaB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edThetaS_Callback(hObject, eventdata, handles)
% hObject    handle to edThetaS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edThetaS as text
%        str2double(get(hObject,'String')) returns contents of edThetaS as a double
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function edThetaS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edThetaS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbRx1.
function rbRx1_Callback(hObject, eventdata, handles)
% hObject    handle to rbRx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbRx1
GridBuilderCallbacks(hObject,eventdata,handles)


function edZlev_Callback(hObject, eventdata, handles)
% hObject    handle to edZlev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edZlev as text
%        str2double(get(hObject,'String')) returns contents of edZlev as a double
GridBuilderCallbacks(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function edZlev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edZlev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbDisplayR.
function cbDisplayR_Callback(hObject, eventdata, handles)
% hObject    handle to cbDisplayR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbDisplayR


% --- Executes when selected object is changed in panMode.
function panMode_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panMode 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(handles.panMode,eventdata,handles)


% --- Executes when selected object is changed in panMode0.
function panMode0_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panMode0 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in panGrid.
function panGrid_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panGrid 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(handles.panGrid,eventdata,handles)

% --- Executes on button press in pbClearCP.
function pbClearCP_Callback(hObject, eventdata, handles)
% hObject    handle to pbClearCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in rbExpand.
function rbExpand_Callback(hObject, eventdata, handles)
% hObject    handle to rbExpand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbExpand
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mMaskUser_Callback(hObject, eventdata, handles)
% hObject    handle to mMaskUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes when MainFigure is resized.
function MainFigure_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)


% --- Executes on button press in rbUserCoast.
function rbUserCoast_Callback(hObject, eventdata, handles)
% hObject    handle to rbUserCoast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbUserCoast
GridBuilderCallbacks(hObject,eventdata,handles)


% --------------------------------------------------------------------
function mHelp_Callback(hObject, eventdata, handles)
% hObject    handle to mHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mAbout_Callback(hObject, eventdata, handles)
% hObject    handle to mAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)

% --------------------------------------------------------------------
function mDoc_Callback(hObject, eventdata, handles)
% hObject    handle to mDoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GridBuilderCallbacks(hObject,eventdata,handles)
