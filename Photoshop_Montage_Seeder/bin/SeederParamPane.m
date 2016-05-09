function varargout = SeederParamPane(varargin)
% SEEDERPARAMPANE MATLAB code for SeederParamPane.fig
%      SEEDERPARAMPANE, by itself, creates a new SEEDERPARAMPANE or raises the existing
%      singleton*.
%
%      H = SEEDERPARAMPANE returns the handle to a new SEEDERPARAMPANE or the handle to
%      the existing singleton*.
%
%      SEEDERPARAMPANE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEEDERPARAMPANE.M with the given input arguments.
%
%      SEEDERPARAMPANE('Property','Value',...) creates a new SEEDERPARAMPANE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SeederParamPane_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SeederParamPane_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
%   This SeederParamPane is responsible for loading and setting the scales/ROI
%   locations for each montage. It returns a parameter struct that can be
%   used in the creation of a set of ROIs.
%
%     Copyright (C) 2014  Robert F Cooper
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Edit the above text to modify the response to help SeederParamPane

% Last Modified by GUIDE v2.5 13-Nov-2014 15:43:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SeederParamPane_OpeningFcn, ...
                   'gui_OutputFcn',  @SeederParamPane_OutputFcn, ...
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


% --- Executes just before SeederParamPane is made visible.
function SeederParamPane_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SeederParamPane (see VARARGIN)

% Choose default command line output for SeederParamPane
handles.output = hObject;

handles.param.basepath = pwd;
handles.param.seedpath = pwd;
scaletabledata = {};
substrdata     = { 'confocal' true; 'split_det' false; 'avg' false; '' false };

set(handles.scaletable,'data', scaletabledata);
set(handles.subsettable,'data', substrdata);

handles.param.substr = substrdata(1:end-1);
handles.param.cullimages    = 0;
handles.param.groupbyfov    = 1;
handles.param.groupbysubset = 1;
handles.param.groupbydomdir = get(handles.groupdomdir,'Value');
handles.param.eye           = 'od';
handles.param.axial         = str2double(strtrim(get(handles.axiallengthbox,'String') ));
handles.param.pixperdeg     = str2double(strtrim(get(handles.ppdbox,'String') ));
handles.param.minsize       = [0 0];
handles.param.limitimagesize = 0;

guidata(hObject, handles);
% UIWAIT makes SeederParamPane wait for user response (see UIRESUME)
uiwait(handles.seederpane);


% --- Outputs from this function are returned to the command line.
function varargout = SeederParamPane_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.param;

delete(hObject);


function enablepane(hObject,handles)

    % This section of the script allows one to enable the entire
    % frame.
    allhandles = fieldnames(handles);
    for i=1:length(allhandles)

        if ishandle(handles.(allhandles{i}))
            hoi = (handles.(allhandles{i}));
            
            if isfield(get(hoi),'Enable')
                set(hoi,'Enable','on');
            end
        end
    end

    guidata(hObject, handles);
    
    
function disablepane(hObject,handles)

    % This section of the script allows one to disable the entire
    % frame.
    allhandles = fieldnames(handles);
    for i=1:length(allhandles)

        if ishandle(handles.(allhandles{i}))
            hoi = (handles.(allhandles{i}));

            if isfield(get(hoi),'Enable')
                set(hoi,'Enable','off');
            end
        end
    end

    guidata(hObject, handles);
    

function eyepane_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in eyepane 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
lower( get(eventdata.NewValue,'String') )
handles.param.eye = lower( get(eventdata.NewValue,'String') );

guidata(hObject, handles);


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.param = 0;
guidata(hObject, handles);
uiresume(gcbf);


% --- Executes on button press in seedmontbutton.
function seedmontbutton_Callback(hObject, eventdata, handles)
% hObject    handle to seedmontbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Hint: delete(hObject) closes the figure

% Grab the final values in the exclusion boxes, if its checked.
if handles.param.limitimagesize
    handles.param.minsize = [str2double(get(handles.heightbox,'String')) str2double(get(handles.widthbox,'String'))];
else
    handles.param.minsize = [Inf Inf];
end


% Grab the final values in the axial length and pix/deg fields, preventing
% advancement if they aren't able to be converted to numbers...
contents = cellstr(get(handles.typescale,'String'));
selected = contents{get(handles.typescale,'Value')};

if strcmp(selected, 'Pix/Deg')
    scaletabledata = get(handles.scaletable,'data');    
    pixperdeg = scaletabledata{ cell2mat(scaletabledata(:,3)), 2};
    
elseif strcmp(selected, 'Relative')
    pixperdeg = str2double( get(handles.ppdbox,'String') );
end

if isnan( pixperdeg ) || pixperdeg == 0
   warndlg('The pixels per degree value is invalid! Enter a correct value to continue.'); 
   return;
else    
    handles.param.pixperdeg = pixperdeg;
end

get(handles.axiallengthbox,'String')
axial = str2double( strtrim( get(handles.axiallengthbox,'String')) );

if isnan( axial )
   warndlg('The axial length is invalid! Enter a correct value to continue.');
   return;
else    
    handles.param.axial = axial;
end

% Grab the prefix for the montage.
handles.param.montage_name = get(handles.prefixbox,'String');

% Grab the reference scale as well as the entire list of scales.
scaletabledata = get(handles.scaletable,'data');
handles.param.allscale = cell2mat(scaletabledata(:, 1:2));

% If its relative, find the scale of the 2nd column by multiplying the reciprocal of those
% values by whatever the pixels per degree is. If it isn't relative, then
% just take the values as input.
if strcmp(selected, 'Relative')
    relvals = 1./(handles.param.allscale(:,2)./100);
    handles.param.allscale(:,2) = pixperdeg.*relvals;
end

% If any of the scale regions are 0, then they weren't filled in and we
% can't progress.
if any( handles.param.allscale == 0 )
   warndlg('You must fill out the pixels per degree for each FOV!');
   return;
end

% Grab which of the substrings should be made visible by default.
tabledata = get(handles.subsettable,'data');
handles.param.visible = cell2mat(tabledata(:, 2));
handles.param.substr  = tabledata(1:end-1, 1);

imageLoader(handles.param);

uiresume(gcbf);


% --- Executes on button press in selectbasefolder.
function selectbasefolder_Callback(hObject, eventdata, handles)
% hObject    handle to selectbasefolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
basepath = uigetdir(handles.param.basepath, 'Select Image Folder');

if basepath ~= 0    
    handles.param.basepath = basepath;
    set(handles.loadSeedLocations,'Enable','on')
end

guidata(hObject, handles);


% --- Executes on button press in loadSeedLocations.
function loadSeedLocations_Callback(hObject, eventdata, handles)
% hObject    handle to loadSeedLocations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[seedlocFname seedpath] = uigetfile({'*.csv','CSV-files (*.csv)'},'Select the location/FOV file.',handles.param.seedpath);

if ~isequal(seedlocFname,0) && ~isequal(seedpath,0)
    
    handles.param.seedpath = seedpath;
    fid = fopen(fullfile(handles.param.seedpath,seedlocFname));
    handles.param.scandata = textscan(fid, '%s%f', 'Delimiter', ',');
    fclose(fid);

    % Determine the unique FOV
    fov = sort(unique(handles.param.scandata{2}));

    % Initialize the table with those FOV values
    scaletabledata = cell( length(fov), 3);

    for i=1: length(fov)
        scaletabledata{i,1} = fov(i);
        scaletabledata{i,2} = 0;
        if i==1
            scaletabledata{i,3} = true(1);
        else
            scaletabledata{i,3} = false(1);
        end
    end

    set(handles.scaletable, 'data', scaletabledata);
    set(handles.typescale, 'Enable', 'on');
    set(handles.scaletolabel, 'Enable', 'on');
    set(handles.scaletable, 'Enable', 'on');
    
    children = get(handles.axialpanel, 'Children');
    set(children, 'Enable', 'on');
    children = get(handles.pshopoutputpane, 'Children');
    set(children, 'Enable', 'on');
    children = get(handles.eyepane, 'Children');
    set(children, 'Enable', 'on');
    set(handles.excludeimage, 'Enable', 'on');
    
    set(handles.cullimages,'Enable','on');
    set(handles.seedmontbutton, 'Enable', 'on');
    set(handles.cancel, 'Enable', 'on');
    
    guidata(hObject, handles);
end

% --- Executes on selection change in typescale.
function typescale_Callback(hObject, eventdata, handles)
% hObject    handle to typescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns typescale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from typescale
contents = cellstr(get(hObject,'String'));
selected = contents{get(hObject,'Value')};

scaletabledata = get(handles.scaletable,'data');

if strcmp(selected, 'Pix/Deg')
    scaletabledata(:,2) = {0};
    set(handles.scaletable,'ColumnEditable',[false true true])
    set(handles.scaletable,'ColumnName',{'FOV', 'Pix/Deg', 'Reference'})
    set(handles.pixdegtext,'Visible','off')
    set(handles.ppdbox,'Visible','off')
elseif strcmp(selected, 'Relative')
    
    reference = scaletabledata{ cell2mat(scaletabledata(:,3)), 1};
    allfov    = cell2mat(scaletabledata(:, 1));
    
    for i=1:length(scaletabledata( :, 2))
        
        scaletabledata( i, 2) = { 100*(allfov(i)./reference) };
    end
    set(handles.scaletable,'ColumnEditable',[false false true])
    set(handles.scaletable,'ColumnName',{'FOV', 'Rel %', 'Reference'})
    set(handles.pixdegtext,'Visible','on')
    set(handles.ppdbox,'Visible','on')
end

set(handles.scaletable,'data',scaletabledata);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function typescale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to typescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in scaletable.
function scaletable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to scaletable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
idx = eventdata.Indices;

contents = cellstr(get(handles.typescale,'String'));
selected = contents{get(handles.typescale,'Value')};


if ~all(isempty(idx)) && idx(2) == 3
    scaletabledata = get(handles.scaletable,'data');
    
    scaletabledata(:,3) = {false(1)};
    
    scaletabledata(idx(1),3) = {true(1)};
    
    if strcmp(selected, 'Relative') %If we're set to relative scaling, adjust the values.
    
        reference = scaletabledata{ cell2mat(scaletabledata(:,3)), 1};
        allfov    = cell2mat(scaletabledata(:, 1));

        for i=1:length(scaletabledata( :, 2))
            scaletabledata( i, 2) = { 100*(allfov(i)./reference) };
        end
    end
    
    
    set(handles.scaletable,'data',scaletabledata);
end

guidata(hObject, handles);

% --- Executes on button press in cullimages.
function cullimages_Callback(hObject, eventdata, handles)
% hObject    handle to cullimages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cullimages
handles.param.cullimages = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17



function widthbox_Callback(hObject, eventdata, handles)
% hObject    handle to widthbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of widthbox as text
%        str2double(get(hObject,'String')) returns contents of widthbox as a double

newval = str2double(strtrim(get(hObject,'String')));

if ~isnan(newval)   
    handles.param.minsize(2) = newval;
else
    set(hObject,'String', num2str(handles.param.minsize(2)));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function widthbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to widthbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function heightbox_Callback(hObject, eventdata, handles)
% hObject    handle to heightbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of heightbox as text
%        str2double(get(hObject,'String')) returns contents of heightbox as a double
newval = str2double(strtrim(get(hObject,'String')));

if ~isnan(newval)   
    handles.param.minsize(1) = newval;
else
    set(hObject,'String', num2str(handles.param.minsize(1)));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function heightbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heightbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cullimagesbutton.
function cullimagesbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cullimagesbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in groupbyfov.
function groupbyfov_Callback(hObject, eventdata, handles)
% hObject    handle to groupbyfov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of groupbyfov
handles.param.groupbyfov = get(hObject,'Value');

if ~handles.param.groupbyfov
    set(handles.groupbysubset,'Value',0);
    set(handles.groupbysubset,'Enable','off');
end

guidata(hObject, handles);

% --- Executes on button press in groupbysubset.
function groupbysubset_Callback(hObject, eventdata, handles)
% hObject    handle to groupbysubset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of groupbysubset
handles.param.groupbysubset = get(hObject,'Value');

if handles.param.groupbysubset    
    set(handles.groupdomdir,'Enable','on');
else
    set(handles.groupdomdir,'Value',0);
    set(handles.groupdomdir,'Enable','off');
end

guidata(hObject, handles);

% --- Executes when entered data in editable cell(s) in subsettable.
function subsettable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to subsettable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

subsetdata = get(handles.subsettable,'data');
idx = eventdata.Indices;

subsetdata{idx(1),idx(2)} = eventdata.EditData;

% If the index is the last one, add a row, if the new data wasn't blank.

if idx(1) == size(subsetdata,1) && ~isempty(eventdata.EditData)
	subsetdata = [subsetdata; {''}];
end
% If the index was was empty, shrink the size of the array.
if isempty(eventdata.EditData)
   subsetdata = subsetdata([1:idx(1)-1 idx(1)+1:end],:); 
end

set(handles.subsettable,'data',subsetdata);

handles.param.substr = subsetdata(1:end-1);

guidata(hObject, handles);



function axiallengthbox_Callback(hObject, eventdata, handles)
% hObject    handle to axiallengthbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axiallengthbox as text
%        str2double(get(hObject,'String')) returns contents of axiallengthbox as a double

newval = str2double(strtrim(get(hObject,'String')));

if ~isnan(newval)   
    handles.param.axial = newval;
else
    set(hObject,'String', num2str(handles.param.axial));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function axiallengthbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axiallengthbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ppdbox_Callback(hObject, eventdata, handles)
% hObject    handle to ppdbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ppdbox as text
%        str2double(get(hObject,'String')) returns contents of ppdbox as a double

newval = str2double(strtrim(get(hObject,'String')));

if ~isnan(newval)   
    handles.param.pixperdeg = newval;
else
    set(hObject,'String', num2str(handles.param.pixperdeg));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ppdbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppdbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function prefixbox_Callback(hObject, eventdata, handles)
% hObject    handle to prefixbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefixbox as text
%        str2double(get(hObject,'String')) returns contents of prefixbox as a double


% --- Executes during object creation, after setting all properties.
function prefixbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefixbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in subsettable.
function subsettable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to subsettable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
idx = eventdata.Indices;

% Only allow one check box to be pressed at any time.
if ~all(isempty(idx)) && idx(2) == 2
    tabledata = get(handles.subsettable,'data');
    
    tabledata(:,2) = {false(1)};
    
    tabledata(idx(1),2) = {true(1)};    
    
    set(handles.subsettable,'data',tabledata);
end

guidata(hObject, handles);


% --- Executes on button press in excludeimage.
function excludeimage_Callback(hObject, eventdata, handles)
% hObject    handle to excludeimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of excludeimage
handles.param.limitimagesize = get(hObject,'Value');

if handles.param.limitimagesize
    set(handles.widthtext,'Enable','on')
    set(handles.xtext,'Enable','on')
    set(handles.heighttext,'Enable','on')
    set(handles.widthbox,'Enable','on')
    set(handles.heightbox,'Enable','on')
else
    set(handles.widthtext,'Enable','off')
    set(handles.xtext,'Enable','off')
    set(handles.heighttext,'Enable','off')
    set(handles.widthbox,'Enable','off')
    set(handles.heightbox,'Enable','off')    
end

guidata(hObject, handles);


% --- Executes on button press in groupdomdir.
function groupdomdir_Callback(hObject, eventdata, handles)
% hObject    handle to groupdomdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of groupdomdir
handles.param.groupbydomdir = get(hObject,'Value');

guidata(hObject, handles);


% --- Executes when user attempts to close seederpane.
function seederpane_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to seederpane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(gcbf);
