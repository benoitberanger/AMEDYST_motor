function varargout = AMEDYSTmotor_GUI
% AMEDYSTmotor_GUI is the function that creates (or bring to focus) AMEDYSTmotor GUI.
% Then, AMEDYSTmotor_main is always called to start each task. It is the
% "main" program.

% debug=1 closes previous figure and reopens it, and send the gui handles
% to base workspace.
debug = 0;


%% Open a singleton figure, or gring the actual into focus.

% Is the GUI already open ?
figPtr = findall(0,'Tag',mfilename);

if ~isempty(figPtr) % Figure exists so brings it to the focus
    
    figure(figPtr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        close(figPtr); %#ok<UNRCH>
        AMEDYSTmotor_GUI;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
else % Create the figure
    
    clc
    rng('default')
    rng('shuffle')
    
    % Create a figure
    figHandle = figure( ...
        'HandleVisibility', 'off',... % close all does not close the figure
        'MenuBar'         , 'none'                   , ...
        'Toolbar'         , 'none'                   , ...
        'Name'            , mfilename                , ...
        'NumberTitle'     , 'off'                    , ...
        'Units'           , 'Pixels'                 , ...
        'Position'        , [20, 20, 600, 700] , ...
        'Tag'             , mfilename                );
    
    figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
    buttonBGcolor = figureBGcolor - 0.1;
    editBGcolor   = [1.0 1.0 1.0];
    
    % Create GUI handles : pointers to access the graphic objects
    handles = guihandles(figHandle);
    
    
    %% Panel proportions
    
    panelProp.xposP = 0.05; % xposition of panel normalized : from 0 to 1
    panelProp.wP    = 1 - panelProp.xposP * 2;
    
    panelProp.vect  = ...
        [1 2 2 1 1 1 1 2 ]; % relative proportions of each panel, from bottom to top
    
    panelProp.vectLength    = length(panelProp.vect);
    panelProp.vectTotal     = sum(panelProp.vect);
    panelProp.adjustedTotal = panelProp.vectTotal + 1;
    panelProp.unitWidth     = 1/panelProp.adjustedTotal;
    panelProp.interWidth    = panelProp.unitWidth/panelProp.vectLength;
    
    panelProp.countP = panelProp.vectLength + 1;
    panelProp.yposP  = @(countP) panelProp.unitWidth*sum(panelProp.vect(1:countP-1)) + 0.8*countP*panelProp.interWidth;
    
    
    %% Panel : Subject & Run
    
    p_sr.x = panelProp.xposP;
    p_sr.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_sr.y = panelProp.yposP(panelProp.countP);
    p_sr.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_SubjectRun = uipanel(handles.(mfilename),...
        'Title','Subject & Run',...
        'Units', 'Normalized',...
        'Position',[p_sr.x p_sr.y p_sr.w p_sr.h],...
        'BackgroundColor',figureBGcolor);
    
    p_sr.nbO       = 3; % Number of objects
    p_sr.Ow        = 1/(p_sr.nbO + 1); % Object width
    p_sr.countO    = 0; % Object counter
    p_sr.xposO     = @(countO) p_sr.Ow/(p_sr.nbO+1)*countO + (countO-1)*p_sr.Ow;
    p_sr.yposOmain = 0.1;
    p_sr.hOmain    = 0.6;
    p_sr.yposOhdr  = 0.7;
    p_sr.hOhdr     = 0.2;
    
    
    % ---------------------------------------------------------------------
    % Edit : Subject ID
    
    p_sr.countO = p_sr.countO + 1;
    e_sid.x = p_sr.xposO(p_sr.countO);
    e_sid.y = p_sr.yposOmain ;
    e_sid.w = p_sr.Ow;
    e_sid.h = p_sr.hOmain;
    handles.edit_SubjectID = uicontrol(handles.uipanel_SubjectRun,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_sid.x e_sid.y e_sid.w e_sid.h],...
        'BackgroundColor',editBGcolor,...
        'String','');
    
    
    % ---------------------------------------------------------------------
    % Text : Subject ID
    
    t_sid.x = p_sr.xposO(p_sr.countO);
    t_sid.y = p_sr.yposOhdr ;
    t_sid.w = p_sr.Ow;
    t_sid.h = p_sr.hOhdr;
    handles.text_SubjectID = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_sid.x t_sid.y t_sid.w t_sid.h],...
        'String','Subject ID',...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Check SubjectID data
    
    p_sr.countO = p_sr.countO + 1;
    b_csidd.x = p_sr.xposO(p_sr.countO);
    b_csidd.y = p_sr.yposOmain;
    b_csidd.w = p_sr.Ow;
    b_csidd.h = p_sr.hOmain;
    handles.pushbutton_Check_SubjectID_data = uicontrol(handles.uipanel_SubjectRun,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_csidd.x b_csidd.y b_csidd.w b_csidd.h],...
        'String','Check SubjectID data',...
        'BackgroundColor',buttonBGcolor,...
        'TooltipString','Display in Command Window the content of data/(SubjectID)',...
        'Callback',@(hObject,eventdata)GUI.Pushbutton_Check_SubjectID_data_Callback(handles.edit_SubjectID,eventdata));
    
    
    % ---------------------------------------------------------------------
    % Text : Last file name annoucer
    
    p_sr.countO = p_sr.countO + 1;
    t_lfna.x = p_sr.xposO(p_sr.countO);
    t_lfna.y = p_sr.yposOhdr ;
    t_lfna.w = p_sr.Ow;
    t_lfna.h = p_sr.hOhdr;
    handles.text_LastFileNameAnnouncer = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_lfna.x t_lfna.y t_lfna.w t_lfna.h],...
        'String','Last file name',...
        'BackgroundColor',figureBGcolor,...
        'Visible','Off');
    
    
    % ---------------------------------------------------------------------
    % Text : Last file name
    
    t_lfn.x = p_sr.xposO(p_sr.countO);
    t_lfn.y = p_sr.yposOmain ;
    t_lfn.w = p_sr.Ow;
    t_lfn.h = p_sr.hOmain;
    handles.text_LastFileName = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_lfn.x t_lfn.y t_lfn.w t_lfn.h],...
        'String','',...
        'BackgroundColor',figureBGcolor,...
        'Visible','Off');
    
    
    %% Panel : Sequence
    
    p_seq.x = panelProp.xposP;
    p_seq.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_seq.y = panelProp.yposP(panelProp.countP);
    p_seq.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_Sequence = uibuttongroup(handles.(mfilename),...
        'Title','Sequence',...
        'Units', 'Normalized',...
        'Position',[p_seq.x p_seq.y p_seq.w p_seq.h],...
        'BackgroundColor',figureBGcolor);
    
    p_seq.nbO    = 1; % Number of objects
    p_seq.Ow     = 1/(p_seq.nbO + 1); % Object width
    p_seq.countO = 0; % Object counter
    p_seq.xposO  = @(countO) p_seq.Ow/(p_seq.nbO+1)*countO + (countO-1)*p_seq.Ow;
    
    
    % ---------------------------------------------------------------------
    % Edit : Sequence
    
    p_seq.countO = p_seq.countO + 1;
    e_seq.x   = p_seq.xposO(p_seq.countO);
    e_seq.y   = 0.1;
    e_seq.w   = p_seq.Ow;
    e_seq.h   = 0.8;
    e_seq.tag = 'edit_Sequence';
    handles.(e_seq.tag) = uicontrol(handles.uipanel_Sequence,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_seq.x e_seq.y e_seq.w e_seq.h],...
        'BackgroundColor',editBGcolor,...
        'String','',...
        'Callback',@edit_Seqeunce_Callback);
    
    
    %% Panel : Save mode
    
    p_sm.x = panelProp.xposP;
    p_sm.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_sm.y = panelProp.yposP(panelProp.countP);
    p_sm.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_SaveMode = uibuttongroup(handles.(mfilename),...
        'Title','Save mode',...
        'Units', 'Normalized',...
        'Position',[p_sm.x p_sm.y p_sm.w p_sm.h],...
        'BackgroundColor',figureBGcolor);
    
    p_sm.nbO    = 2; % Number of objects
    p_sm.Ow     = 1/(p_sm.nbO + 1); % Object width
    p_sm.countO = 0; % Object counter
    p_sm.xposO  = @(countO) p_sm.Ow/(p_sm.nbO+1)*countO + (countO-1)*p_sm.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Save Data
    
    p_sm.countO = p_sm.countO + 1;
    r_sd.x   = p_sm.xposO(p_sm.countO);
    r_sd.y   = 0.1 ;
    r_sd.w   = p_sm.Ow;
    r_sd.h   = 0.8;
    r_sd.tag = 'radiobutton_SaveData';
    handles.(r_sd.tag) = uicontrol(handles.uipanel_SaveMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_sd.x r_sd.y r_sd.w r_sd.h],...
        'String','Save data',...
        'TooltipString','Save data to : /data/SubjectID/SubjectID_Task_RunNumber',...
        'HorizontalAlignment','Center',...
        'Tag',r_sd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : No save
    
    p_sm.countO = p_sm.countO + 1;
    r_ns.x   = p_sm.xposO(p_sm.countO);
    r_ns.y   = 0.1 ;
    r_ns.w   = p_sm.Ow;
    r_ns.h   = 0.8;
    r_ns.tag = 'radiobutton_NoSave';
    handles.(r_ns.tag) = uicontrol(handles.uipanel_SaveMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_ns.x r_ns.y r_ns.w r_ns.h],...
        'String','No save',...
        'TooltipString','In Acquisition mode, Save mode must be engaged',...
        'HorizontalAlignment','Center',...
        'Tag',r_ns.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    %% Panel : Environement
    
    p_env.x = panelProp.xposP;
    p_env.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_env.y = panelProp.yposP(panelProp.countP);
    p_env.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_Environement = uibuttongroup(handles.(mfilename),...
        'Title','Environement',...
        'Units', 'Normalized',...
        'Position',[p_env.x p_env.y p_env.w p_env.h],...
        'BackgroundColor',figureBGcolor);
    
    p_env.nbO    = 2; % Number of objects
    p_env.Ow     = 1/(p_env.nbO + 1); % Object width
    p_env.countO = 0; % Object counter
    p_env.xposO  = @(countO) p_env.Ow/(p_env.nbO+1)*countO + (countO-1)*p_env.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : MRI
    
    p_env.countO = p_env.countO + 1;
    r_mri.x   = p_env.xposO(p_env.countO);
    r_mri.y   = 0.1 ;
    r_mri.w   = p_env.Ow;
    r_mri.h   = 0.8;
    r_mri.tag = 'radiobutton_MRI';
    handles.(r_mri.tag) = uicontrol(handles.uipanel_Environement,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_mri.x r_mri.y r_mri.w r_mri.h],...
        'String','MRI',...
        'TooltipString','fMRI task',...
        'HorizontalAlignment','Center',...
        'Tag',(r_mri.tag),...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Practice
    
    p_env.countO = p_env.countO + 1;
    r_practice.x   = p_env.xposO(p_env.countO);
    r_practice.y   = 0.1 ;
    r_practice.w   = p_env.Ow;
    r_practice.h   = 0.8;
    r_practice.tag = 'radiobutton_Practice';
    handles.(r_practice.tag) = uicontrol(handles.uipanel_Environement,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_practice.x r_practice.y r_practice.w r_practice.h],...
        'String','Practice',...
        'TooltipString','some kind of practice...',...
        'HorizontalAlignment','Center',...
        'Tag',(r_practice.tag),...
        'BackgroundColor',figureBGcolor);
    
    
    %% Panel : Left & Right buttons
    
    p_pplr.x = panelProp.xposP;
    p_pplr.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_pplr.y = panelProp.yposP(panelProp.countP);
    p_pplr.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_ParallelPortLeftRight = uibuttongroup(handles.(mfilename),...
        'Title','Parallel port     ||     Left/Right buttons',...
        'Units', 'Normalized',...
        'Position',[p_pplr.x p_pplr.y p_pplr.w p_pplr.h],...
        'BackgroundColor',figureBGcolor);
    
    p_pplr.nbO    = 2; % Number of objects
    p_pplr.Ow     = 1/(p_pplr.nbO + 1); % Object width
    p_pplr.countO = 0; % Object counter
    p_pplr.xposO  = @(countO) p_pplr.Ow/(p_pplr.nbO+1)*countO + (countO-1)*p_pplr.Ow;
    
    
    %     % ---------------------------------------------------------------------
    %     % Checkbox : Parallel port
    %
    %     p_pplr.countO = p_pplr.countO + 1;
    %     c_pp.x = p_pplr.xposO(p_pplr.countO);
    %     c_pp.y = 0.1 ;
    %     c_pp.w = p_pplr.Ow*2;
    %     c_pp.h = 0.8;
    %     handles.checkbox_ParPort = uicontrol(handles.uipanel_ParallelPortLeftRight,...
    %         'Style','checkbox',...
    %         'Units', 'Normalized',...
    %         'Position',[c_pp.x c_pp.y c_pp.w c_pp.h],...
    %         'String','Parallel port',...
    %         'HorizontalAlignment','Center',...
    %         'TooltipString','Send messages via parallel port : useful for Eyelink',...
    %         'BackgroundColor',figureBGcolor,...
    %         'Value',1,...
    %         'Callback',@GUI.Checkbox_ParPort_Callback,...
    %         'CreateFcn',@GUI.Checkbox_ParPort_Callback);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Left buttons
    
    p_pplr.countO = p_pplr.countO + 1;
    r_left.x   = p_pplr.xposO(p_pplr.countO);
    r_left.y   = 0.1 ;
    r_left.w   = p_pplr.Ow;
    r_left.h   = 0.8;
    r_left.tag = 'radiobutton_LeftButtons';
    handles.(r_left.tag) = uicontrol(handles.uipanel_ParallelPortLeftRight,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_left.x r_left.y r_left.w r_left.h],...
        'String','Left buttons',...
        'HorizontalAlignment','Center',...
        'Tag',r_left.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Right buttons
    
    p_pplr.countO = p_pplr.countO + 1;
    r_right.x   = p_pplr.xposO(p_pplr.countO);
    r_right.y   = 0.1 ;
    r_right.w   = p_pplr.Ow;
    r_right.h   = 0.8;
    r_right.tag = 'radiobutton_RightButtons';
    handles.(r_right.tag) = uicontrol(handles.uipanel_ParallelPortLeftRight,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_right.x r_right.y r_right.w r_right.h],...
        'String','Right buttons',...
        'HorizontalAlignment','Center',...
        'Tag',r_right.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    %% Panel : Eyelink mode
    
    el_shift = 0.30;
    
    p_el.x = panelProp.xposP + el_shift;
    p_el.w = panelProp.wP - el_shift ;
    
    panelProp.countP = panelProp.countP - 1;
    p_el.y = panelProp.yposP(panelProp.countP);
    p_el.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_EyelinkMode = uibuttongroup(handles.(mfilename),...
        'Title','Eyelink mode',...
        'Units', 'Normalized',...
        'Position',[p_el.x p_el.y p_el.w p_el.h],...
        'BackgroundColor',figureBGcolor,...
        'SelectionChangeFcn',@uipanel_EyelinkMode_SelectionChangeFcn);
    
    
    % ---------------------------------------------------------------------
    % Checkbox : Windowed screen
    
    c_ws.x = panelProp.xposP;
    c_ws.w = el_shift - panelProp.xposP;
    
    c_ws.y = panelProp.yposP(panelProp.countP)-0.01 ;
    c_ws.h = p_el.h * 0.3;
    
    handles.checkbox_WindowedScreen = uicontrol(handles.(mfilename),...
        'Style','checkbox',...
        'Units', 'Normalized',...
        'Position',[c_ws.x c_ws.y c_ws.w c_ws.h],...
        'String','Windowed screen',...
        'HorizontalAlignment','Center',...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % Listbox : Screens
    
    l_sc.x = panelProp.xposP;
    l_sc.w = el_shift - panelProp.xposP;
    
    l_sc.y = c_ws.y + c_ws.h ;
    l_sc.h = p_el.h * 0.6;
    
    handles.listbox_Screens = uicontrol(handles.(mfilename),...
        'Style','listbox',...
        'Units', 'Normalized',...
        'Position',[l_sc.x l_sc.y l_sc.w l_sc.h],...
        'String',{'a' 'b' 'c'},...
        'TooltipString','Select the display mode   PTB : 0 for extended display (over all screens) , 1 for screen 1 , 2 for screen 2 , etc.',...
        'HorizontalAlignment','Center',...
        'CreateFcn',@GUI.Listbox_Screens_CreateFcn);
    
    
    % ---------------------------------------------------------------------
    % Text : ScreenMode
    
    t_sm.x = panelProp.xposP;
    t_sm.w = el_shift - panelProp.xposP;
    
    t_sm.y = l_sc.y + l_sc.h ;
    t_sm.h = p_el.h * 0.15;
    
    handles.text_ScreenMode = uicontrol(handles.(mfilename),...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_sm.x t_sm.y t_sm.w t_sm.h],...
        'String','Screen mode selection',...
        'TooltipString','Output of Screen(''Screens'')   Use ''Screen Screens?'' in Command window for help',...
        'HorizontalAlignment','Center',...
        'BackgroundColor',figureBGcolor);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    p_el_up.nbO    = 6; % Number of objects
    p_el_up.Ow     = 1/(p_el_up.nbO + 1); % Object width
    p_el_up.countO = 0; % Object counter
    p_el_up.xposO  = @(countO) p_el_up.Ow/(p_el_up.nbO+1)*countO + (countO-1)*p_el_up.Ow;
    p_el_up.y      = 0.6;
    p_el_up.h      = 0.3;
    
    % ---------------------------------------------------------------------
    % RadioButton : Eyelink ON
    
    p_el_up.countO = p_el_up.countO + 1;
    r_elon.x   = p_el_up.xposO(p_el_up.countO);
    r_elon.y   = p_el_up.y ;
    r_elon.w   = p_el_up.Ow;
    r_elon.h   = p_el_up.h;
    r_elon.tag = 'radiobutton_EyelinkOn';
    handles.(r_elon.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_elon.x r_elon.y r_elon.w r_elon.h],...
        'String','On',...
        'HorizontalAlignment','Center',...
        'Tag',r_elon.tag,...
        'BackgroundColor',figureBGcolor,...
        'Visible','On');
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Eyelink OFF
    
    p_el_up.countO = p_el_up.countO + 1;
    r_eloff.x   = p_el_up.xposO(p_el_up.countO);
    r_eloff.y   = p_el_up.y ;
    r_eloff.w   = p_el_up.Ow;
    r_eloff.h   = p_el_up.h;
    r_eloff.tag = 'radiobutton_EyelinkOff';
    handles.(r_eloff.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_eloff.x r_eloff.y r_eloff.w r_eloff.h],...
        'String','Off',...
        'HorizontalAlignment','Center',...
        'Tag',r_eloff.tag,...
        'BackgroundColor',figureBGcolor,...
        'Visible','On');
    
    
    % ---------------------------------------------------------------------
    % Checkbox : Parallel port
    
    p_el_up.countO = p_el_up.countO + 1;
    c_pp.x = p_el_up.xposO(p_el_up.countO);
    c_pp.y = p_el_up.y ;
    c_pp.w = p_el_up.Ow*2;
    c_pp.h = p_el_up.h;
    handles.checkbox_ParPort = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','checkbox',...
        'Units', 'Normalized',...
        'Position',[c_pp.x c_pp.y c_pp.w c_pp.h],...
        'String','Parallel port',...
        'HorizontalAlignment','Center',...
        'TooltipString','Send messages via parallel port : useful for Eyelink',...
        'BackgroundColor',figureBGcolor,...
        'Value',1,...
        'Callback',@GUI.Checkbox_ParPort_Callback,...
        'CreateFcn',@GUI.Checkbox_ParPort_Callback);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    p_el_dw.nbO    = 3; % Number of objects
    p_el_dw.Ow     = 1/(p_el_dw.nbO + 1); % Object width
    p_el_dw.countO = 0; % Object counter
    p_el_dw.xposO  = @(countO) p_el_dw.Ow/(p_el_dw.nbO+1)*countO + (countO-1)*p_el_dw.Ow;
    p_el_dw.y      = 0.1;
    p_el_dw.h      = 0.4 ;
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Initialize
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_init.x = p_el_dw.xposO(p_el_dw.countO);
    b_init.y = p_el_dw.y ;
    b_init.w = p_el_dw.Ow;
    b_init.h = p_el_dw.h;
    handles.pushbutton_Initialize = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_init.x b_init.y b_init.w b_init.h],...
        'String','Initialize',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.Initialize');
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink IsConnected
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_isco.x = p_el_dw.xposO(p_el_dw.countO);
    b_isco.y = p_el_dw.y ;
    b_isco.w = p_el_dw.Ow;
    b_isco.h = p_el_dw.h;
    handles.pushbutton_IsConnected = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_isco.x b_isco.y b_isco.w b_isco.h],...
        'String','IsConnected',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.IsConnected');
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Calibration
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_cal.x   = p_el_dw.xposO(p_el_dw.countO);
    b_cal.y   = p_el_dw.y ;
    b_cal.w   = p_el_dw.Ow;
    b_cal.h   = p_el_dw.h;
    b_cal.tag = 'pushbutton_EyelinkCalibration';
    handles.(b_cal.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_cal.x b_cal.y b_cal.w b_cal.h],...
        'String','Calibration',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_cal.tag,...
        'Callback',@SMACC_main);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink force shutdown
    
    b_fsd.x = c_pp.x + c_pp.h;
    b_fsd.y = p_el_up.y ;
    b_fsd.w = p_el_dw.Ow*1.25;
    b_fsd.h = p_el_dw.h;
    handles.pushbutton_ForceShutDown = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_fsd.x b_fsd.y b_fsd.w b_fsd.h],...
        'String','ForceShutDown',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.ForceShutDown');
    
    
    %% Panel : Instructions & DreamDebrief
    
    %     p_instr.x = panelProp.xposP;
    %     p_instr.w = panelProp.wP;
    %
    %     panelProp.countP = panelProp.countP - 1;
    %     p_instr.y = panelProp.yposP(panelProp.countP);
    %     p_instr.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    %
    %     handles.uipanel_InstructionsDreamDebrief = uibuttongroup(handles.(mfilename),...
    %         'Title','Instructions & DreamDebrief',...
    %         'Units', 'Normalized',...
    %         'Position',[p_instr.x p_instr.y p_instr.w p_instr.h],...
    %         'BackgroundColor',figureBGcolor);
    %
    %     p_instr.nbO    = 5; % Number of objects
    %     p_instr.Ow     = 1/(p_instr.nbO + 1); % Object width
    %     p_instr.countO = 0; % Object counter
    %     p_instr.xposO  = @(countO) p_instr.Ow/(p_instr.nbO+1)*countO + (countO-1)*p_instr.Ow;
    %
    %     buttun_y = 0.10;
    %     buttun_h = 0.85;
    %
    %     % ---------------------------------------------------------------------
    %     % Pushbutton : Instructions for Sleep
    %
    %     p_instr.countO = p_instr.countO + 1;
    %     b_sleep.x = p_instr.xposO(p_instr.countO);
    %     b_sleep.y = buttun_y;
    %     b_sleep.w = p_instr.Ow;
    %     b_sleep.h = buttun_h;
    %     b_sleep.tag = 'pushbutton_InstructionSleep';
    %     handles.(b_sleep.tag) = uicontrol(handles.uipanel_InstructionsDreamDebrief,...
    %         'Style','pushbutton',...
    %         'Units', 'Normalized',...
    %         'Position',[b_sleep.x b_sleep.y b_sleep.w b_sleep.h],...
    %         'String','Sleep',...
    %         'BackgroundColor',buttonBGcolor,...
    %         'Tag',b_sleep.tag,...
    %         'Callback',@PlayInstructions);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % Pushbutton : Instructions for Execution
    %
    %     p_instr.countO = p_instr.countO + 1;
    %     b_execution.x = p_instr.xposO(p_instr.countO);
    %     b_execution.y = buttun_y;
    %     b_execution.w = p_instr.Ow;
    %     b_execution.h = buttun_h;
    %     b_execution.tag = 'pushbutton_InstructionExecution';
    %     handles.(b_execution.tag) = uicontrol(handles.uipanel_InstructionsDreamDebrief,...
    %         'Style','pushbutton',...
    %         'Units', 'Normalized',...
    %         'Position',[b_execution.x b_execution.y b_execution.w b_execution.h],...
    %         'String','Execution',...
    %         'BackgroundColor',buttonBGcolor,...
    %         'Tag',b_execution.tag,...
    %         'Callback',@PlayInstructions);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % Pushbutton : Instructions for Imagination
    %
    %     p_instr.countO = p_instr.countO + 1;
    %     b_imagination.x = p_instr.xposO(p_instr.countO);
    %     b_imagination.y = buttun_y;
    %     b_imagination.w = p_instr.Ow;
    %     b_imagination.h = buttun_h;
    %     b_imagination.tag = 'pushbutton_InstructionImagination';
    %     handles.(b_imagination.tag) = uicontrol(handles.uipanel_InstructionsDreamDebrief,...
    %         'Style','pushbutton',...
    %         'Units', 'Normalized',...
    %         'Position',[b_imagination.x b_imagination.y b_imagination.w b_imagination.h],...
    %         'String','Imagination',...
    %         'BackgroundColor',buttonBGcolor,...
    %         'Tag',b_imagination.tag,...
    %         'Callback',@PlayInstructions);
    %
    %     % ---------------------------------------------------------------------
    %     % Pushbutton : Dreamd debrief
    %
    %     p_instr.countO = p_instr.countO + 1;
    %     b_dreamdebrief.x = p_instr.xposO(p_instr.countO) + p_instr.Ow/4;
    %     b_dreamdebrief.y = buttun_y;
    %     b_dreamdebrief.w = p_instr.Ow*2;
    %     b_dreamdebrief.h = buttun_h;
    %     b_dreamdebrief.tag = 'pushbutton_DreamDebrief';
    %     handles.(b_dreamdebrief.tag) = uicontrol(handles.uipanel_InstructionsDreamDebrief,...
    %         'Style','pushbutton',...
    %         'Units', 'Normalized',...
    %         'Position',[b_dreamdebrief.x b_dreamdebrief.y b_dreamdebrief.w b_dreamdebrief.h],...
    %         'String','Dream debrief',...
    %         'BackgroundColor',buttonBGcolor,...
    %         'Tag',b_dreamdebrief.tag,...
    %         'Callback',@AMEDYSTmotor_main);
    
    
    %% Panel : Task
    
    p_tk.x = panelProp.xposP;
    p_tk.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_tk.y = panelProp.yposP(panelProp.countP);
    p_tk.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_Task = uibuttongroup(handles.(mfilename),...
        'Title','Task',...
        'Units', 'Normalized',...
        'Position',[p_tk.x p_tk.y p_tk.w p_tk.h],...
        'BackgroundColor',figureBGcolor);
    
    %     p_tk.vect          = [ 2 0.5 3 3 ]; % Object relative widthn from left to right
    %     p_tk.vectLength    = length(p_tk.vect);
    %     p_tk.vectTotal     = sum(p_tk.vect);
    %     p_tk.adjustedTotal = p_tk.vectTotal + 1;
    %     p_tk.unitWidth     = 1/p_tk.adjustedTotal;
    %     p_tk.interWidth    = p_tk.unitWidth/p_tk.vectLength;
    %
    %     p_tk.countO = p_tk.vectLength + 1;
    %     p_tk.xposO  = @(countP) p_tk.unitWidth*sum(p_tk.vect(1:countP-1)) + 0.8*countP*p_tk.interWidth;
    
    p_tk.nbO    = 1; % Number of objects
    p_tk.Ow     = 1/(p_tk.nbO + 1); % Object width
    p_tk.countO = 0; % Object counter
    p_tk.xposO  = @(countO) p_tk.Ow/(p_tk.nbO+1)*countO + (countO-1)*p_tk.Ow;
    
    buttun_y = 0.10;
    buttun_h = 0.80;
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Motor
    
    p_tk.countO  = p_tk.countO + 1;
    b_motor.x   = p_tk.xposO(p_tk.countO);
    b_motor.y   = buttun_y;
    b_motor.w   = p_tk.Ow;
    b_motor.h   = buttun_h;
    b_motor.tag = 'pushbutton_Motor';
    handles.(b_motor.tag) = uicontrol(handles.uipanel_Task,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_motor.x b_motor.y b_motor.w b_motor.h],...
        'String','Motor',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_motor.tag,...
        'Callback',@AMEDYSTmotor_main);
    
    
    %     % ---------------------------------------------------------------------
    %     % Pushbutton : Familiarization
    %
    %     p_tk.countO  = p_tk.countO + 1;
    %     b_fam.x   = p_tk.xposO(p_tk.countO);
    %     b_fam.y   = buttun_y + buttun_h/2 * 1.05;
    %     b_fam.w   = p_tk.unitWidth*p_tk.vect(p_tk.countO);
    %     b_fam.h   = buttun_h/2 * 0.95;
    %     b_fam.tag = 'pushbutton_Familiarization';
    %     handles.(b_fam.tag) = uicontrol(handles.uipanel_Task,...
    %         'Style','pushbutton',...
    %         'Units', 'Normalized',...
    %         'Position',[b_fam.x b_fam.y b_fam.w b_fam.h],...
    %         'String','Familiarization',...
    %         'BackgroundColor',buttonBGcolor,...
    %         'Tag',b_fam.tag,...
    %         'Callback',@AMEDYSTmotor_main);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % Pushbutton : Training
    %
    %     b_train.x   = p_tk.xposO(p_tk.countO);
    %     b_train.y   = buttun_y;
    %     b_train.w   = p_tk.unitWidth*p_tk.vect(p_tk.countO);
    %     b_train.h   = buttun_h/2 * 0.95;
    %     b_train.tag = 'pushbutton_Training';
    %     handles.(b_train.tag) = uicontrol(handles.uipanel_Task,...
    %         'Style','pushbutton',...
    %         'Units', 'Normalized',...
    %         'Position',[b_train.x b_train.y b_train.w b_train.h],...
    %         'String','Training',...
    %         'BackgroundColor',buttonBGcolor,...
    %         'Tag',b_train.tag,...
    %         'Callback',@AMEDYSTmotor_main);
    %
    %     % To add space
    %     p_tk.countO  = p_tk.countO + 1;
    %
    %     % ---------------------------------------------------------------------
    %     % Pushbutton : SpeedTest
    %
    %     p_tk.countO  = p_tk.countO + 1;
    %     b_speed.x   = p_tk.xposO(p_tk.countO);
    %     b_speed.y   = buttun_y;
    %     b_speed.w   = p_tk.unitWidth*p_tk.vect(p_tk.countO);
    %     b_speed.h   = buttun_h;
    %     b_speed.tag = 'pushbutton_SpeedTest';
    %     handles.(b_speed.tag) = uicontrol(handles.uipanel_Task,...
    %         'Style','pushbutton',...
    %         'Units', 'Normalized',...
    %         'Position',[b_speed.x b_speed.y b_speed.w b_speed.h],...
    %         'String','SpeedTest',...
    %         'BackgroundColor',buttonBGcolor,...
    %         'Tag',b_speed.tag,...
    %         'Callback',@AMEDYSTmotor_main,...
    %         'Tooltip','Only complex sequence');
    %
    %
    %     % ---------------------------------------------------------------------
    %     % Pushbutton : DualTask_Complex
    %
    %     p_tk.countO = p_tk.countO + 1;
    %     b_dtC.x   = p_tk.xposO(p_tk.countO);
    %     b_dtC.y   = buttun_y + buttun_h/2 * 1.05;
    %     b_dtC.w   = p_tk.unitWidth*p_tk.vect(p_tk.countO);
    %     b_dtC.h   = buttun_h/2 * 0.95;
    %     b_dtC.tag = 'pushbutton_DualTask_Complex';
    %     handles.(b_dtC.tag) = uicontrol(handles.uipanel_Task,...
    %         'Style','pushbutton',...
    %         'Units', 'Normalized',...
    %         'Position',[b_dtC.x b_dtC.y b_dtC.w b_dtC.h],...
    %         'String','DualTask Complex',...
    %         'BackgroundColor',buttonBGcolor,...
    %         'Tag',b_dtC.tag,...
    %         'Callback',@AMEDYSTmotor_main);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % Pushbutton : DualTask_Simple
    %
    %     b_dtS.x   = p_tk.xposO(p_tk.countO);
    %     b_dtS.y   = buttun_y;
    %     b_dtS.w   = p_tk.unitWidth*p_tk.vect(p_tk.countO);
    %     b_dtS.h   = buttun_h/2 * 0.95;
    %     b_dtS.tag = 'pushbutton_DualTask_Simple';
    %     handles.(b_dtS.tag) = uicontrol(handles.uipanel_Task,...
    %         'Style','pushbutton',...
    %         'Units', 'Normalized',...
    %         'Position',[b_dtS.x b_dtS.y b_dtS.w b_dtS.h],...
    %         'String','DualTask Simple',...
    %         'BackgroundColor',buttonBGcolor,...
    %         'Tag',b_dtS.tag,...
    %         'Callback',@AMEDYSTmotor_main);
    
    
    %% Panel : Name modulation
    
    %     p_nm.x = panelProp.xposP;
    %     p_nm.w = panelProp.wP;
    %
    %     panelProp.countP = panelProp.countP - 1;
    %     p_nm.y = panelProp.yposP(panelProp.countP);
    %     p_nm.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    %
    %     handles.uipanel_NameModulation = uibuttongroup(handles.(mfilename),...
    %         'Title','Name modulation',...
    %         'Units', 'Normalized',...
    %         'Position',[p_nm.x p_nm.y p_nm.w p_nm.h],...
    %         'BackgroundColor',figureBGcolor,...
    %         'Visible','on');
    %
    %     p_nm.nbO    = 5; % Number of objects
    %     p_nm.Ow     = 1/(p_nm.nbO + 1); % Object width
    %     p_nm.countO = 0; % Object counter
    %     p_nm.xposO  = @(countO) p_nm.Ow/(p_nm.nbO+1)*countO + (countO-1)*p_nm.Ow;
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Start
    %
    %     p_nm.countO = p_nm.countO + 1;
    %     r_start.x   = p_nm.xposO(p_nm.countO);
    %     r_start.y   = 0.1 ;
    %     r_start.w   = p_nm.Ow;
    %     r_start.h   = 0.8;
    %     r_start.tag = 'radiobutton_Start';
    %     handles.(r_start.tag) = uicontrol(handles.uipanel_NameModulation,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_start.x r_start.y r_start.w r_start.h],...
    %         'String','Start',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_start.tag,...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Pre
    %
    %     p_nm.countO = p_nm.countO + 1;
    %     r_pre.x   = p_nm.xposO(p_nm.countO);
    %     r_pre.y   = 0.1 ;
    %     r_pre.w   = p_nm.Ow;
    %     r_pre.h   = 0.8;
    %     r_pre.tag = 'radiobutton_Pre';
    %     handles.(r_pre.tag) = uicontrol(handles.uipanel_NameModulation,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_pre.x r_pre.y r_pre.w r_pre.h],...
    %         'String','Pre',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_pre.tag,...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : PrePost
    %
    %     p_nm.countO = p_nm.countO + 1;
    %     r_pre.x   = p_nm.xposO(p_nm.countO);
    %     r_pre.y   = 0.1 ;
    %     r_pre.w   = p_nm.Ow;
    %     r_pre.h   = 0.8;
    %     r_pre.tag = 'radiobutton_PrePost';
    %     handles.(r_pre.tag) = uicontrol(handles.uipanel_NameModulation,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_pre.x r_pre.y r_pre.w r_pre.h],...
    %         'String','PrePost',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_pre.tag,...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Post
    %
    %     p_nm.countO = p_nm.countO + 1;
    %     r_post.x   = p_nm.xposO(p_nm.countO);
    %     r_post.y   = 0.1 ;
    %     r_post.w   = p_nm.Ow;
    %     r_post.h   = 0.8;
    %     r_post.tag = 'radiobutton_Post';
    %     handles.(r_post.tag) = uicontrol(handles.uipanel_NameModulation,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_post.x r_post.y r_post.w r_post.h],...
    %         'String','Post',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_post.tag,...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : End
    %
    %     p_nm.countO = p_nm.countO + 1;
    %     r_stop.x   = p_nm.xposO(p_nm.countO);
    %     r_stop.y   = 0.1 ;
    %     r_stop.w   = p_nm.Ow;
    %     r_stop.h   = 0.8;
    %     r_stop.tag = 'radiobutton_End';
    %     handles.(r_stop.tag) = uicontrol(handles.uipanel_NameModulation,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_stop.x r_stop.y r_stop.w r_stop.h],...
    %         'String','End',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_stop.tag,...
    %         'BackgroundColor',figureBGcolor);
    
    
    %% Panel : Operation mode
    
    p_op.x = panelProp.xposP;
    p_op.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_op.y = panelProp.yposP(panelProp.countP);
    p_op.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_OperationMode = uibuttongroup(handles.(mfilename),...
        'Title','Operation mode',...
        'Units', 'Normalized',...
        'Position',[p_op.x p_op.y p_op.w p_op.h],...
        'BackgroundColor',figureBGcolor);
    
    p_op.nbO    = 3; % Number of objects
    p_op.Ow     = 1/(p_op.nbO + 1); % Object width
    p_op.countO = 0; % Object counter
    p_op.xposO  = @(countO) p_op.Ow/(p_op.nbO+1)*countO + (countO-1)*p_op.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Acquisition
    
    p_op.countO = p_op.countO + 1;
    r_aq.x = p_op.xposO(p_op.countO);
    r_aq.y = 0.1 ;
    r_aq.w = p_op.Ow;
    r_aq.h = 0.8;
    r_aq.tag = 'radiobutton_Acquisition';
    handles.(r_aq.tag) = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_aq.x r_aq.y r_aq.w r_aq.h],...
        'String','Acquisition',...
        'TooltipString','Should be used for all the environements',...
        'HorizontalAlignment','Center',...
        'Tag',r_aq.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : FastDebug
    
    p_op.countO = p_op.countO + 1;
    r_fd.x   = p_op.xposO(p_op.countO);
    r_fd.y   = 0.1 ;
    r_fd.w   = p_op.Ow;
    r_fd.h   = 0.8;
    r_fd.tag = 'radiobutton_FastDebug';
    handles.radiobutton_FastDebug = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_fd.x r_fd.y r_fd.w r_fd.h],...
        'String','FastDebug',...
        'TooltipString','Only to work on the scripts',...
        'HorizontalAlignment','Center',...
        'Tag',r_fd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : RealisticDebug
    
    p_op.countO = p_op.countO + 1;
    r_rd.x   = p_op.xposO(p_op.countO);
    r_rd.y   = 0.1 ;
    r_rd.w   = p_op.Ow;
    r_rd.h   = 0.8;
    r_rd.tag = 'radiobutton_RealisticDebug';
    handles.(r_rd.tag) = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_rd.x r_rd.y r_rd.w r_rd.h],...
        'String','RealisticDebug',...
        'TooltipString','Only to work on the scripts',...
        'HorizontalAlignment','Center',...
        'Tag',r_rd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    %% End of opening
    
    % IMPORTANT
    guidata(figHandle,handles)
    % After creating the figure, dont forget the line
    % guidata(figHandle,handles) . It allows smart retrive like
    % handles=guidata(hObject)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        assignin('base','handles',handles) %#ok<UNRCH>
        disp(handles)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figPtr = figHandle;
    
    
end

if nargout > 0
    
    varargout{1} = guidata(figPtr);
    
end


end % function


%% GUI Functions

% -------------------------------------------------------------------------
function edit_Seqeunce_Callback(hObject, ~)

NrTap = 8;

sequence_str = get(hObject,'String');

if length(sequence_str) ~= NrTap
    set(hObject,'String','')
    error('Sequence must be %d non consecutive numbers', NrTap)
end

sequence_vect = (  cellstr(sequence_str')' );
sequence_vect = cellfun(@str2double,sequence_vect);
if any(sequence_vect > 5  |  sequence_vect < 2  |  round(sequence_vect) ~= sequence_vect)
    set(hObject,'String','')
    error('Sequence must be numbers from 2 to 5 (positive integers)')
end

if any( diff(sequence_vect) == 0 )
    set(hObject,'String','')
    error('Sequence not have two identical consecutive numbers')
end

fprintf('Sequence OK : %s \n', sequence_str)

end % function

% -------------------------------------------------------------------------
function uipanel_EyelinkMode_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton_EyelinkOff'
        set(handles.pushbutton_EyelinkCalibration,'Visible','off')
        set(handles.pushbutton_IsConnected       ,'Visible','off')
        set(handles.pushbutton_ForceShutDown     ,'Visible','off')
        set(handles.pushbutton_Initialize        ,'Visible','off')
    case 'radiobutton_EyelinkOn'
        set(handles.pushbutton_EyelinkCalibration,'Visible','on')
        set(handles.pushbutton_IsConnected       ,'Visible','on')
        set(handles.pushbutton_ForceShutDown     ,'Visible','on')
        set(handles.pushbutton_Initialize        ,'Visible','on')
end

end % function
