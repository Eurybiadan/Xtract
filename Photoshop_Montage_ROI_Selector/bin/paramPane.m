function varargout = paramPane(varargin)
% PARAMPANE MATLAB code for paramPane.fig
%      PARAMPANE, by itself, creates a new PARAMPANE or raises the existing
%      singleton*.
%
%      H = PARAMPANE returns the handle to a new PARAMPANE or the handle to
%      the existing singleton*.
%
%      PARAMPANE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAMPANE.M with the given input arguments.
%
%      PARAMPANE('Property','Value',...) creates a new PARAMPANE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before paramPane_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to paramPane_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
%   This paramPane is responsible for loading and setting the scales/ROI
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

% Edit the above text to modify the response to help paramPane

% Last Modified by GUIDE v2.5 27-May-2015 16:27:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @paramPane_OpeningFcn, ...
                   'gui_OutputFcn',  @paramPane_OutputFcn, ...
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


% --- Executes just before paramPane is made visible.
function paramPane_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to paramPane (see VARARGIN)

% Choose default command line output for paramPane
handles.output = hObject;

%Initialize our roigenerator structs
handles.stripgen = struct('type','Strips','westroiloc', str2num(get(handles.westroilocbox,'String')), ...
                                          'northroiloc', str2num(get(handles.northroilocbox,'String')), ...
                                          'eastroiloc', str2num(get(handles.eastroilocbox,'String')), ...
                                          'southroiloc', str2num(get(handles.southroilocbox,'String')), ...
                                          'linkedroistrip',0,'locunits', 'degrees', 'SNIT', uint8(0));
handles.gridgen  = struct('type','Grid','locunits','degrees','gridwidth', 3, 'gridheight', 3,'gridrowsamp', 1, 'gridcolsamp', 1, 'anchor','C');
        
handles.centergen  = struct('type','Center','locunits','degrees');

handles.importgen = struct('type','Import','locunits','','locations',[]);

if ~isempty(varargin) && any(strcmp(varargin,'Parameters'))
    
    handles.param = varargin{find(strcmp(varargin,'Parameters'))+1};
    
    % Intialize the window based on the input parameters
    set(handles.eye,'SelectedObject', findobj('Tag',handles.param.eye));
    set(handles.axialbox,'String',    num2str( handles.param.axial ) );
    set(handles.pixpdegbox,'String',  num2str( handles.param.pixperdeg ) );
    set(handles.roisize,'String',     num2str( handles.param.roiboxsize ) );

    switch (handles.param.gen.type)
        case 'Strips'
            set(handles.importpanel,'Visible','off');
            set(handles.strippanel,'Visible','on');
            set(handles.gridpanel,'Visible','off');
            
            % Update the fields based on our input parameters
            handles.stripgen = handles.param.gen;
            
            set(handles.westroilocbox,'String', num2str( handles.stripgen.westroiloc, '%1.2f,' ) );
            
            [match matchind] = max(cellfun(@(cellname) ~isempty(regexp(handles.stripgen.locunits,deblank(cellname))),...
                           cellstr(get(handles.gridlocunitspopup,'String')) ));
            set(handles.gridlocunitspopup, 'Value',matchind);
                        
            % SNIT
            set(handles.superior,'Value',    bitget(handles.stripgen.SNIT,4));
            set(handles.nasalortemp,'Value', bitget(handles.stripgen.SNIT,1));
            set(handles.tempornasal,'Value', bitget(handles.stripgen.SNIT,3));
            set(handles.inferior,'Value',    bitget(handles.stripgen.SNIT,2));
            
            if strcmp(handles.param.eye,'os')
                set(handles.tempornasallabel,'String','Temporal');
                set(handles.nasalortemplabel,'String','Nasal');
            elseif strcmp(handles.param.eye,'od')
                set(handles.tempornasallabel,'String','Nasal');
                set(handles.nasalortemplabel,'String','Temporal');
            end
            set(handles.locunitspopup,'Enable','on');
        case 'Grid'
            set(handles.importpanel,'Visible','off');
            set(handles.strippanel,'Visible','off');
            set(handles.gridpanel,'Visible','on');
            % Update the fields based on our input parameters
            handles.gridgen = handles.param.gen;
            
            set(handles.gridwidthbox,'String',  num2str(handles.gridgen.gridwidth) );
            set(handles.gridheightbox,'String', num2str(handles.gridgen.gridheight) );
            set(handles.gridwidthsampbox,'String',  num2str(handles.gridgen.gridrowsamp) );
            set(handles.gridheightsampbox,'String', num2str(handles.gridgen.gridcolsamp) );
            
            set(handles.gridanchorgroup,'SelectedObject', findobj('Tag',handles.gridgen.anchor));
            set(handles.locunitspopup,'Enable','on');
        case 'Radial'
            set(handles.importpanel,'Visible','off');
            set(handles.strippanel,'Visible','off');
            set(handles.gridpanel,'Visible','off');
            set(handles.locunitspopup,'Enable','on');
        case 'Center'
            set(handles.importpanel,'Visible','off');
            set(handles.strippanel,'Visible','off');
            set(handles.gridpanel,'Visible','off');
            set(handles.locunitspopup,'Enable','on');
        case 'Import'
            set(handles.importpanel,'Visible','on');
            set(handles.strippanel,'Visible','off');
            set(handles.gridpanel,'Visible','off');
            set(handles.locunitspopup,'Enable','off');
    end
    
    
    
    [match matchind] = max(cellfun(@(cellname) ~isempty(regexp(handles.param.boxunits,deblank(cellname))),...
                           cellstr(get(handles.boxunitspopup,'String')) ));
    set(handles.boxunitspopup, 'Value',matchind);

    
    enablepane(hObject,handles);
else

    set(handles.importpanel,'Visible','off');
    set(handles.strippanel,'Visible','on');
    set(handles.gridpanel,'Visible','off');
    
    handles.param = struct('eye', 'od','axial', 0,'pixperdeg',0,'roitype','Fixed','roiboxsize',55, 'boxunits', 'microns',...
                           'gen',handles.stripgen,'layer_bounds', 0, 'rsetfname','');
    handles.psdAbsolutePath = [];
end

if ~isempty(varargin) && any(strcmp(varargin,'PSDPath'))
    handles.psdAbsolutePath = varargin{find(strcmp(varargin,'PSDPath'))+1};
    
    disp(['PSD Absolute path:' num2str(handles.psdAbsolutePath)]);
    
    % Get the figure that this is based on
    jmFigure = get(handle(gcf),'JavaFrame');
    jmWindow = jmFigure.getFigurePanelContainer;
    jmWindow.setEnabled(false);

    [handles.param.rsetfname handles.param.layer_bounds handles.param.layer_names handles.param.numungrp] = loadAndProcPSD(handles.psdAbsolutePath);

    if (handles.param.rsetfname ~= 0) && ...
       (handles.param.layer_bounds ~= 0) && ...
       (handles.param.layer_names ~= 0)
       
        jmWindow.setEnabled(true);

        set(handles.axialbox,'Enable','on');
        set(handles.axlabel,'Enable','on');
        set(handles.pixlabel,'Enable','on');
        set(handles.pixpdegbox,'Enable','on');
        set(handles.loadpsd,'Enable','off');
    end
end

if ~isempty(varargin) && any(strcmp(varargin,'Adjust'))
    if strcmp(varargin{find(strcmp(varargin,'Adjust'))+1},'on')
        set(handles.create,'String', 'Update!');
        set(handles.loadpsd,'Visible', 'off');
    end
end



guidata(hObject, handles);
% UIWAIT makes paramPane wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = paramPane_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% handles.param.westroiloc = deg_um_to_pixel( handles.param, handles.param.locunits , str2num(get(handles.westroilocbox,'String')) );
switch (handles.param.gen.type)
    case 'Strips'
        handles.param.gen = handles.stripgen;
    case 'Grid'
        handles.param.gen = handles.gridgen;
    case 'Radial'

    case 'Center'
        handles.param.gen = handles.centergen;
    case 'Import'        
        if isfield(handles,'locfile')
            [handles.importgen.locations, units] = extract_roi_locations( handles.locfile(2:3), handles.param.eye );
            
            if size(handles.locfile,2) == 4
                if all(handles.locfile{4} ~= 0)
                    handles.importgen.roi_ind = handles.locfile{4};
                else
                    handles.importgen.roi_ind = 1:length(handles.importgen.locations);
                end
            else
                handles.importgen.roi_ind = 1:length(handles.importgen.locations);
            end
            
            if strcmp(units,'deg')
                handles.importgen.locunits = 'degrees';
            elseif strcmp(units,'um')
                handles.importgen.locunits = 'microns';
            end
        end
        
        handles.param.gen = handles.importgen;
end

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
    
    
% --- Executes on button press in loadpsd.
function loadpsd_Callback(hObject, eventdata, handles)
% hObject    handle to loadpsd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname path] = uigetfile('*.psd','Select photoshop file');
handles.psdAbsolutePath = fullfile(path,fname);

if ~isequal(fname,0) || ~isequal(path,0)

    % Get the figure that this is based on
    jmFigure = get(handle(gcf),'JavaFrame');
    jmWindow = jmFigure.getFigurePanelContainer;
    jmWindow.setEnabled(false);

    [handles.param.rsetfname handles.param.layer_bounds handles.param.layer_names handles.param.numungrp] = loadAndProcPSD(handles.psdAbsolutePath);

    if ~isempty(handles.param.rsetfname) && ...
       ~isempty(handles.param.layer_bounds) && ...
       ~isempty(handles.param.layer_names)
   
        jmWindow.setEnabled(true);

        set(handles.axialbox,'Enable','on');
        set(handles.axlabel,'Enable','on');
        set(handles.pixlabel,'Enable','on');
        set(handles.pixpdegbox,'Enable','on');

    end
    guidata(hObject, handles);
end


function axialbox_Callback(hObject, eventdata, handles)
% hObject    handle to axialbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axnum = str2double(get(hObject,'String'));

if ~isnan(axnum)
    handles.param.axial = axnum;
else
    set(hObject,'String',''); 
end

% If both of these are defined, enable the entire pane.
if (handles.param.axial ~= 0) && (handles.param.pixperdeg ~=0)
    enablepane(hObject,handles);
%     handles.param.roiboxsize = deg_um_to_pixel( handles.param, 'microns', handles.param.roiboxsize );
% else
%     disablepane(hObject,handles);
end
    
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function axialbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axialbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pixpdegbox_Callback(hObject, eventdata, handles)
% hObject    handle to pixpdegbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pixpdegnum = str2double(get(hObject,'String'));

if ~isnan(pixpdegnum)
    handles.param.pixperdeg = pixpdegnum;
else
    set(hObject,'String',''); 
end

if (handles.param.axial ~= 0) && (handles.param.pixperdeg ~=0)
    enablepane(hObject,handles);
%     handles.param.roiboxsize = deg_um_to_pixel( handles.param, 'microns', handles.param.roiboxsize );
% else
%     disablepane(hObject,handles);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pixpdegbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixpdegbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function westroilocbox_Callback(hObject, eventdata, handles)
% hObject    handle to westroilocbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[westroiloc ok]= str2num(get(hObject,'String'));

if ok    
    if handles.stripgen.linkedroistrip == 1
        handles.stripgen.northroiloc = westroiloc;
        handles.stripgen.eastroiloc = westroiloc;
        handles.stripgen.southroiloc = westroiloc;
        handles.stripgen.westroiloc = westroiloc;
        
        set(handles.southroilocbox,'String', get(hObject,'String'));
        set(handles.northroilocbox,'String', get(hObject,'String'));
        set(handles.eastroilocbox,'String', get(hObject,'String'));
    else
        handles.stripgen.westroiloc = westroiloc;
    end
else
    set(hObject,'String',''); 
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function westroilocbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to westroilocbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in boxunitspopup.
function boxunitspopup_Callback(hObject, eventdata, handles)
% hObject    handle to boxunitspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
contents{get(hObject,'Value')};
handles.param.boxunits = deblank(contents{get(hObject,'Value')});
% handles.param.roiboxsize = deg_um_to_pixel( handles.param, handles.param.boxunits , str2double(get(handles.roisize,'String')) );

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function boxunitspopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxunitspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function roisize_Callback(hObject, eventdata, handles)
% hObject    handle to roisize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

roisize = str2double(get(hObject,'String'));

if ~isnan(roisize)
    handles.param.roiboxsize = roisize;%deg_um_to_pixel( handles.param, handles.param.boxunits , roisize );
else
    set(hObject,'String',''); 
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function roisize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roisize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in superior.
function superior_Callback(hObject, eventdata, handles)
% hObject    handle to superior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    handles.stripgen.SNIT = bitset(handles.stripgen.SNIT,4);
    set(handles.superiorlabel,'Enable','on');
    set(handles.northroilocbox,'Enable','on');
else
    set(handles.superiorlabel,'Enable','off');
    set(handles.northroilocbox,'Enable','off');    
    handles.stripgen.SNIT = bitset(handles.stripgen.SNIT,4,0);
end

guidata(hObject, handles);


% --- Executes on button press in inferior.
function inferior_Callback(hObject, eventdata, handles)
% hObject    handle to inferior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    handles.stripgen.SNIT = bitset(handles.stripgen.SNIT,2);
    set(handles.inferiorlabel,'Enable','on');
    set(handles.southroilocbox,'Enable','on');
else
    set(handles.inferiorlabel,'Enable','off');
    set(handles.southroilocbox,'Enable','off');
    handles.stripgen.SNIT = bitset(handles.stripgen.SNIT,2,0);
end
guidata(hObject, handles);


% --- Executes on button press in nasalortemp.
function nasalortemp_Callback(hObject, eventdata, handles)
% hObject    handle to nasalortemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    handles.stripgen.SNIT = bitset(handles.stripgen.SNIT,1);
    set(handles.nasalortemplabel,'Enable','on');
    set(handles.westroilocbox,'Enable','on');
else
    set(handles.nasalortemplabel,'Enable','off');
    set(handles.westroilocbox,'Enable','off');
    handles.stripgen.SNIT = bitset(handles.stripgen.SNIT,1,0);
end
guidata(hObject, handles);


% --- Executes on button press in tempornasal.
function tempornasal_Callback(hObject, eventdata, handles)
% hObject    handle to tempornasal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    handles.stripgen.SNIT = bitset(handles.stripgen.SNIT,3);
    set(handles.tempornasallabel,'Enable','on');
    set(handles.eastroilocbox,'Enable','on');
else
    set(handles.tempornasallabel,'Enable','off');
    set(handles.eastroilocbox,'Enable','off');
    handles.stripgen.SNIT = bitset(handles.stripgen.SNIT,3,0);
end
guidata(hObject, handles);


function eye_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in eye 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'os'
        set(handles.tempornasallabel,'String','Temporal Locations');
        set(handles.nasalortemplabel,'String','Nasal Locations'); 
        set(handles.gridnasalortemplabel,'String','Temporal'); 
        set(handles.gridtempornasallabel,'String','Nasal ');
               
        
        handles.param.eye = 'os';
    case 'od'
        set(handles.tempornasallabel,'String','Nasal Locations');
        set(handles.nasalortemplabel,'String','Temporal Locations');
        set(handles.gridnasalortemplabel,'String','Nasal');
        set(handles.gridtempornasallabel,'String','Temporal ');
        
        
        handles.param.eye = 'od';
    otherwise
        % Code for when there is no match.
end

guidata(hObject, handles);


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.param = 0;
guidata(hObject, handles);
uiresume(gcbf);


% --- Executes on button press in create.
function create_Callback(hObject, eventdata, handles)
% hObject    handle to create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Hint: delete(hObject) closes the figure

% montage_roi_selection( handles.param );


uiresume(gcbf);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(hObject);


% --- Executes on selection change in genType.
function genType_Callback(hObject, eventdata, handles)
% hObject    handle to genType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns genType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from genType

contents = cellstr(get(hObject,'String'));
% Update the generator type with our new type, and switch the visible
% panel.
handles.param.gen.type = contents{get(hObject,'Value')};

switch (handles.param.gen.type)
    case 'Strips'
        set(handles.importpanel,'Visible','off');
        set(handles.strippanel,'Visible','on');
        set(handles.gridpanel,'Visible','off');
        set(handles.locunitspopup,'Enable','on');
        handles.param.gen = handles.stripgen;
    case 'Grid'
        set(handles.importpanel,'Visible','off');
        set(handles.strippanel,'Visible','off');
        set(handles.gridpanel,'Visible','on');
        set(handles.locunitspopup,'Enable','on');
        handles.param.gen = handles.gridgen;
    case 'Import'
        set(handles.importpanel,'Visible','on');
        set(handles.strippanel,'Visible','off');
        set(handles.gridpanel,'Visible','off');
        set(handles.locunitspopup,'Enable','off');
        handles.param.gen = handles.importgen;
    case 'Center'
        set(handles.importpanel,'Visible','off');
        set(handles.strippanel,'Visible','off');
        set(handles.gridpanel,'Visible','off');
        set(handles.locunitspopup,'Enable','on');
        handles.param.gen = handles.centergen;
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function genType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to genType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gridheightbox_Callback(hObject, eventdata, handles)
% hObject    handle to gridheightbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gridheightbox as text
%        str2double(get(hObject,'String')) returns contents of gridheightbox as a double

gridheight = str2double(get(hObject,'String'));

if ~isnan(gridheight)
    handles.gridgen.gridheight = gridheight;
else
    set(hObject,'String',''); 
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function gridheightbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridheightbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gridwidthbox_Callback(hObject, eventdata, handles)
% hObject    handle to gridwidthbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gridwidthbox as text
%        str2double(get(hObject,'String')) returns contents of gridwidthbox as a double
gridwidth = str2double(get(hObject,'String'));

if ~isnan(gridwidth)
    handles.gridgen.gridwidth = gridwidth;
else
    set(hObject,'String',''); 
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function gridwidthbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridwidthbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in gridanchorgroup.
function gridanchorgroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in gridanchorgroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

handles.gridgen.anchor = get(eventdata.NewValue,'Tag');    

guidata(hObject, handles);



function gridheightsampbox_Callback(hObject, eventdata, handles)
% hObject    handle to gridheightsampbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gridheightsampbox as text
%        str2double(get(hObject,'String')) returns contents of gridheightsampbox as a double
gridheightsampling = str2double(get(hObject,'String'));

if ~isnan(gridheightsampling)
    handles.gridgen.gridrowsamp = gridheightsampling;
else
    set(hObject,'String',''); 
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function gridheightsampbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridheightsampbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gridwidthsampbox_Callback(hObject, eventdata, handles)
% hObject    handle to gridwidthsampbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gridwidthsampbox as text
%        str2double(get(hObject,'String')) returns contents of gridwidthsampbox as a double
gridwidthsampling = str2double(get(hObject,'String'));

if ~isnan(gridwidthsampling)
    handles.gridgen.gridcolsamp = gridwidthsampling;
else
    set(hObject,'String',''); 
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function gridwidthsampbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridwidthsampbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in locunitspopup.
function locunitspopup_Callback(hObject, eventdata, handles)
% hObject    handle to locunitspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns locunitspopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from locunitspopup
contents = cellstr(get(hObject,'String'));

locunits = deblank(contents{get(hObject,'Value')});

handles.gridgen.locunits   = locunits;
handles.stripgen.locunits  = locunits;
handles.centergen.locunits = locunits;
% handles.importgen.locunits = locunits;

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function locunitspopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to locunitspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function northroilocbox_Callback(hObject, eventdata, handles)
% hObject    handle to northroilocbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of northroilocbox as text
%        str2double(get(hObject,'String')) returns contents of northroilocbox as a double
[northroiloc ok]= str2num(get(hObject,'String'));

if ok
    if handles.stripgen.linkedroistrip == 1
        handles.stripgen.northroiloc = northroiloc;
        handles.stripgen.eastroiloc = northroiloc;
        handles.stripgen.southroiloc = northroiloc;
        handles.stripgen.westroiloc = northroiloc;
        
        set(handles.southroilocbox,'String', get(hObject,'String'));
        set(handles.westroilocbox,'String', get(hObject,'String'));
        set(handles.eastroilocbox,'String', get(hObject,'String'));
    else
        handles.stripgen.northroiloc = northroiloc;
    end
else
    set(hObject,'String',''); 
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function northroilocbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to northroilocbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function southroilocbox_Callback(hObject, eventdata, handles)
% hObject    handle to southroilocbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of southroilocbox as text
%        str2double(get(hObject,'String')) returns contents of southroilocbox as a double
[southroiloc ok]= str2num(get(hObject,'String'));

if ok    
    if handles.stripgen.linkedroistrip == 1
        handles.stripgen.northroiloc = southroiloc;
        handles.stripgen.eastroiloc = southroiloc;
        handles.stripgen.southroiloc = southroiloc;
        handles.stripgen.westroiloc = southroiloc;
        
        set(handles.northroilocbox,'String', get(hObject,'String'));
        set(handles.westroilocbox,'String', get(hObject,'String'));
        set(handles.eastroilocbox,'String', get(hObject,'String'));
    else
        handles.stripgen.southroiloc = southroiloc;
    end
else
    set(hObject,'String',''); 
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function southroilocbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to southroilocbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eastroilocbox_Callback(hObject, eventdata, handles)
% hObject    handle to eastroilocbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eastroilocbox as text
%        str2double(get(hObject,'String')) returns contents of eastroilocbox as a double
[eastroiloc ok]= str2num(get(hObject,'String'));

if ok    
    if handles.stripgen.linkedroistrip == 1
        handles.stripgen.northroiloc = eastroiloc;
        handles.stripgen.eastroiloc = eastroiloc;
        handles.stripgen.southroiloc = eastroiloc;
        handles.stripgen.westroiloc = eastroiloc;
        
        set(handles.northroilocbox,'String', get(hObject,'String'));
        set(handles.westroilocbox,'String', get(hObject,'String'));
        set(handles.southroilocbox,'String', get(hObject,'String'));
    else
        handles.stripgen.eastroiloc = eastroiloc;
    end
else
    set(hObject,'String',''); 
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function eastroilocbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eastroilocbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in samebox.
function samebox_Callback(hObject, eventdata, handles)
% hObject    handle to samebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of samebox
if get(hObject,'Value') == 1
    handles.stripgen.linkedroistrip = 1;
else
    handles.stripgen.linkedroistrip = 0;
end
guidata(hObject, handles);


% --- Executes on selection change in roitype.
function roitype_Callback(hObject, eventdata, handles)
% hObject    handle to roitype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roitype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roitype
contents = cellstr(get(hObject,'String'));

if strcmp( deblank(contents{get(hObject,'Value')}), 'Fixed')
    handles.param.roitype = 'Fixed';
    set(handles.roilabel,'String','Size');
    set(handles.roisize,'String', num2str( 55 ) );
    set(handles.boxunitspopup,'Value',1);
    handles.param.boxunits = 'microns';
    handles.param.roiboxsize = 55;
elseif strcmp( deblank(contents{get(hObject,'Value')}),'Variable')
    handles.param.roitype = 'Variable';
    set(handles.roilabel,'String','Padding');
    set(handles.roisize,'String', num2str( 10 ) );
    set(handles.boxunitspopup,'Value',1);
    handles.param.boxunits = 'microns';
    handles.param.roiboxsize = 10;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function roitype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roitype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browseimports.
function browseimports_Callback(hObject, eventdata, handles)
% hObject    handle to browseimports (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname, pathname] = uigetfile('*.csv','Select location file to import');

fid = fopen(fullfile(pathname,fname),'r');

handles.locfile = textscan(fid,'%s%s%s%d','Delimiter',',');

fclose(fid);

[tmp, repeatinds]=unique(handles.locfile{4});

handles.locfile{1}=handles.locfile{1}(repeatinds);
handles.locfile{2}=handles.locfile{2}(repeatinds);
handles.locfile{3}=handles.locfile{3}(repeatinds);
handles.locfile{4}=handles.locfile{4}(repeatinds);

set(handles.roilocs,'Data', [handles.locfile{2} handles.locfile{3}] );

guidata(hObject,handles);
