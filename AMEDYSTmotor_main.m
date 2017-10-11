function AMEDYSTmotor_main(hObject, ~)
% AMEDYSTmotor_main is the main program, calling the different tasks and
% routines, accoding to the paramterts defined in the GUI


%% GUI : open a new one or retrive data from the current one

if nargin == 0
    
    AMEDYSTmotor_GUI;
    
    return
    
end

handles = guidata(hObject); % retrieve GUI data


%% Clean the environment

clc
sca
rng('default')
rng('shuffle')


%% Initialize the main structure

global S
S               = struct; % S is the main structure, containing everything usefull, and used everywhere
S.TimeStamp     = datestr(now, 'yyyy-mm-dd HH:MM'); % readable
S.TimeStampFile = datestr(now, 30                ); % to sort automatically by time of creation


%% Task selection

switch get(hObject,'Tag')
    
    case 'pushbutton_Motor'
        Task = 'Motor';
        
    case 'pushbutton_EyelinkCalibration'
        Task = 'EyelinkCalibration';
        
    otherwise
        error('AMEDYSTmotor:TaskSelection','Error in Task selection')
end

S.Task = Task;


%% Environement selection

switch get(get(handles.uipanel_Environement,'SelectedObject'),'Tag')
    case 'radiobutton_MRI'
        Environement = 'MRI';
    case 'radiobutton_Practice'
        Environement = 'Practice';
    otherwise
        warning('AMEDYSTmotor:ModeSelection','Error in Environement selection')
end

S.Environement = Environement;


%% Save mode selection

switch get(get(handles.uipanel_SaveMode,'SelectedObject'),'Tag')
    case 'radiobutton_SaveData'
        SaveMode = 'SaveData';
    case 'radiobutton_NoSave'
        SaveMode = 'NoSave';
    otherwise
        warning('AMEDYSTmotor:SaveSelection','Error in SaveMode selection')
end

S.SaveMode = SaveMode;


%% Mode selection

switch get(get(handles.uipanel_OperationMode,'SelectedObject'),'Tag')
    case 'radiobutton_Acquisition'
        OperationMode = 'Acquisition';
    case 'radiobutton_FastDebug'
        OperationMode = 'FastDebug';
    case 'radiobutton_RealisticDebug'
        OperationMode = 'RealisticDebug';
    otherwise
        warning('AMEDYSTmotor:ModeSelection','Error in Mode selection')
end

S.OperationMode = OperationMode;


%% Sequence

Sequence = get(handles.edit_Sequence,'String');
if isempty(Sequence)
    error('Sequence is empty')
end
S.Sequence = Sequence;


%% Subject ID & Run number

SubjectID = get(handles.edit_SubjectID,'String');

if isempty(SubjectID)
    error('AMEDYSTmotor:SubjectIDLength','\n SubjectID is required \n')
end

% Prepare path
DataPath = [fileparts(pwd) filesep 'data' filesep SubjectID filesep];

DataFile = sprintf('%s%s_%s_%s_%s', DataPath, S.TimeStampFile, SubjectID, Task, Environement );


S.SubjectID = SubjectID;
% S.RunNumber = RunNumber;
S.DataPath  = DataPath;
S.DataFile  = DataFile;


%% Controls for SubjectID depending on the Mode selected

switch OperationMode
    
    case 'Acquisition'
        
        % Empty subject ID
        if isempty(SubjectID)
            error('AMEDYSTmotor:MissingSubjectID','\n For acquisition, SubjectID is required \n')
        end
        
        % Acquisition => save data
        if ~get(handles.radiobutton_SaveData,'Value')
            warning('AMEDYSTmotor:DataShouldBeSaved','\n\n\n In acquisition mode, data should be saved \n\n\n')
        end
        
end


%% Parallel port ?

switch get( handles.checkbox_ParPort , 'Value' )
    
    case 1
        ParPort = 'On';
        S.ParPortMessages = Common.PrepareParPort;
        
    case 0
        ParPort = 'Off';
end

handles.ParPort    = ParPort;
S.ParPort = ParPort;


%% Left or right handed ?

switch get(get(handles.uipanel_ParallelPortLeftRight,'SelectedObject'),'Tag')
    case 'radiobutton_LeftButtons'
        Side = 'Left';
    case 'radiobutton_RightButtons'
        Side = 'Right';
    otherwise
        warning('AMEDYSTmotor:LeftRight','Error in LeftRight')
end

S.Side = Side;


%% Check if Eyelink toolbox is available

switch get(get(handles.uipanel_EyelinkMode,'SelectedObject'),'Tag')
    
    case 'radiobutton_EyelinkOff'
        
        EyelinkMode = 'Off';
        
    case 'radiobutton_EyelinkOn'
        
        EyelinkMode = 'On';
        
        % 'Eyelink.m' exists ?
        status = which('Eyelink.m');
        if isempty(status)
            error('AMEDYST:EyelinkToolbox','no ''Eyelink.m'' detected in the path')
        end
        
        % Save mode ?
        if strcmp(S.SaveMode,'NoSave')
            error('AMEDYST:SaveModeForEyelink',' \n ---> Save mode should be turned on when using Eyelink <--- \n ')
        end
        
        % Eyelink connected ?
        Eyelink.IsConnected
        
        % File name for the eyelink : 8 char maximum
        %         switch Task
        %             case 'EyelinkCalibration'
        %                 task = 'EC';
        %             case 'Session'
        %                 task = ['S' get(handles.edit_IlluBlock,'String')];
        %             otherwise
        %                 error('AMEDYST:Task','Task ?')
        %         end
        %         EyelinkFile = [ SubjectID task sprintf('%.2d',str2double(RunNumber)) ];
        
        S.EyelinkFile = EyelinkFile;
        
    otherwise
        
        warning('AMEDYST:EyelinkMode','Error in Eyelink mode')
        
end

S.EyelinkMode = EyelinkMode;


%% Security : NEVER overwrite a file
% If erasing a file is needed, we need to do it manually

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if exist([DataFile '.mat'], 'file')
        error('MATLAB:FileAlreadyExists',' \n ---> \n The file %s.mat already exists .  <--- \n \n',DataFile);
    end
    
end


%% Get stimulation parameters

S.Parameters = GetParameters;

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay = get(handles.listbox_Screens,'Value');
S.Parameters.Video.ScreenMode = str2double( AvalableDisplays(SelectedDisplay) );


%% Windowed screen ?

switch get(handles.checkbox_WindowedScreen,'Value')
    
    case 1
        WindowedMode = 'On';
    case 0
        WindowedMode = 'Off';
    otherwise
        warning('AMEDYST:WindowedScreen','Error in WindowedScreen')
        
end

S.WindowedMode = WindowedMode;


%% Open PTB window & sound

S.PTB = StartPTB;


%% Task run

EchoStart(Task)

switch Task
    
    case 'Motor'
        TaskData = Motor.Task;
        
    otherwise
        error('AMEDYSTmotor:Task','Task ?')
end

EchoStop(Task)

S.TaskData = TaskData;


%% Save files on the fly : just a security in case of crash of the end the script

save([fileparts(pwd) filesep 'data' filesep 'LastS'],'S');


%% Close PTB

sca;
Priority( 0 );


%% SPM data organization

[ names , onsets , durations ] = SPMnod;


%% Saving data strucure

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
    save(DataFile, 'S', 'names', 'onsets', 'durations');
    save([DataFile '_SPM'], 'names', 'onsets', 'durations');
    
end


%% Send S and SPM nod to workspace

assignin('base', 'S'        , S        );
assignin('base', 'names'    , names    );
assignin('base', 'onsets'   , onsets   );
assignin('base', 'durations', durations);


%% Ready for another run

set(handles.text_LastFileNameAnnouncer,'Visible','on'                             )
set(handles.text_LastFileName,         'Visible','on'                             )
set(handles.text_LastFileName,         'String' , DataFile(length(DataPath)+1:end))

printResults(S.TaskData.ER)

WaitSecs(0.100);
pause(0.100);
fprintf('\n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')
fprintf('  Ready for another session   \n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')


end % function
