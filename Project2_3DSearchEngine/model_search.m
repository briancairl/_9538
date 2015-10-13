function varargout = model_search(varargin)
% MODEL_SEARCH MATLAB code for model_search.fig
%      MODEL_SEARCH, by itself, creates a new MODEL_SEARCH or raises the existing
%      singleton*.
%
%      H = MODEL_SEARCH returns the handle to a new MODEL_SEARCH or the handle to
%      the existing singleton*.
%
%      MODEL_SEARCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODEL_SEARCH.M with the given input arguments.
%
%      MODEL_SEARCH('Property','Value',...) creates a new MODEL_SEARCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before model_search_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to model_search_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help model_search

% Last Modified by GUIDE v2.5 12-Oct-2015 20:10:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @model_search_OpeningFcn, ...
                   'gui_OutputFcn',  @model_search_OutputFcn, ...
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





% --- Executes just before model_search is made visible.
function model_search_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to model_search (see VARARGIN)

% Choose default command line output for model_search
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Global Params (default)
global DescriptorType;      DescriptorType      = 'GD';
global DescriptorParams;    DescriptorParams    = get_descriptor_params();
global ModelInputColor;     ModelInputColor     = 'b';
global ModelSearchColor;    ModelSearchColor    = 'g';
global ModelDescriptors;    ModelDescriptors    = [];
global ModelDirectory;      ModelDirectory      = 'models';
global ModelInput;          ModelInput.E = [];  ModelInput.V = [];


% Clear Match Collumn
clear_matches(handles);

% UIWAIT makes model_search wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = model_search_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function model_name_entry_Callback(hObject, eventdata, handles)
% hObject    handle to model_name_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of model_name_entry as text
%        str2double(get(hObject,'String')) returns contents of model_name_entry as a double
    global ModelInputColor;
    global ModelInput;
    
    % Get string input from box
    mesh_filename   = get(hObject,'String');
    
    if ismeshfilename(mesh_filename)
        ModelInput = meshread(mesh_filename);
        if  isempty(ModelInput.V)
            warndlg(sprintf('Mesh ''%s'' is empty or file does not exist.',mesh_filename));
        else
            % Preview the mesh
            axes(handles.model_view); cla
            meshview(ModelInput,'FaceColor',ModelInputColor); 
            
            % Generate corresponding query descriptors
            recompute_query_descriptors();
        end
    else
        warndlg(sprintf('Invalid mesh filename : %s',mesh_filename));
    end

    

    
    

% --- Executes during object creation, after setting all properties.
function model_name_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to model_name_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in descriptor_menu.
function descriptor_menu_Callback(hObject, eventdata, handles)
% hObject    handle to descriptor_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns descriptor_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from descriptor_menu
    global DescriptorType;
    global DescriptorParams;
    
    
    % Get string input from box
    contents        = get(hObject,'String');
    DescriptorType  = contents{get(hObject,'Value')};
    
    % Recompute active model descriptors
    recompute_query_descriptors();
    
    % Check to see if db exists
    if(check_create_descriptor_db())
    
        % Get descriptor parameters asscoiated with database
        DescriptorParams= get_descriptor_params();
        
    end

    
% --- Executes during object creation, after setting all properties.
function descriptor_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to descriptor_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in search_button.
function search_button_Callback(hObject, eventdata, handles)
% hObject    handle to search_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    if  query_is_loaded()
        if(check_create_descriptor_db())
            clear_matches(handles);
            scan_descriptor_db(handles);
        end
        set(handles.candidate_name,'String','Search complete!');
    else
        warndlg('No query model set!');
    end
    
    
    
    
% Helper functions
% ========================================================================
function b = query_is_loaded()
    global ModelInput;
    if isempty(ModelInput)
        b = false;
    else
        b = ~isempty(ModelInput.V);
    end

    
function dir = get_descriptor_dir()
    global DescriptorType;
    dir = sprintf('%s_data',DescriptorType);

    
function b = has_descriptor_dir()
    b = ~isempty(dir(get_descriptor_dir()));


    
function p = get_descriptor_params()
    if  has_descriptor_dir()
        p = dlmread(sprintf('%s/param.conf',get_descriptor_dir()));
    else
        vrat= inputdlg('Input the descriptor/vertex ratio.');
        dmin= inputdlg('Input minimum binning distance.');
        dmax= inputdlg('Input maximum binning distance.');
        dres= inputdlg('Input binning resolution.');
        p   = [str2double(vrat{1}),str2double(dmin{1}),str2double(dmax{1}),str2double(dres{1})];
    end

    
    
function recompute_query_descriptors()
    
    global ModelInput;
    global ModelDescriptors;
    global DescriptorType;
    global DescriptorParams;   

    if query_is_loaded()
        % Generate a descriptor matrix (using default params)
        ModelDescriptors = generate_spatial_descriptors(ModelInput,...
            DescriptorParams(1),...
            DescriptorParams(2),...
            DescriptorParams(3),...
            DescriptorParams(4),...
            DescriptorType      ...
        );
    end

    

function b = check_create_descriptor_db()
    global DescriptorType;
    global ModelDirectory;
    global DescriptorParams;
    
    b       = false;
    if  ~has_descriptor_dir()
        qans= questdlg( sprintf('Descriptor database does not exist for type ''%s''. Would you like to create one?', DescriptorType) );
        if strcmpi(qans,'YES')
            output_dir = sprintf('%s_data',DescriptorType);
            batch_generate_mesh_descriptors(ModelDirectory,output_dir,...
                DescriptorParams(1),...
                DescriptorParams(2),...
                DescriptorParams(3),...
                DescriptorParams(4),...
                DescriptorType      ...
            );
            b = true;
        end
    else
        b = true;
    end

    
    
    function clear_matches(handles)
        axes(handles.match0); cla; set(handles.match0_name,'String','1st Closest Match');
        axes(handles.match1); cla; set(handles.match1_name,'String','2nd Closest Match');
        axes(handles.match2); cla; set(handles.match2_name,'String','3rd Closest Match');
        axes(handles.match3); cla; set(handles.match3_name,'String','4th Closest Match');
        axes(handles.match4); cla; set(handles.match4_name,'String','5th Closest Match');
 
    
    
    function scan_descriptor_db(handles)
        
        global ModelDescriptors;
        global ModelSearchColor;
        global ModelInputColor;
        global ModelInput;
        
        % Get descriptor file names
        desc_files      = dir(get_descriptor_dir());
        desc_files(1:2) = []; %. and ..
        N               = numel(desc_files)-1;
        grades          = zeros(N,1);
        model_names     = cell(N,1);
        models          = cell(N,1);
        descriptors     = cell(N,1);
        
        for idx = 1:N
            
            % Load database models
            model_names{idx}    = sprintf('models/%s.off',desc_files(idx).name(4:(end-4)));
            models{idx}         = meshread(model_names{idx});
            
            
            % Update Name-box of UI
            update_str = sprintf('[%d/%d] %s',idx,(N-1),model_names{idx});
            set(handles.candidate_name,'String',update_str);
            
            
            % Plot query vs. db models
            axes(handles.model_view)
            cla
            hold on
            meshview(models{idx} ,  'FaceColor',ModelSearchColor);
            meshview(ModelInput,    'FaceColor',ModelInputColor);
            hold off
            pause(1e-3);
            
            
            % Perform matching/grading
            data                = load(sprintf('%s/%s',get_descriptor_dir(),desc_files(idx).name));
            descriptors{idx}    = data.D;
            [~,d]               = knnsearch(descriptors{idx}.',ModelDescriptors.');
            grades(idx)         = sum(d);
            
            
            % Plot query vs. db histograms
            axes(handles.hist_view)
            cla
            hold on
            plot(descriptors{idx},  'Color',ModelSearchColor);
            plot(ModelDescriptors,  'Color',ModelInputColor);
            axis auto;
            hold off
            pause(1e-3);
               
        end
        
        % Sort grades
        [~,opt_idx] = sort(grades);
        
        % Display the closest database result
        axes(handles.match0); cla; meshview(models{opt_idx(1)},'FaceColor',ModelSearchColor); set(handles.match0_name,'String',model_names{opt_idx(1)});
        axes(handles.match1); cla; meshview(models{opt_idx(2)},'FaceColor',ModelSearchColor); set(handles.match1_name,'String',model_names{opt_idx(2)});
        axes(handles.match2); cla; meshview(models{opt_idx(3)},'FaceColor',ModelSearchColor); set(handles.match2_name,'String',model_names{opt_idx(3)});
        axes(handles.match3); cla; meshview(models{opt_idx(4)},'FaceColor',ModelSearchColor); set(handles.match3_name,'String',model_names{opt_idx(4)});
        axes(handles.match4); cla; meshview(models{opt_idx(5)},'FaceColor',ModelSearchColor); set(handles.match4_name,'String',model_names{opt_idx(5)});

        % Repost the model + hist
        axes(handles.model_view); cla
        meshview(ModelInput,    'FaceColor',ModelInputColor);

        % Plot query vs. db histograms
        axes(handles.hist_view); cla
        plot(ModelDescriptors,  'Color',ModelInputColor);

