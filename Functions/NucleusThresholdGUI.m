function varargout = NucleusThresholdGUI(varargin)
% NUCLEUSTHRESHOLDGUI MATLAB code for NucleusThresholdGUI.fig
%      NUCLEUSTHRESHOLDGUI, by itself, creates a new NUCLEUSTHRESHOLDGUI or raises the existing
%      singleton*.
%
%      H = NUCLEUSTHRESHOLDGUI returns the handle to a new NUCLEUSTHRESHOLDGUI or the handle to
%      the existing singleton*.
%
%      NUCLEUSTHRESHOLDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NUCLEUSTHRESHOLDGUI.M with the given input arguments.
%
%      NUCLEUSTHRESHOLDGUI('Property','ThreshValue',...) creates a new NUCLEUSTHRESHOLDGUI or raises the
%      existing singleton*.  Starting from the left, property threshvalue pairs are
%      applied to the GUI before NucleusThresholdGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid threshvalue makes property application
%      stop.  All inputs are passed to NucleusThresholdGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NucleusThresholdGUI

% Last Modified by GUIDE v2.5 20-Mar-2020 18:04:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NucleusThresholdGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @NucleusThresholdGUI_OutputFcn, ...
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


% --- Executes just before NucleusThresholdGUI is made visible.
function NucleusThresholdGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NucleusThresholdGUI (see VARARGIN)

set(handles.NucleusThresholdGUI,'units','normalized','position',[0 1 0.95 0.7]);

im = evalin('base', 'img'); %'orig');
axes(handles.OrigImg);
imshow(max(im,[],3), []);

TryThis_Callback(hObject, eventdata, handles);
UpdateButton_Callback(hObject, eventdata, handles);

% Choose default command line output for NucleusThresholdGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NucleusThresholdGUI wait for user response (see UIRESUME)
% uiwait(handles.NucleusThresholdGUI);


% --- Outputs from this function are returned to the command line.
function varargout = NucleusThresholdGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in DecidedButton.
function DecidedButton_Callback(hObject, eventdata, handles)
% hObject    handle to DecidedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

assignin('base','ShowNucImg', getappdata(handles.NucleusThresholdGUI,'ShowImgs'));
assignin('base','NucNoiseIm', getappdata(handles.NucleusThresholdGUI,'NoiseIm'));
close(handles.NucleusThresholdGUI);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function NoiseSlider_Callback(hObject, eventdata, handles)
% hObject    handle to NoiseSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'ThreshValue') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
val=round(val);

set(handles.PixelValue,'String',val);
setappdata(handles.NucleusThresholdGUI,'noise',val); 



% --- Executes during object creation, after setting all properties.
function NoiseSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoiseSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in TryThis.
function TryThis_Callback(hObject, eventdata, handles)
% hObject    handle to TryThis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
adjust = getappdata(handles.NucleusThresholdGUI,'adjust');
if isempty(adjust)
    adjust = get(handles.ThreshSlider,'value');
end
assignin('base','nucAdjust', adjust);
adjust = evalin('base','nucAdjust');
zs = evalin('base','zs');
s = evalin('base','s');
img(:,:,:) = evalin('base','img');
%BinaryThresholdedImg=zeros(s(1),s(2),zs);
h = waitbar(0,'Calculating...');
% for i=1:zs %For each slice
%     waitbar (i/zs,h);
%     level=graythresh(img(:,:,i)); %Finds threshold level using Otsu's method. Different for each slice b/c no need to keep intensity conistent, just want to pick up all mg processes. Tried adaptive threshold, but did not produce better images.
%     level=level*adjust; %Increase the threshold by *1.6 to get all fine processes 
%     BinaryThresholdedImg(:,:,i) = im2bw(img(:,:,i),level);% Apply the adjusted threshold and convert from gray the black white image.
% end
level = graythresh(img) * adjust;
BinaryThresholdedImg = imbinarize(img, level);

axes(handles.ThreshImg);
imshow(max(BinaryThresholdedImg,[],3), []);

if isgraphics(h);
close(h);
end
setappdata(handles.NucleusThresholdGUI,'BinaryThresholdedImg',BinaryThresholdedImg);
assignin('base','NucBinaryThresholdedImg', getappdata(handles.NucleusThresholdGUI,'BinaryThresholdedImg'));


% --- Executes on button press in UpdateButton.
function UpdateButton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
adjust = getappdata(handles.NucleusThresholdGUI,'noise');
if isempty(adjust)
    adjust = get(handles.NoiseSlider,'value');
end
assignin('base','nucNoise', adjust);
BinaryIm(:,:,:) = evalin('base','NucBinaryThresholdedImg');
midslice = evalin('base','midslice');
noise = evalin('base','nucNoise');

h=msgbox('One moment please...');
NoiseIm=bwareaopen(BinaryIm,noise); %Removes objects smaller than set value (in pixels). For 3D inputs, uses automatic connectivity input of 26. Don't want small background dots left over from decreased threshold.
close(h);

NoiseIm2 = double(NoiseIm);
ConnectedNuclei = bwconncomp(NoiseIm2,26);
for i=1:ConnectedNuclei.NumObjects
    color = max(0.5, rand());
    NoiseIm2(ConnectedNuclei.PixelIdxList{i}) = color;
end

axes(handles.FilteredImg);
imshow(max(NoiseIm2,[],3), []);

setappdata(handles.NucleusThresholdGUI,'NoiseIm',NoiseIm);


% --- Executes on button press in HowManyObjects.
function HowManyObjects_Callback(~, eventdata, handles)
% hObject    handle to HowManyObjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base','NucNoiseIm', getappdata(handles.NucleusThresholdGUI,'NoiseIm'));
NoiseIm = evalin('base','NucNoiseIm');

h=msgbox('Counting...');
ConnectedComponents=bwconncomp(NoiseIm,26); %returns structure with 4 fields. PixelIdxList contains a 1-by-NumObjects cell array where the k-th element in the cell array is a vector containing the linear indices of the pixels in the k-th object. 26 defines connectivity. This looks at cube of connectivity around pixel.
close(h);

numObj = numel(ConnectedComponents.PixelIdxList); %PixelIdxList is field with list of pixels in each connected component. Find how many connected components there are.

set(handles.NumberOfObjects,'String',numObj);



% --- Executes on slider movement.
function ThreshSlider_Callback(hObject, eventdata, handles)
% hObject    handle to ThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'ThreshValue') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = get(hObject,'Value');
val=round(val,2);

im = evalin('base','img'); %'orig');
level=graythresh(im); %Finds threshold level using Otsu's method. Different for each slice b/c no need to keep intensity conistent, just want to pick up all mg processes. Tried adaptive threshold, but did not produce better images.
level=level*val;  
BinaryThresholdedImg = imbinarize((im),level);% Apply the adjusted threshold and convert from gray the black white image.

axes(handles.ThreshImg);
imshow(max(BinaryThresholdedImg,[],3), []);
set(handles.ThreshValue,'String',val);
setappdata(handles.NucleusThresholdGUI,'adjust',val);
setappdata(handles.NucleusThresholdGUI,'BinaryThresholdedImg',BinaryThresholdedImg);


% --- Executes during object creation, after setting all properties.
function ThreshSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
