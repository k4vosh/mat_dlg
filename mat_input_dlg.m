function varargout = mat_input_dlg(varargin)
%MAT_INPUT_DLG Input a 2-D matrix.
% ans = MAT_INPUT_DLG('size', tableSize) creates a modal dialog box 
% that returns user input for the in the form of a 2-D matrix in the size
% given by tableSize.
% 
% ans = MAT_INPUT_DLG('size',tableSize, options) manipulates dialogue
% characteristics using 'PropertyName',PropertyValue pairs. The following
% optional pairs are supported:
% 
% 
% 'title', titleStr :                   Specifies title of the window.
%                                       Defaults to "Matrix Entry"
% 
% 'string', promptStr :                 Specifies the prompt. Defaults to
%                                       "Please Enter the matrix:"
%                                     
% 'cell validation', cellValidation :   A constraint that is used to validate
%                                       each cell as it is entered.
%                                       It must be one of the following:
%                                        1. A function handle that returns
%                                        true for valid input and false for
%                                        invalid input.
%                                        2. One of the strings "positive",
%                                           "nonnegative", "nonzero" or
%                                           "integer".
%                                        3. An empty string to denote that
%                                        no validation is required. This is
%                                        the default behaviour.
% 
% 'mat validation', matValidation :     A function handle that is used to
%                                       validate the entire matrix before
%                                       returning the results.
% 
% 'colnames', colNames :                A cell string containing titles for
%                                       the columns. It must have the same
%                                       number of elements as the number of
%                                       columns.
% 
% 'rownames', rowNames :                A cell string containing titles for
%                                       the rows. It must have the same
%                                       number of elements as the number of
%                                       rows.
% 
% 'colwidth', colWidth :                The width of the columns.
%
% ans = MAT_INPUT_DLG('size',tableSize, options)
%
% See also INPUTDLG, DIALOG, ERRORDLG, HELPDLG, LISTDLG,
%    MSGBOX, QUESTDLG, TEXTWRAP, UIWAIT, WARNDLG .
% 
% Copyright (c) 2016 Mohammadreza Khoshbin

% Last Modified by GUIDE v2.5 17-Jan-2016 05:03:04
%#ok<*INUSD,*DEFNU,*INUSL>
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mat_input_dlg_OpeningFcn, ...
                   'gui_OutputFcn',  @mat_input_dlg_OutputFcn, ...
                   'gui_LayoutFcn',  @mat_input_dlg_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end
% End initialization code - DO NOT EDIT

% --- Executes just before mat_input_dlg is made visible.
function mat_input_dlg_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for mat_input_dlg
handles.output = false;
guidata(hObject, handles);
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
            case 'size'
                tableSize = varargin{index+1};
            case 'data'
                oldData = varargin{index+1};
            case 'cell validation'
                cellValidation = varargin{index+1};
            case 'mat validation'
                matValidation = varargin{index+1};
            case 'colnames'
                colNames = varargin{index+1};
            case 'rownames'
                rowNames = varargin{index+1};
            case 'colwidth'
                colWidth = varargin{index+1};
            case 'title'
                set(hObject, 'Name', varargin{index+1});
            case 'string'
                set(handles.msg_st, 'String', varargin{index+1});
        end
    end
end

validateattributes(tableSize, {'numeric'}, {'positive', 'size', [1 2]})
global dlgInput
cellEditCallbackFunc = @table_uit_CellEditCallback;

data{tableSize(1),tableSize(2)} = [];
if exist('oldData', 'var')
    validateattributes(oldData, {'numeric'}, {'size', tableSize})
    for i=1:numel(data) %#ok<FORPF>
       data{i} = oldData(i); 
    end
end
if exist('cellValidation', 'var')
    if ischar(cellValidation)
        if any(strcmp(cellValidation, {'positive', 'nonnegative', 'nonzero', 'integer'}))
        elseif strcmp(cellValidation, '')
            cellValidation = 'scalar';
        else
            error('cellValidation must be either a function handle, an empty string or one of the strings "positive", "nonnegative", "nonzero" or "integer".')
        end
    elseif isa(cellValidation, 'function_handle')
        cellEditCallbackFunc = cellValidation;
    else
        error('"cell validation" must be either a function handle, an empty string or one of the strings "positive", "nonnegative", "nonzero" or "integer".')
    end
else
    cellValidation = 'scalar';
end
dlgInput.cellValidation= cellValidation;

if exist('matValidation', 'var')
    if isa(matValidation, 'function_handle')
        dlgInput.matValidation= matValidation;
    else
        error('"mat validation" must be a function handle.')
    end
end

if exist('colNames', 'var')
    if ~iscellstr(colNames)
        error('"colnames" must be a cell string.')
    end
    if numel(colNames) ~= tableSize(2)
        error('"colnames" must be the same size as the number of columns.')
    end
end
if exist('rowNames', 'var')
    if ~iscellstr(rowNames)
        error('"rownames" must be a cell string.')
    end
    if numel(rowNames) ~= tableSize(1)
        error('"rownames" must be the same size as the number of rows.')
    end
end
if exist('colWidth', 'var')
    validateattributes(colWidth, {'numeric'}, {'scalar', 'positive'})
    colWidth = num2cell(repmat([colWidth], [1 tableSize(2)]));
else
    colWidth = num2cell(repmat([50], [1 tableSize(2)]));
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

%Create the table.
coledit = repmat([true], [1, tableSize(2)]);
% colWidth = cellfun( (@(x) 'auto'), cell(1, 10), 'UniformOutput', false);
colfmt = cellfun( (@(x) 'numeric'), cell(1, 10), 'UniformOutput', false);

appdata = [];
appdata.lastValidTag = 'table_uit';
appdata.PropertyMetaData = {  {  'DataPropertyDimension' 'DataPropertyConditionedDimension' 'DataPropertySource' 'BackgroundColorPropertyDimension' 'RowNameTyped' 'ColumnNameTyped' } {  [4 2] [4 2] 'DataDefault' [2 3] {  blanks(0) blanks(0) blanks(0) blanks(0) } {  blanks(0) blanks(0) blanks(0) blanks(0) } } };
handles.table_uit = uitable(...
    'Parent',hObject,...
    'Units','characters',...
    'Position',[9.8 4.95 130.2 22.6923076923077],...
    'BackgroundColor',[1 1 1;0.831372549019608 0.815686274509804 0.784313725490196],...
    'Data',data,...
    'ColumnEditable',coledit,...
    'ColumnFormat',colfmt,...
    'ColumnWidth',colWidth,...
    'Tag','table_uit',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata},...
    'CellEditCallback', cellEditCallbackFunc);

if exist('colNames', 'var')
    set(handles.table_uit, 'ColumnName', colNames)
end
if exist('rowNames', 'var')
    set(handles.table_uit, 'RowName', rowNames)
end

guidata(hObject, handles);
% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')
% UIWAIT makes mat_input_dlg wait for user response (see UIRESUME)
uiwait(handles.figure1);
end
function varargout = mat_input_dlg_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
global dlgInput
dlgInput = [];
% The figure can be deleted now
delete(handles.figure1);
end
function figure1_CloseRequestFcn(hObject, eventdata, handles) 

if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
end
function ok_pb_Callback(hObject, eventdata, handles)
matDataCell = get(handles.table_uit,'Data');
matSize = size(matDataCell);
matData = zeros(matSize);
for i=1:matSize(1)
    for j=1:matSize(2)
        if isempty(matDataCell{i,j})
            matData(i,j) = NaN;
        else
            matData(i,j) = matDataCell{i,j};
        end
    end
end
global dlgInput
if isfield(dlgInput, 'matValidation')
    matValidation = dlgInput.matValidation;
    if ~matValidation(matData)
        errordlg('Matrix didn''t pass validation test.')
        return
    end
end
handles.output = matData;
guidata(hObject, handles);
uiresume(handles.figure1);
end
function cancel_pb_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
uiresume(handles.figure1);
end
% --- Creates and returns a handle to the GUI figure. 
function h1 = mat_input_dlg_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end


appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', 2, ...
    'pushbutton', 3, ...
    'axes', 2, ...
    'text', 3, ...
    'uitable', 2), ...
    'override', 1, ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', 1, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0);
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
'Units','normalized',...
'CloseRequestFcn','mat_input_dlg(''figure1_CloseRequestFcn'',gcf,[],guidata(gcf))',...
'Color',[0.941176470588235 0.941176470588235 0.941176470588235],...
'Colormap',[0 0 0;1 1 1;0.984313725490196 0.956862745098039 0.6;0.984313725490196 0.952941176470588 0.6;0 0 0.6;0.988235294117647 0.956862745098039 0.603921568627451;0.988235294117647 0.956862745098039 0.6;0.690196078431373 0.662745098039216 0.666666666666667;0.0549019607843137 0.0509803921568627 0.0549019607843137;0.0627450980392157 0.0588235294117647 0.0627450980392157;0.0705882352941176 0.0666666666666667 0.0705882352941176;0.0156862745098039 0.0117647058823529 0.0196078431372549;0.0352941176470588 0.0313725490196078 0.0392156862745098;0.623529411764706 0.596078431372549 0.658823529411765;0.0196078431372549 0.0156862745098039 0.0274509803921569;0.501960784313725 0.482352941176471 0.647058823529412;0.447058823529412 0.427450980392157 0.643137254901961;0.388235294117647 0.372549019607843 0.63921568627451;0.270588235294118 0.258823529411765 0.627450980392157;0.294117647058824 0.282352941176471 0.627450980392157;0.309803921568627 0.298039215686275 0.631372549019608;0.352941176470588 0.341176470588235 0.635294117647059;0.125490196078431 0.12156862745098 0.611764705882353;0.149019607843137 0.145098039215686 0.615686274509804;0.192156862745098 0.184313725490196 0.619607843137255;0.223529411764706 0.215686274509804 0.619607843137255;0 0 0.00784313725490196;0 0 0.00392156862745098;0.0196078431372549 0.0196078431372549 0.603921568627451;0.0470588235294118 0.0431372549019608 0.603921568627451;0.0784313725490196 0.0745098039215686 0.607843137254902;0.0823529411764706 0.0784313725490196 0.607843137254902;0.105882352941176 0.101960784313725 0.611764705882353;0.00392156862745098 0.00392156862745098 0.0196078431372549;0.00784313725490196 0.00784313725490196 0.0196078431372549;0.0117647058823529 0.0117647058823529 0.0274509803921569;0.0235294117647059 0.0235294117647059 0.0352941176470588;0.0274509803921569 0.0274509803921569 0.0392156862745098;1 0.996078431372549 0.623529411764706;1 1 0.627450980392157;1 0.996078431372549 0.631372549019608;1 1 0.635294117647059;1 1 0.643137254901961;1 1 0.650980392156863;0.0705882352941176 0.0705882352941176 0.0509803921568627;0.305882352941176 0.305882352941176 0.227450980392157;0.16078431372549 0.16078431372549 0.12156862745098;0.0392156862745098 0.0392156862745098 0.0352941176470588;0.0705882352941176 0.0705882352941176 0.0666666666666667;0.0862745098039216 0.0862745098039216 0.0823529411764706;0.184313725490196 0.184313725490196 0.176470588235294;0.0941176470588235 0.0941176470588235 0.0901960784313725;0.101960784313725 0.101960784313725 0.0980392156862745;0.145098039215686 0.145098039215686 0.141176470588235;1 0.988235294117647 0.615686274509804;1 0.992156862745098 0.619607843137255;0.925490196078431 0.913725490196078 0.6;0.423529411764706 0.419607843137255 0.298039215686275;1 0.976470588235294 0.611764705882353;0.996078431372549 0.972549019607843 0.607843137254902;1 0.980392156862745 0.615686274509804;1 0.984313725490196 0.619607843137255;1 0.976470588235294 0.619607843137255;0.988235294117647 0.972549019607843 0.615686274509804;1 0.980392156862745 0.627450980392157;0.988235294117647 0.972549019607843 0.619607843137255;0.984313725490196 0.964705882352941 0.615686274509804;0.219607843137255 0.215686274509804 0.145098039215686;0.4 0.392156862745098 0.270588235294118;0.258823529411765 0.254901960784314 0.192156862745098;0.145098039215686 0.141176470588235 0.0862745098039216;0.992156862745098 0.96078431372549 0.603921568627451;0.988235294117647 0.96078431372549 0.6;0.96078431372549 0.929411764705882 0.584313725490196;0.996078431372549 0.968627450980392 0.607843137254902;0.988235294117647 0.96078431372549 0.603921568627451;0.96078431372549 0.933333333333333 0.588235294117647;0.945098039215686 0.913725490196078 0.576470588235294;0.996078431372549 0.964705882352941 0.611764705882353;0.984313725490196 0.952941176470588 0.603921568627451;0.964705882352941 0.941176470588235 0.592156862745098;0.964705882352941 0.937254901960784 0.592156862745098;0.956862745098039 0.925490196078431 0.588235294117647;0.949019607843137 0.92156862745098 0.584313725490196;0.984313725490196 0.96078431372549 0.607843137254902;0.952941176470588 0.925490196078431 0.588235294117647;0.972549019607843 0.949019607843137 0.607843137254902;0.956862745098039 0.929411764705882 0.6;0.937254901960784 0.909803921568627 0.588235294117647;0.929411764705882 0.901960784313726 0.584313725490196;0.92156862745098 0.898039215686275 0.584313725490196;0.909803921568627 0.882352941176471 0.576470588235294;0.850980392156863 0.827450980392157 0.541176470588235;0.611764705882353 0.596078431372549 0.4;0.407843137254902 0.396078431372549 0.270588235294118;0.458823529411765 0.447058823529412 0.309803921568627;0.368627450980392 0.36078431372549 0.258823529411765;0.329411764705882 0.32156862745098 0.235294117647059;0.231372549019608 0.227450980392157 0.176470588235294;0.988235294117647 0.952941176470588 0.6;0.988235294117647 0.952941176470588 0.603921568627451;0.984313725490196 0.949019607843137 0.6;0.92156862745098 0.890196078431373 0.580392156862745;0.819607843137255 0.792156862745098 0.52156862745098;0.83921568627451 0.811764705882353 0.537254901960784;0.8 0.772549019607843 0.509803921568627;0.764705882352941 0.737254901960784 0.494117647058824;0.713725490196078 0.690196078431373 0.462745098039216;0.741176470588235 0.713725490196078 0.482352941176471;0.580392156862745 0.56078431372549 0.380392156862745;0.215686274509804 0.207843137254902 0.141176470588235;0.698039215686274 0.674509803921569 0.458823529411765;0.619607843137255 0.6 0.407843137254902;0.682352941176471 0.658823529411765 0.450980392156863;0.450980392156863 0.435294117647059 0.301960784313725;0.262745098039216 0.254901960784314 0.176470588235294;0.584313725490196 0.564705882352941 0.396078431372549;0.486274509803922 0.470588235294118 0.329411764705882;0.6 0.580392156862745 0.407843137254902;0.470588235294118 0.454901960784314 0.32156862745098;0.505882352941176 0.490196078431373 0.349019607843137;0.388235294117647 0.376470588235294 0.274509803921569;0.403921568627451 0.392156862745098 0.290196078431373;0.266666666666667 0.258823529411765 0.192156862745098;0.180392156862745 0.176470588235294 0.137254901960784;0.72156862745098 0.694117647058824 0.470588235294118;0.6 0.576470588235294 0.392156862745098;0.101960784313725 0.0980392156862745 0.0705882352941176;0.309803921568627 0.298039215686275 0.215686274509804;0.313725490196078 0.301960784313725 0.219607843137255;0.250980392156863 0.243137254901961 0.180392156862745;0.141176470588235 0.137254901960784 0.105882352941176;0.156862745098039 0.152941176470588 0.12156862745098;0.0862745098039216 0.0823529411764706 0.0588235294117647;0.494117647058824 0.474509803921569 0.349019607843137;0.286274509803922 0.274509803921569 0.203921568627451;0.219607843137255 0.211764705882353 0.164705882352941;0.243137254901961 0.235294117647059 0.184313725490196;0.0627450980392157 0.0588235294117647 0.0392156862745098;0.192156862745098 0.184313725490196 0.145098039215686;0.443137254901961 0.43921568627451 0.419607843137255;0.0784313725490196 0.0745098039215686 0.0588235294117647;0.164705882352941 0.156862745098039 0.125490196078431;0.117647058823529 0.113725490196078 0.0980392156862745;0.152941176470588 0.145098039215686 0.117647058823529;0.850980392156863 0.815686274509804 0.682352941176471;0.835294117647059 0.8 0.67843137254902;0.0470588235294118 0.0431372549019608 0.0313725490196078;0.0862745098039216 0.0823529411764706 0.0705882352941176;0.803921568627451 0.772549019607843 0.67843137254902;0.23921568627451 0.235294117647059 0.223529411764706;0.513725490196078 0.505882352941176 0.482352941176471;0.568627450980392 0.56078431372549 0.537254901960784;0.56078431372549 0.552941176470588 0.529411764705882;0.556862745098039 0.549019607843137 0.525490196078431;0.552941176470588 0.545098039215686 0.52156862745098;0.270588235294118 0.266666666666667 0.254901960784314;0.607843137254902 0.6 0.576470588235294;0.576470588235294 0.568627450980392 0.545098039215686;0.290196078431373 0.286274509803922 0.274509803921569;0.498039215686275 0.490196078431373 0.470588235294118;0.482352941176471 0.474509803921569 0.454901960784314;0.47843137254902 0.470588235294118 0.450980392156863;0.533333333333333 0.525490196078431 0.505882352941176;0.529411764705882 0.52156862745098 0.501960784313725;0.513725490196078 0.505882352941176 0.486274509803922;0.505882352941176 0.498039215686275 0.47843137254902;0.501960784313725 0.494117647058824 0.474509803921569;0.552941176470588 0.545098039215686 0.525490196078431;0.772549019607843 0.741176470588235 0.674509803921569;0.662745098039216 0.650980392156863 0.623529411764706;0.647058823529412 0.635294117647059 0.607843137254902;0.701960784313725 0.690196078431373 0.662745098039216;0.686274509803922 0.674509803921569 0.647058823529412;0.670588235294118 0.658823529411765 0.631372549019608;0.0352941176470588 0.0313725490196078 0.0235294117647059;0.129411764705882 0.12156862745098 0.105882352941176;0.6 0.588235294117647 0.564705882352941;0.588235294117647 0.576470588235294 0.552941176470588;0.580392156862745 0.568627450980392 0.545098039215686;0.63921568627451 0.627450980392157 0.603921568627451;0.627450980392157 0.615686274509804 0.592156862745098;0.623529411764706 0.611764705882353 0.588235294117647;0.619607843137255 0.607843137254902 0.584313725490196;0.611764705882353 0.6 0.576470588235294;0.423529411764706 0.415686274509804 0.4;0.686274509803922 0.674509803921569 0.650980392156863;0.682352941176471 0.670588235294118 0.647058823529412;0.67843137254902 0.666666666666667 0.643137254901961;0.674509803921569 0.662745098039216 0.63921568627451;0.666666666666667 0.654901960784314 0.631372549019608;0.662745098039216 0.650980392156863 0.627450980392157;0.654901960784314 0.643137254901961 0.619607843137255;0.650980392156863 0.63921568627451 0.615686274509804;0.454901960784314 0.447058823529412 0.431372549019608;0.450980392156863 0.443137254901961 0.427450980392157;0.43921568627451 0.431372549019608 0.415686274509804;0.435294117647059 0.427450980392157 0.411764705882353;0.227450980392157 0.223529411764706 0.215686274509804;0.466666666666667 0.458823529411765 0.443137254901961;0.247058823529412 0.243137254901961 0.235294117647059;0.243137254901961 0.23921568627451 0.231372549019608;0.23921568627451 0.235294117647059 0.227450980392157;0.235294117647059 0.231372549019608 0.223529411764706;0.258823529411765 0.254901960784314 0.247058823529412;0.294117647058824 0.290196078431373 0.282352941176471;0.32156862745098 0.317647058823529 0.309803921568627;0.745098039215686 0.717647058823529 0.670588235294118;0.529411764705882 0.517647058823529 0.498039215686275;0.52156862745098 0.509803921568627 0.490196078431373;0.572549019607843 0.56078431372549 0.541176470588235;0.564705882352941 0.552941176470588 0.533333333333333;0.545098039215686 0.533333333333333 0.513725490196078;0.592156862745098 0.580392156862745 0.56078431372549;0.694117647058824 0.67843137254902 0.654901960784314;0.352941176470588 0.345098039215686 0.333333333333333;0.345098039215686 0.337254901960784 0.325490196078431;0.368627450980392 0.36078431372549 0.349019607843137;0.407843137254902 0.4 0.388235294117647;0.4 0.392156862745098 0.380392156862745;0.388235294117647 0.380392156862745 0.368627450980392;0.490196078431373 0.47843137254902 0.462745098039216;0.474509803921569 0.462745098039216 0.447058823529412;0.733333333333333 0.705882352941177 0.670588235294118;0.0588235294117647 0.0549019607843137 0.0509803921568627;0.101960784313725 0.0980392156862745 0.0941176470588235;0.133333333333333 0.129411764705882 0.125490196078431;0.701960784313725 0.682352941176471 0.662745098039216;0.27843137254902 0.270588235294118 0.262745098039216;0.145098039215686 0.141176470588235 0.137254901960784;0.333333333333333 0.325490196078431 0.317647058823529;0.317647058823529 0.309803921568627 0.301960784313725;0.309803921568627 0.301960784313725 0.294117647058824;0.164705882352941 0.16078431372549 0.156862745098039;0.203921568627451 0.2 0.196078431372549;0.0196078431372549 0.0156862745098039 0.0156862745098039;0.0470588235294118 0.0431372549019608 0.0431372549019608;0.0549019607843137 0.0509803921568627 0.0509803921568627;0.0705882352941176 0.0666666666666667 0.0666666666666667;0.0745098039215686 0.0705882352941176 0.0705882352941176;0.0784313725490196 0.0745098039215686 0.0745098039215686;0.12156862745098 0.117647058823529 0.117647058823529;0.113725490196078 0.109803921568627 0.109803921568627;0.172549019607843 0.168627450980392 0.168627450980392;0.109803921568627 0.109803921568627 0.109803921568627;0.105882352941176 0.105882352941176 0.105882352941176;0.0941176470588235 0.0941176470588235 0.0941176470588235;0.0823529411764706 0.0823529411764706 0.0823529411764706;0.0627450980392157 0.0627450980392157 0.0627450980392157;0.0588235294117647 0.0588235294117647 0.0588235294117647;0.0509803921568627 0.0509803921568627 0.0509803921568627;0.0392156862745098 0.0392156862745098 0.0392156862745098;0.0313725490196078 0.0313725490196078 0.0313725490196078;0.0274509803921569 0.0274509803921569 0.0274509803921569;0.00784313725490196 0.00784313725490196 0.00784313725490196;0.752941176470588 0.752941176470588 0.752941176470588],...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','none',...
'Name','Matrix Entry',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'Position',[0.480234260614934 0.234375 0.549780380673499 0.520833333333333],...
'Resize','off',...
'HandleVisibility','callback',...
'UserData',[],...
'Tag','figure1',...
'Visible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ok_pb';

h2 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)mat_input_dlg('ok_pb_Callback',hObject,eventdata,guidata(hObject)),...
'CData',[],...
'ListboxTop',0,...
'Position',[0.264980026631158 0.015 0.135818908122503 0.1325],...
'String','OK',...
'UserData',[],...
'Tag','ok_pb',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'cancel_pb';

h3 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback',@(hObject,eventdata)mat_input_dlg('cancel_pb_Callback',hObject,eventdata,guidata(hObject)),...
'CData',[],...
'ListboxTop',0,...
'Position',[0.597869507323569 0.015 0.134487350199734 0.1325],...
'String','Cancel',...
'UserData',[],...
'Tag','cancel_pb',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'msg_st';

h4 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[39.8 28 70.2 1.92307692307692],...
'String','Please Enter the matrix:',...
'Style','text',...
'Tag','msg_st',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

hsingleton = h1;
end
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   if isa(createfcn,'function_handle')
       createfcn(hObject, eventdata);
   else
       eval(createfcn);
   end
end
end
function table_uit_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to table_uit (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

global dlgInput
cellValidation = dlgInput.cellValidation;
try
    validateattributes(eventdata.NewData, {'numeric'}, {'scalar', cellValidation})
catch e
    ind = eventdata.Indices;
    newData = get(hObject, 'Data');
    newData{ind(1), ind(2)} = eventdata.PreviousData;
    set(hObject, 'Data', newData)
end
end
% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error(message('MATLAB:guide:StateFieldNotFound', gui_StateFields{ i }, gui_Mfile));
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % MAT_INPUT_DLG
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % MAT_INPUT_DLG(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallback(gui_State, varargin{:})
    % MAT_INPUT_DLG('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % MAT_INPUT_DLG(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~ishghandle(fig,'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || isprop(fig,'__GUIDEFigure');
    end
        
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else       
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishghandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end

    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.

    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.   
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);

        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')

        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end

    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI M-file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;

    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end

    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end

    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure); 
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);

        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end

        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end

    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end
end
function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    gui_hFigure = openfig(name, singleton, visible);  
    %workaround for CreateFcn not called to create ActiveX
    if feature('HGUsingMATLABClasses')
        peers=findobj(findall(allchild(gui_hFigure)),'type','uicontrol','style','text');    
        for i=1:length(peers)
            if isappdata(peers(i),'Control')
                actxproxy(peers(i));
            end            
        end
    end
end
end
function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
             && isequal(varargin{1},gcbo);
catch
    result = false;
end
end
function result = local_isInvokeHGCallback(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
             (ischar(varargin{1}) ...
             && isequal(ishghandle(varargin{2}), 1) ...
             && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
                ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The MIT License (MIT)
% 
% Copyright (c) 2016 Mohammadreza Khoshbin
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%