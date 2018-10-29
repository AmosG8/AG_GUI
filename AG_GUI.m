function varargout = AG_GUI(varargin)
% 26 Jan 16 modified 6/March/2018  27/9/18

%varargout is an output variable in a function definition statement that
%allows the function to return any number of output arguments


% AG_GUI MATLAB code for AG_GUI.fig
%      AG_GUI, by itself, creates a new AG_GUI or raises the existing
%      singleton*.

%

%      H = AG_GUI returns the handle to a new AG_GUI or the handle to
%      the existing singleton*.
%
%      AG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AG_GUI.M with the given input arguments.
%
%      AG_GUI('Property','Value',...) creates a new AG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AG_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AG_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AG_GUI

% Last Modified by GUIDE v2.5 16-May-2017 18:20:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AG_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AG_GUI_OutputFcn, ...
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


% --- Executes just before AG_GUI is made visible.
function AG_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AG_GUI (see VARARGIN)

% Choose default command line output for AG_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AG_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AG_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%1. Make sure push buttons are not pressed, and counters display 0
set(handles.StopButton,'Value',0);
set(handles.Open_right,'Value',0);
set(handles.Open_left,'Value',0);
% displays
set (handles.Right_Licks_counter, 'string',0);
set (handles.Left_Licks_counter, 'string',0);
set(handles.LicksDisplay, 'string', '0');
set(handles.HitsDisplay, 'string', '0'); 
set (handles.Hits_Right, 'string',0);
set (handles.Hits_Left, 'string',0);
set(handles.GoDisplay, 'string', 0);
set(handles.TexturePresented, 'string', 0); 
set (handles.Current_Trial_Num, 'string', 0);
set(handles.Display_END, 'string', 'RUNNING');

%2. Collect all information that the USER has enetered
%2.1 transform sec to msec
params.SampleDuration = 1000* str2double(get(handles.Sample_Duration_Input,'String'));
params.RetentionDuration = 1000* str2double(get(handles.Retention_Duration_Input,'String'));
params.ResponseDuration = 1000* str2double(get(handles.Response_Duration_Input,'String'));
params.ITIDuration = 1000* str2double(get(handles.ITI_Duration_Input,'String'));
params.VacuumDuration = 1000* str2double(get(handles.Vacuum_Duration_Input,'String'));
params.ToneDuration = 1000* str2double(get(handles.Tone_Duration_Input,'String'));
params.PunishmentDuration = 1000* str2double(get(handles.Punishment_Duration_Input,'String'));
params.OpenWater=1000* str2double(get(handles.OpenWater,'String'));
%%2.2 numbers
params.Nchoices = str2double(get(handles.Last_N_Choices,'String'));
params.Nlicks = str2double(get(handles.Last_N_Licks,'String'));
params.N_Trials_Exp = str2double(get(handles.N_Trials_Input,'String'));
params.Stage2Repetitions=str2double(get(handles.Stage2_repetitions,'String'));
params.PinP=str2double(get(handles.PinP,'String')); %how many time to do punishment within punishment
params.Rotation_angle=str2double(get(handles.Rotation_angle,'String'));
params.Cue_Freqency=str2double(get(handles.Cue_Freqency,'String'));
%%2.3 strings
params.MouseName=get(handles.MouseID_Input,'String');
params.TrainingStages=get(handles.TrainingStagesPopDown,'Value');

% %tests for collecting the data provided by the USER
% fprintf ('sample duration is %d \n' ,params.SampleDuration); 

%%3. generate a file name in the format: "MouseID_Date_time", i.g: Miki_12Jan2011_14_41_19 
KeepMouseName=params.MouseName;
ExpTime=datestr(now); % => 12-Jan-2016 14:41:19
ExpTime=ExpTime(ExpTime~='-');  %12Jan2011 14:41:19
ExpTime=strrep(ExpTime, ' ', '_');%12Jan2011_14:41:19
ExpTime=strrep(ExpTime, ':', '_');%12Jan2011_14_41_19
params.MouseName=[params.MouseName,'_',ExpTime];%Miki_12Jan2016_14_52_45

%4. Open communication with the Arduino 
delete(instrfindall); % if any port is already opened by MATLAB its gonna find and close it
%s = serial ('/dev/tty.usbmodem1411');  % COM7 Port (for PB)
%global s;
s = serial ('COM3');   
s.BaudRate = 19200;    % the baud rate with which my data is received 115200
s.Terminator = 'LF';  %Since I am sending the data in a string format 
%I am basically sending an end character as carriage return '\r', 
%This script understands this as the end and considers all the data before this as the 
%acquired data
s.InputBufferSize=2^16;
fopen(s);  
pause(4);
% s.ReadAsyncMode = 'manual';
% readasync(s); 

%5. sending data to the Arduino
%5.1 change the 'training stage' from a number (1 or 2 or 3 or 4 or 5) to what
%the arduino expects: Z, A,B,C,D
switch (params.TrainingStages)
    case 1
        stage='Z'; %licking from the lick ports.
    case 2
        stage='A'; %Association between the cue and the water.
    case 3
        stage='B';% Association between S1 to R1, and S2 to R2.
    case 4
        stage='C';% Discrimination without delay.
    case 5
        stage='D';% Discrimination with delay.
end %of switch for experiment stage

%fprintf ('stage %s\n', stage ); 
%5.2 sending a 14 variables seq to Arduino

% A test for what I'm actually sending
% fprintf('%s,',stage);                   fprintf('%d,',params.N_Trials_Exp);
% fprintf('%d,',params.SampleDuration);    fprintf('%d,',params.RetentionDuration);
% fprintf('%d,',params.ResponseDuration);  fprintf('%d,',params.ITIDuration);
% fprintf('%d,',params.VacuumDuration);    fprintf('%d,',params.ToneDuration);
% fprintf('%d,',params.PunishmentDuration); fprintf('%d,',params.OpenWater); 
% fprintf('%d,',params.Stage2Repetitions);  fprintf('%d,',params.PinP); 
% fprintf('%d,',params.Rotation_angle);     fprintf('%d',params.Cue_Freqency);

fprintf(s,'%s,',stage);                    fprintf(s,'%d,',params.N_Trials_Exp);
fprintf(s,'%d,',params.SampleDuration);    fprintf(s,'%d,',params.RetentionDuration);
fprintf(s,'%d,',params.ResponseDuration);  fprintf(s,'%d,',params.ITIDuration);
fprintf(s,'%d,',params.VacuumDuration);    fprintf(s,'%d,',params.ToneDuration);
fprintf(s,'%d,',params.PunishmentDuration); fprintf(s,'%d,',params.OpenWater); 
fprintf(s,'%d,',params.Stage2Repetitions);  fprintf(s,'%d,',params.PinP); 
fprintf(s,'%d,',params.Rotation_angle);     fprintf(s,'%d \n',params.Cue_Freqency);

%%6 operation
global KEEP_READING;
KEEP_READING=1;

switch (params.TrainingStages)
    case 1 %sending Z to the Arduino
        %Once the user press 'start' the Arduino opens the valves for the
        %openning duration time. The valves are reopened after any lick
        %until the user press on Stop
        %display of time 

      %I'm saving the data:
      % 1st raw=time
      %2nd raw = R licks
      %3rd raw =L licks
      R_Licks=0; L_Licks=0;  %lick counters
      Table_counter=2;Table(1,1)=0;
        while KEEP_READING
            arduinoMessage = readAndParseArduionoSerialMessage(s);
            %check if message has content
                    if numel(arduinoMessage)>0
                      ExperimentTime=arduinoMessage.experimentElapsedTime/60000;%convert from msec to min
                      set (handles.ElapsedTime, 'string',ExperimentTime);
                      set(handles.SpeedDisplay, 'string',...
                          arduinoMessage.carrouselVelocityMeterPerSec);
                      if arduinoMessage.lickEventCorrectTiming ==1
                         %at this stage the
                          %side of the lick is sent within this variable
                          R_Licks=R_Licks+1;
                          set (handles.Right_Licks_counter, 'string',R_Licks);
                          Table(1,Table_counter)=arduinoMessage.experimentElapsedTime;
                          Table(2,Table_counter)=1; Table(3,Table_counter)=0;
                          Table_counter=Table_counter+1;
                      elseif arduinoMessage.lickEventCorrectTiming ==2
                          L_Licks=L_Licks+1;
                          set (handles.Left_Licks_counter, 'string',L_Licks);
                          Table(1,Table_counter)=arduinoMessage.experimentElapsedTime;
                          Table(3,Table_counter)=1; Table(2,Table_counter)=0;
                          Table_counter=Table_counter+1;
                      end %of if there was a lick
                    end %of if there's content in the message
             KEEP_READING= ~get(handles.StopButton,'Value');
             if ~KEEP_READING %stop
                    stage='S';
                    fprintf(s,'%s',stage); 
                    pause(0.001);
                    delete(instrfindall);
             end
        pause(0.0001);
        end %of while
     
   
    case {2} %arduino receives A
    %%There's an ITI that ends when the mouse licks
    % then there's a Response time in which  the water valve isn't
    % opened again
    %count licks and amake a table as before, plus another row: 
    %4th for ITI- 0 for licks in Response time 1 for licks in ITI
      R_Licks=0; L_Licks=0;  %lick counters
      Table_counter=2;Table(1,1)=0;
      ReceivedDataFilename=['Received_', params.MouseName];
      Table_Filename=['Table_', params.MouseName];
            
        while KEEP_READING
            arduinoMessage = readAndParseArduionoSerialMessage(s);
            ReceivedData(arduinoMessage.messageId)=arduinoMessage; 
                    if numel(arduinoMessage)>0 %check if message has content
                      ExperimentTime=arduinoMessage.experimentElapsedTime/60000;%convert from msec to min
                      set (handles.ElapsedTime, 'string',ExperimentTime);
                      set(handles.SpeedDisplay, 'string',...
                        arduinoMessage.carrouselVelocityMeterPerSec);
                      set(handles.Stage_of_Trial, 'string', arduinoMessage.trailStage);
                      if strcmp(arduinoMessage.trailStage,'It') %0 if aren't the same 1 is the same
                          ITI=1;
                      else ITI=0;
                      end
                      if arduinoMessage.lickEventCorrectTiming ==2 %at this stage the
                          %side of the lick is sent within this variable
                            %27-9-18 bug fix AG changed from 1 to 2 
                          R_Licks=R_Licks+1;
                          set (handles.Right_Licks_counter, 'string',R_Licks);
                          Table(1,Table_counter)=arduinoMessage.experimentElapsedTime;
                          Table(2,Table_counter)=1; Table(3,Table_counter)=0;
                          Table(4,Table_counter)=ITI;
                          Table_counter=Table_counter+1;
                      elseif arduinoMessage.lickEventCorrectTiming ==1
                          L_Licks=L_Licks+1;
                          set (handles.Left_Licks_counter, 'string',L_Licks);
                          Table(1,Table_counter)=arduinoMessage.experimentElapsedTime;
                          Table(3,Table_counter)=1; Table(2,Table_counter)=0;
                          Table(4,Table_counter)=ITI;
                          Table_counter=Table_counter+1;
                      end %of if there was a lick
                    end %of if there's content in the message
%save(ReceivedDataFilename,'ReceivedData'); 
             %save(Table_Filename,'Table');  Sep-18
             KEEP_READING= ~get(handles.StopButton,'Value');
             if ~KEEP_READING %stop
                stage='S';
                fprintf(s,'%s',stage); 
                pause(0.001);
                delete(instrfindall);
             end
        pause(0.0001);
       save(ReceivedDataFilename,'ReceivedData');   %8-3-18
       %save(Table_Filename,'Table'); Sep-18
        end %of while
        ReceivedData(1).('parmatrers') = params;%AG added 9-Oct-18
       save(ReceivedDataFilename,'ReceivedData');   
       %save(Table_Filename,'Table'); Sep-18
%%
    case 3 %Sending B to the Arduino
           %Association between S1 to R1, and between S2 to R2.

        %There is a Sample time, and a short ITI
        %During the Sample time a texture is presented and if the mouse licks
        %at the correct side it receives reward
        %Need sometimes to open a specific valve manually without a lick.
     R_Licks=0; L_Licks=0;  %lick counters
     Table_counter=2;
     Table={};
     Table(1,1)={'Time'};
     Table(2,1)={'2 R lick'};
     Table(3,1)={'1 L lick'};
     Table(4,1)={'ITI'};
     Table(5,1)={'S'};
     Table(6,1)={'OpenR'};
     Table(7,1)={'OpenL'};
     L_Hits=0; R_Hits=0; 
     TrialCounter=0; 
     ReceivedDataFilename=['Received_', params.MouseName];
     Table_Filename=['Table_', params.MouseName];
        while KEEP_READING
            %if the user has clicked on openning a lick port, send to the
            %Arduino the releveant command
            OpenR=0; OpenL=0;
            if get(handles.Open_right,'Value')==1
              fprintf(s,'R');
              OpenR=1;
              set(handles.Open_right,'Value',0);
            end
            if get(handles.Open_left,'Value')==1
              fprintf(s,'L');
              OpenL=1;
              set(handles.Open_left,'Value',0);
            end
            %read a message from the Arduino     
            arduinoMessage = readAndParseArduionoSerialMessage(s);
            ReceivedData(arduinoMessage.messageId)=arduinoMessage; 
            if numel(arduinoMessage)>0 %check if message has content
                  ExperimentTime=arduinoMessage.experimentElapsedTime/60000;%convert from msec to min
                  set (handles.ElapsedTime, 'string',ExperimentTime);
                  set(handles.SpeedDisplay, 'string',...
                    arduinoMessage.carrouselVelocityMeterPerSec);
                  set(handles.Stage_of_Trial, 'string', arduinoMessage.trailStage);
                  set(handles.TexturePresented, 'string', arduinoMessage.thisTrialTexture); 
                  if arduinoMessage.trialBeginningEvent == 2 %end of the experiment
                      KEEP_READING =0;
                  elseif arduinoMessage.trialBeginningEvent ==1
                        TrialCounter=TrialCounter+1;
                        set(handles.Current_Trial_Num, 'string', TrialCounter);
                  end 

                      %Making a table of licks and of openning water valves by the
                      %user
                      
                      %1. extract from the data if the lick is at right or
                      %left port
                      %2. calculate for each lick in the Sample time if it was hit/miss 
                      %and if it was a hit for port 1 or for fort 2
                  if strcmp(arduinoMessage.trailStage,'It') %0 if the two strings aren't 
                      %the same 1 is if the same
                      ITI=1;
                  else ITI=0;
                  end

                  if arduinoMessage.thisTrialTexture==1
                      Sone=1;
                  else
                      Sone=2;
                  end

                  if (arduinoMessage.lickEventCorrectPort ==1 && arduinoMessage.thisTrialTexture==1)
                      %there was a correct lick at 1(left)
                      L_Licks=L_Licks+1; 
                      set(handles.Left_Licks_counter, 'string',L_Licks);
                      Table(1,Table_counter)={ExperimentTime};
                      Table(2,Table_counter)={0};
                      Table(3,Table_counter)={1};
                      Table(4,Table_counter)={ITI};
                      Table(5,Table_counter)={Sone};
                      Table(6,Table_counter)={OpenR};
                      Table(7,Table_counter)={OpenL};
                      Table_counter=Table_counter+1;
                      if arduinoMessage.lickEventCorrectTiming ==1
                          L_Hits=L_Hits+1;
                          set(handles.Hits_Left, 'string',L_Hits);
                      end
                  elseif(arduinoMessage.lickEventCorrectPort ==2 && arduinoMessage.thisTrialTexture==2) 
                      %there was an incorrect lick at 1(left)
                      L_Licks = L_Licks+1; 
                      set (handles.Left_Licks_counter, 'string',L_Licks);
                      Table(1,Table_counter)={ExperimentTime};
                      Table(2,Table_counter)={0};%right lick
                      Table(3,Table_counter)={1};%left lick
                      Table(4,Table_counter)={ITI};
                      Table(5,Table_counter)={Sone};
                      Table(6,Table_counter)={OpenR};
                      Table(7,Table_counter)={OpenL};
                      Table_counter=Table_counter+1;

                  elseif (arduinoMessage.lickEventCorrectPort ==1 && arduinoMessage.thisTrialTexture==2)
                      %there was a correct lick at 2(right)
                      R_Licks=R_Licks+1; 
                      set(handles.Right_Licks_counter, 'string',R_Licks);
                      Table(1,Table_counter)={ExperimentTime};
                      Table(2,Table_counter)={1};%right lick
                      Table(3,Table_counter)={0};%left lick
                      Table(4,Table_counter)={ITI};
                      Table(5,Table_counter)={Sone};
                      Table(6,Table_counter)={OpenR};
                      Table(7,Table_counter)={OpenL};
                      Table_counter=Table_counter+1;
                      if arduinoMessage.lickEventCorrectTiming ==1
                          R_Hits=R_Hits+1;
                          set(handles.Hits_Right, 'string',R_Hits);
                      end
                  elseif (arduinoMessage.lickEventCorrectPort ==2 && arduinoMessage.thisTrialTexture==1)
                      %there was an incorrect lick at 2(right)
                      R_Licks=R_Licks+1;
                      set (handles.Right_Licks_counter, 'string',R_Licks);
                      Table(1,Table_counter)={ExperimentTime};
                      Table(2,Table_counter)={1};%right lick
                      Table(3,Table_counter)={0};%left lick
                      Table(4,Table_counter)={ITI};
                      Table(5,Table_counter)={Sone};
                      Table(6,Table_counter)={OpenR};
                      Table(7,Table_counter)={OpenL};
                      Table_counter=Table_counter+1;
                  elseif (arduinoMessage.lickEventCorrectPort ==0 && (OpenR+OpenL)>0)
                      %there was no lick but the user opened a valve
                      Table(1,Table_counter)={ExperimentTime};
                      Table(2,Table_counter)={0};%right lick
                      Table(3,Table_counter)={0};%left lick
                      Table(4,Table_counter)={ITI};
                      Table(5,Table_counter)={Sone};
                      Table(6,Table_counter)={OpenR};
                      Table(7,Table_counter)={OpenL};
                      Table_counter=Table_counter+1;
                  end
            end %there was content in the message
         %save(Table_Filename,'Table'); Sep-18
         save(ReceivedDataFilename,'ReceivedData'); 
         KEEP_READING= ~get(handles.StopButton,'Value');
         if ~KEEP_READING %stoping
                stage='S';
                fprintf(s,'%s',stage); 
                pause(0.001);
                delete(instrfindall);
         end
        pause(0.0001);
        if TrialCounter == params.N_Trials_Exp %AG 8-3-18
            KEEP_READING=0;
        end
            
        end %of while 

        ReceivedDataFilename=['Received_', params.MouseName];
        save(ReceivedDataFilename,'ReceivedData'); 
        Table_Filename=['Table_', params.MouseName];
        save(Table_Filename,'Table');
%%
    case 4 %discrimination with no delay %%Sending C
       %Association between S1 to R1, and between S2 to R2.
        %SAME CODE AS FOR CASE 3 - all the differences are in the Arduino
        %There is a Sample time, and a short ITI
        %During the Sample time a texture is presented and if the mouse licks
        %at the correct side it receives reward
        %Need sometimes to open a specific valve manually without a lick.
        R_Licks=0; L_Licks=0;  %lick counters
        Table_counter=2;Table(1,1)=0;
        L_Hits=0; R_Hits=0; 
        TrialCounter=0; 
        ReceivedDataFilename=['Received_', params.MouseName];%AG moved from after the while loop 
        Table_Filename=['Table_', params.MouseName];%AG moved from after the while loop
        while KEEP_READING
            %if the user has clicked on openning a lick port, send to the
            %Arduino the releveant command
            OpenR=0; OpenL=0;
            if get(handles.Open_right,'Value')==1
              fprintf(s,'R');
              OpenR=1;
              set(handles.Open_right,'Value',0);
            end
            if get(handles.Open_left,'Value')==1
              fprintf(s,'L');
              OpenL=1;
              set(handles.Open_left,'Value',0);
            end
            %read a message from the Arduino     
            arduinoMessage = readAndParseArduionoSerialMessage(s);
            ReceivedData(arduinoMessage.messageId)=arduinoMessage; 
            if numel(arduinoMessage)>0 %check if message has content line 463
                  ExperimentTime=arduinoMessage.experimentElapsedTime/60000;%convert from msec to min
                  set (handles.ElapsedTime, 'string',ExperimentTime);
                  set(handles.SpeedDisplay, 'string',...
                    arduinoMessage.carrouselVelocityMeterPerSec);
                  set(handles.Stage_of_Trial, 'string', arduinoMessage.trailStage);
                  set(handles.TexturePresented, 'string', arduinoMessage.thisTrialTexture); 
                  if arduinoMessage.trialBeginningEvent == 2 %end of the experiment
                      KEEP_READING =0;
                  elseif arduinoMessage.trialBeginningEvent ==1
                        TrialCounter=TrialCounter+1;
                        set(handles.Current_Trial_Num, 'string', TrialCounter);
                  end 

                      %Making a table of licks and of openning water valves by the
                      %user
                      
                      %1. extract from the data if the lick is at right or
                      %left port
                      %2. calculate for each lick in the Sample time if it was hit/miss 
                      %and if it was a hit for port 1 or for fort 2
                  if strcmp(arduinoMessage.trailStage,'It') %0 if the two strings aren't 
                      %the same 1 is if the same
                      ITI=1;
                  else ITI=0;
                  end

                  if arduinoMessage.thisTrialTexture==1
                      Sone=1;
                  else
                      Sone=2;
                  end

                  if (arduinoMessage.lickEventCorrectPort ==1 && arduinoMessage.thisTrialTexture==1)
                      %there was a correct lick at 1(left)
                      L_Licks=L_Licks+1; 
                      set(handles.Left_Licks_counter, 'string',L_Licks);
                      Table(1,Table_counter)=ExperimentTime;
                      Table(2,Table_counter)=0;
                      Table(3,Table_counter)=1;
                      Table(4,Table_counter)=ITI;
                      Table(5,Table_counter)=Sone;
                      Table(6,Table_counter)=OpenR;
                      Table(7,Table_counter)=OpenL;
                      Table_counter=Table_counter+1;
                      if arduinoMessage.lickEventCorrectTiming ==1
                          L_Hits=L_Hits+1;
                          set(handles.Hits_Left, 'string',L_Hits);
                      end
                  elseif(arduinoMessage.lickEventCorrectPort ==2 && arduinoMessage.thisTrialTexture==2) 
                      %there was an incorrect lick at 1(left)
                      L_Licks = L_Licks+1; 
                      set(handles.Left_Licks_counter, 'string',L_Licks);
                      Table(1,Table_counter)=ExperimentTime;
                      Table(2,Table_counter)=0;%right lick
                      Table(3,Table_counter)=1;%left lick
                      Table(4,Table_counter)=ITI;
                      Table(5,Table_counter)=Sone;
                      Table(6,Table_counter)=OpenR;
                      Table(7,Table_counter)=OpenL;
                      Table_counter=Table_counter+1;

                  elseif(arduinoMessage.lickEventCorrectPort ==1 && arduinoMessage.thisTrialTexture==2)
                      %there was a correct lick at 2(right)
                      R_Licks=R_Licks+1; 
                      set(handles.Right_Licks_counter, 'string',R_Licks);
                      Table(1,Table_counter)=ExperimentTime;
                      Table(2,Table_counter)=1;%right lick
                      Table(3,Table_counter)=0;%left lick
                      Table(4,Table_counter)=ITI;
                      Table(5,Table_counter)=Sone;
                      Table(6,Table_counter)=OpenR;
                      Table(7,Table_counter)=OpenL;
                      Table_counter=Table_counter+1;
                      if arduinoMessage.lickEventCorrectTiming ==1
                          R_Hits=R_Hits+1;
                          set(handles.Hits_Right, 'string',R_Hits);
                      end
                  elseif(arduinoMessage.lickEventCorrectPort ==2 && arduinoMessage.thisTrialTexture==1)
                      %there was an incorrect lick at 2(right)
                      R_Licks=R_Licks+1;
                      set(handles.Right_Licks_counter, 'string',R_Licks);
                      Table(1,Table_counter)=ExperimentTime;
                      Table(2,Table_counter)=1;%right lick
                      Table(3,Table_counter)=0;%left lick
                      Table(4,Table_counter)=ITI;
                      Table(5,Table_counter)=Sone;
                      Table(6,Table_counter)=OpenR;
                      Table(7,Table_counter)=OpenL;
                      Table_counter=Table_counter+1;
                  elseif(arduinoMessage.lickEventCorrectPort ==0 && (OpenR+OpenL)>0)
                      %there was no lick but the user opened a valve
                      Table(1,Table_counter)=ExperimentTime;
                      Table(2,Table_counter)=0;%right lick
                      Table(3,Table_counter)=0;%left lick
                      Table(4,Table_counter)=ITI;
                      Table(5,Table_counter)=Sone;
                      Table(6,Table_counter)=OpenR;
                      Table(7,Table_counter)=OpenL;
                      Table_counter=Table_counter+1;
                  end
             end %there was content in the message 

         KEEP_READING= ~get(handles.StopButton,'Value');
         if ~KEEP_READING %stoping
                stage='S';
                fprintf(s,'%s',stage); 
                pause(0.001);
                delete(instrfindall);
         end
        if TrialCounter == params.N_Trials_Exp %AG 8-3-18
            KEEP_READING=0;
        end
        pause(0.0001);
        save(ReceivedDataFilename,'ReceivedData'); %8-3-18 moved from after trhe end of the while to before
        save(Table_Filename,'Table');
        end %of while 

    case 5    %sending D  discrimination learning
    NumberofTrials=0;
    TotalLicks=0;
    GoCounter=0;
%     textureOne=0;
%     textureTwo=0;
   %KEEP_READING is set to 1 already at line 119
   
   while KEEP_READING     % reading data loop starts here
        arduinoMessage = readAndParseArduionoSerialMessage(s);        
        if numel(arduinoMessage)>0 %check if message has content
            %save all messages from Arduino into filename: mouseName_date_time
            ReceivedData(arduinoMessage.messageId)=arduinoMessage; 
            
            set(handles.SpeedDisplay, 'string',...
                arduinoMessage.carrouselVelocityMeterPerSec);

            switch arduinoMessage.trialBeginningEvent
                %1=new trial;2-End of experiment ;0=none
                case 1 %a new trial
                    set(handles.Stage_of_Trial, 'string', 'Sample');
                    set(handles.TexturePresented, 'string', arduinoMessage.thisTrialTexture);
                    NumberofTrials=NumberofTrials+1;%counting trials
                    set (handles.Current_Trial_Num, 'string', NumberofTrials);
%                     if arduinoMessage.thisTrialTexture==1
%                         textureOne=textureOne+1;
%                     elseif arduinoMessage.thisTrialTexture==2
%                         textureTwo=textureTwo+1;
%                     end
                    if NumberofTrials ==1 %at 1st time
                        arduinoMessage.Mouse=params.MouseName;%adding " mouse_Date " 
                    else
                        %GoNoGoM columns are trials
                        % row 1 is 0 for no-go, 1 for go
                        % row 2 is texture presented for a go trial
                        % row 3 is the time of go
                        GoNoGoM(1,NumberofTrials)=FlagGo;
                        if FlagGo
                            GoNoGoM(2,NumberofTrials)=GoTexture;
                            GoNoGoM(3,NumberofTrials)= GoTime;
                        else
                            GoNoGoM(2,NumberofTrials)= 0;
                            GoNoGoM(3,NumberofTrials)= 0;
                        end
                       %display of hits and of total go
                        TotalGo=sum(GoNoGoM(1,:));
                        set(handles.GoDisplay, 'string', TotalGo);
                                                
                        %plot percent Go across N last trials
%                         if NumberofTrials > params.Nchoices
%                             axes(handles.GoTrialsPlot);
%                             plot (GoNoGoM (1,(NumberofTrials-params.Nchoices)...
%                             :NumberofTrials));
%                         end %of if for making percent Go Plot 

                      %plot percent Go across N last trials along the whole experiemt                   
                         if mod(NumberofTrials,params.Nchoices)>0
                             LastGoValues(mod(NumberofTrials,params.Nchoices))...
                                 =GoNoGoM(1,NumberofTrials);
                         else  %mod(NumberofTrials,params.Nchoices)=0 
                                     LastGoValues(params.Nchoices)...
                                        =GoNoGoM(NumberofTrials);
                         end                        
                         if length(LastGoValues) == params.Nchoices
                            GoPlotIndex=NumberofTrials-params.Nchoices+1;
                            GoPlot(GoPlotIndex)=mean(LastGoValues);
                            axes(handles.GoTrialsPlot);
                            plot (GoPlot); 
                         end       
                        
                        %calculate data for time-correct licks plot across
                        %trials
                        PercentCorrectTimeLicksPerTrial(NumberofTrials) = CorrectTimeLicksPerTrial...
                        / TotalLicks*100;
                    
                    end  %for else corresponding to NumberofTrials ==1
                   %reaching here in every new trial, AFTER using FlagGo
                    FlagGo=0;
                    
                    %Plot of percent correct lick timing within the last N
                    %trials
                   if NumberofTrials > params.Nlicks
                      axes(handles.Plot_Lick_Timing);
                      plot (PercentCorrectTimeLicksPerTrial( (NumberofTrials-params.Nlicks)...
                          :NumberofTrials));
                   end %of if for making Corrcet-time- Licks plot 
                   IncorrectTimeLicksPerTrial=0;
                   CorrectTimeLicksPerTrial=0;
                   
                case 0 %if we are here, there was a lick and/or a new stage in the trial.
                        switch (arduinoMessage.trailStage)
                        %replace the 2 chars in the Aruino message with 
                        %the full name of that stage in the trial
                        case 'Sa'
                            arduinoMessage.trailStage = 'Sample';
                            stage=1; %this if for LickMatrix because...
                                    %enetring a string into the matrix is a 
                                    %problem. Could use a cell array instead
                        case 'Re'
                            arduinoMessage.trailStage = 'Retention';
                            stage=2;
                        case 'Rr'
                            arduinoMessage.trailStage = 'Response';
                            stage=3;
                        case 'Pu'
                            arduinoMessage.trailStage = 'Punishment';
                            stage=4;
                        case 'It'
                            arduinoMessage.trailStage = 'I T I';
                            stage=5;
                        end %of switch for replacing the string in the trial stage
                        set(handles.Stage_of_Trial, 'string', arduinoMessage.trailStage);

                        switch (arduinoMessage.lickEventCorrectTiming) %lick analysis
                        case 0 %no lick;   %2 incorrect time; 1 corect time
                            
                            %if there's a lick (cases 2 or 1)
                            %making a LickMatrix in which each lick is a
                            %column
                            %1st row is correct(1) or incorrect (0) time
                            %2nd row time of the lick from Ex begining
                            %3rd row is trial number
                            %4th row is trial stage
                            %5th row is texture 
                            
                        case 2 %lick outside of response time
                            TotalLicks=TotalLicks+1;
                            IncorrectTimeLicksPerTrial=IncorrectTimeLicksPerTrial+1;
                            LicksMatrix(1,TotalLicks)=0;
                            LicksMatrix(2,TotalLicks)= arduinoMessage.experimentElapsedTime;
                            LicksMatrix(3,TotalLicks)= NumberofTrials;
                            LicksMatrix(4,TotalLicks)= stage;
                            LicksMatrix(5,TotalLicks)=arduinoMessage.thisTrialTexture;

                          %make a plot if there have been enough licks
                          %for percent of time-correct licks out of X last
                          %licks. This is an alternative to ploting percent
                          %of time-correct licks in the last X trials
                              

                        case 1 %lick within the response time
                            % a go trial;

                            TotalLicks=TotalLicks+1;
                            CorrectTimeLicksPerTrial=CorrectTimeLicksPerTrial+1;
                            LicksMatrix(1,TotalLicks)=1;
                            LicksMatrix(2,TotalLicks)= arduinoMessage.experimentElapsedTime;
                            LicksMatrix(3,TotalLicks)= NumberofTrials;
                            LicksMatrix(4,TotalLicks)= stage;
                            LicksMatrix(5,TotalLicks)= arduinoMessage.thisTrialTexture;
                                                        
                             %make a plot if there have been enough licks
%                              if TotalLicks > params.Nlicks
%                                  plot (LicksMatrix(1,NumberofTrials-params.Nlicks :...
%                                      NumberofTrials)); 
%                              end %of the if there have been enough trials for making a plot
                            if arduinoMessage.lickEventIsFirstInResponseTime ==1                             
             %creating a matrix named: HitOrMiss. Columns are trial numbers, 
             % 1st row: 1 for a hit and 0 for a miss
             % 2nd row: time of trial begining as time from the begining of the expriemnt
             %3rd row - texture  
                                FlagGo=1;
                                GoCounter=GoCounter+1;
                                GoTime=arduinoMessage.experimentElapsedTime;%need to remember for the next trial
                                GoTexture=arduinoMessage.thisTrialTexture; %need to remember for the next trial
                                if arduinoMessage.lickEventCorrectPort ~=1
                                    AtPort=0;
                                else
                                    AtPort=1;
                                end
                                HitOrMiss(1,GoCounter)=AtPort;
                                HitOrMiss(2,GoCounter)=arduinoMessage.experimentElapsedTime;
                                HitOrMiss(3,GoCounter)=arduinoMessage.thisTrialTexture;
                                HitsN=sum(HitOrMiss(1,:));
                                set(handles.HitsDisplay, 'string', HitsN);
                                %populate the vecotr Last_N_Values with Hit
                                %(1) or miss (0) for the user defined last N trials
                                %first value in first value out
                                if mod(GoCounter,params.Nchoices)>0    
                                    Last_N_Values(mod(GoCounter,params.Nchoices))...
                                        =arduinoMessage.lickEventCorrectPort;
                                else  %when mod (GoCounter , params.Nchoices)=0 
                                     Last_N_Values(params.Nchoices)...
                                        =arduinoMessage.lickEventCorrectPort;
                                end
                                if length(Last_N_Values) == params.Nchoices
                                    DiscPlotIndex=GoCounter-params.Nchoices+1;
                                    DiscPlot(DiscPlotIndex)=mean(Last_N_Values);
                                    axes(handles.PlotDiscrimination);
                                    plot (DiscPlot); 
                                end
                                %MessageDone=1;
                                
                            end %of if for checking if the lick was 1st within the response time
                        end %of switch for lick within the response time
                        set(handles.LicksDisplay, 'string', TotalLicks);
                  case 2 %for switch of 'is it begining of a trial
                  %2 means this is the END of the Experiment
                  arduinoMessage.trialBeginningEvent='END'; %Display 'end'
                  set(handles.Display_END, 'string', arduinoMessage.trialBeginningEvent);
                  
                  %FOR SIMULATED DATA THE NEXT LINE SHOULD BE COMMENTED
                  KEEP_READING=0; %go out of the reading data loop 
            end %of switch for cases trial begining, End of experiment, New trial-stage/Lick

            ExperimentTime=arduinoMessage.experimentElapsedTime/60000;%convert from msec to min
            set (handles.ElapsedTime, 'string', ExperimentTime);

        end %got a non empty message
        if KEEP_READING %at end of experiemnt KEEP_READING= 0 
            KEEP_READING=~get(handles.StopButton,'Value');%before pushed StopButton=0
             if KEEP_READING==0
                    stage='S';
                    fprintf(s,'%s',stage); 
                    pause(0.001);
                    delete(instrfindall);
             end
        end
   pause(0.0001);
   end %of while reading
   ReceivedDataFilename=['Received_', params.MouseName];
   save(ReceivedDataFilename,'ReceivedData');        
            
   %saving the 3 matrixes
    GoNoGoM_Filename=['GoNoGoM_', params.MouseName];
    save(GoNoGoM_Filename,'GoNoGoM');

    LickMatrix_Filename=['LickMatrix_', params.MouseName];
    save(LickMatrix_Filename,'LicksMatrix');

    HitOrMiss_Filename=['HitOrMiss_', params.MouseName];
    save(HitOrMiss_Filename,'HitOrMiss');
end %of switch for traing types. 

%fclose (s);  % closing COM port
delete (s);   % deleting serial port object


% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global KEEP_READING;
%global stage

%handles.StopButton_Callback='Value';
%set(handles.StopButton,'UserData',true);

% --- Executes on button press in MotorOne.
function MotorOne_Callback(hObject, eventdata, handles)
% hObject    handle to MotorOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MotorTwo.
function MotorTwo_Callback(hObject, eventdata, handles)
% hObject    handle to MotorTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Last_N_Choices_Callback(hObject, eventdata, handles)
% hObject    handle to Last_N_Choices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Last_N_Choices as text
%        str2double(get(hObject,'String')) returns contents of Last_N_Choices as a double


% --- Executes during object creation, after setting all properties.
function Last_N_Choices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Last_N_Choices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Last_N_Licks_Callback(hObject, eventdata, handles)
% hObject    handle to Last_N_Licks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Last_N_Licks as text
%        str2double(get(hObject,'String')) returns contents of Last_N_Licks as a double


% --- Executes during object creation, after setting all properties.
function Last_N_Licks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Last_N_Licks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function N_Trials_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N_Trials_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Response_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Response_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Response_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Response_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Response_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Response_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ITI_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to ITI_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ITI_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of ITI_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function ITI_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ITI_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Vacuum_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Vacuum_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Vacuum_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Vacuum_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Vacuum_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Vacuum_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Punishment_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Punishment_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Punishment_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Punishment_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Punishment_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Punishment_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tone_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Tone_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tone_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Tone_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Tone_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tone_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MouseID_Input_Callback(hObject, eventdata, handles)
% hObject    handle to MouseID_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MouseID_Input as text
%        str2double(get(hObject,'String')) returns contents of MouseID_Input as a double


% --- Executes during object creation, after setting all properties.
function MouseID_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MouseID_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Sample_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Sample_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sample_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Sample_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Sample_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sample_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Retention_Duration_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Retention_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Retention_Duration_Input as text
%        str2double(get(hObject,'String')) returns contents of Retention_Duration_Input as a double


% --- Executes during object creation, after setting all properties.
function Retention_Duration_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Retention_Duration_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function N_Trials_Input_Callback(hObject, eventdata, handles)
% hObject    handle to N_Trials_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N_Trials_Input as text
%        str2double(get(hObject,'String')) returns contents of N_Trials_Input as a double


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SaveBotton_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SaveBotton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% H=AG_GUI;
% uisave(H,'filename');
% [filename, pathname] = uiputfile({'*.jpg;*.tif;*.png;*.gif' ,'All Image Files';...
%           '*.*','All Files'},'Save Image',...
%           'C:\Work\kofiko.jpg');
% 
% [filename, pathname] = uiputfile('Save file name');

% --- Executes on selection change in PopUp_END.
function PopUp_END_Callback(hObject, eventdata, handles)
% hObject    handle to PopUp_END (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopUp_END contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopUp_END


% --- Executes during object creation, after setting all properties.
function PopUp_END_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopUp_END (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExperimentEnd_DisplayEND_Callback(hObject, eventdata, handles)
% hObject    handle to ExperimentEnd_DisplayEND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExperimentEnd_DisplayEND as text
%        str2double(get(hObject,'String')) returns contents of ExperimentEnd_DisplayEND as a double


% --- Executes during object creation, after setting all properties.
function ExperimentEnd_DisplayEND_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExperimentEnd_DisplayEND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function TrainingStages_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to TrainingStages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in TrainingStagesPopDown.
function TrainingStagesPopDown_Callback(hObject, eventdata, handles)
% hObject    handle to TrainingStagesPopDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TrainingStagesPopDown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TrainingStagesPopDown


% --- Executes during object creation, after setting all properties.
function TrainingStagesPopDown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrainingStagesPopDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Arduino_Com.
function Arduino_Com_Callback(hObject, eventdata, handles)
% hObject    handle to Arduino_Com (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

USBport = 'COM4';%Identify the serial port and change the number
obj=serial(USBport); %Create the serial object
obj.BaudRate=19200;
obj.Terminator='CR'; % Termination character for data sequences
obj.ByteOrder='bigEndian'; % The byte order is important for interpreting binary data
obj.BaudRate=19200;
obj.Terminator='CR'; % Termination character for data sequences
obj.ByteOrder='bigEndian';%Byte order is important for interpreting binary data

if strcmp(obj.Status,'closed'), fopen(obj); end %open the serial port objec
% Send a command. The terminator character set above will be appended.
% % fprintf(obj,'WAKEUP');
% % 
% % % Read the response
% % response = fscanf(obj);
obj.InputBufferSize=2^18; % in bytes
obj.BytesAvailableFcnMode='byte';
obj.BytesAvailableFcnCount=2^10; % 1 kB of data
obj.BytesAvailableFcn = {@getNewData,arg1};
obj.UserData.newData=[];
obj.UserData.isNew=0;
fprintf(obj,'STOP');%  stop data transmission
% flush the input buffer
ba=get(obj,'BytesAvailable');
if ba > 0, fread(mr,ba); end

% Close the serial port
fclose(obj);
delete(obj);

return

% For ASCII data, you might still use fread with format of 'char', so that
%  you do not have to handle the termination characters.
[Dnew, Dcount, Dmsg]=fread(obj);
% Return the data to the main loop for plotting/processing
if obj.UserData.isNew==0
    % indicate that we have new data
    obj.UserData.isNew=1; 
    obj.UserData.newData=Dnew;
else
    % If the main loop has not had a chance to process the previous batch
    % of data, then append this new data to the previous "new" data
    obj.UserData.newData=[obj.UserData.newData Dnew];
end


return


%% Loop Control Function
function [] = stopStream(src,evnt)
% STOPSTREAM is a local function that stops the main loop by setting the
%  global variable to 0 when the user presses return.
global PLOTLOOP;

if strcmp(evnt.Key,'return')
    PLOTLOOP = 0;
    fprintf(1,'Return key pressed.');
end



function Display_END_Callback(hObject, eventdata, handles)
% hObject    handle to Display_END (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Display_END as text
%        str2double(get(hObject,'String')) returns contents of Display_END as a double


% --- Executes during object creation, after setting all properties.
function Display_END_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Display_END (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HitsDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to HitsDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HitsDisplay as text
%        str2double(get(hObject,'String')) returns contents of HitsDisplay as a double


% --- Executes during object creation, after setting all properties.
function HitsDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HitsDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GoDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to GoDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GoDisplay as text
%        str2double(get(hObject,'String')) returns contents of GoDisplay as a double


% --- Executes during object creation, after setting all properties.
function GoDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GoDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LicksDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to LicksDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LicksDisplay as text
%        str2double(get(hObject,'String')) returns contents of LicksDisplay as a double


% --- Executes during object creation, after setting all properties.
function LicksDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LicksDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TexturePresented_Callback(hObject, eventdata, handles)
% hObject    handle to TexturePresented (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TexturePresented as text
%        str2double(get(hObject,'String')) returns contents of TexturePresented as a double


% --- Executes during object creation, after setting all properties.
function TexturePresented_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TexturePresented (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SpeedDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to SpeedDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpeedDisplay as text
%        str2double(get(hObject,'String')) returns contents of SpeedDisplay as a double


% --- Executes during object creation, after setting all properties.
function SpeedDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpeedDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Open_left.
function Open_left_Callback(hObject, eventdata, handles)
% hObject    handle to Open_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Open_right.
function Open_right_Callback(hObject, eventdata, handles)
% hObject    handle to Open_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Stage2_repetitions_Callback(hObject, eventdata, handles)
% hObject    handle to Stage2_repetitions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Stage2_repetitions as text
%        str2double(get(hObject,'String')) returns contents of Stage2_repetitions as a double


% --- Executes during object creation, after setting all properties.
function Stage2_repetitions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Stage2_repetitions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OpenWater_Callback(hObject, eventdata, handles)
% hObject    handle to OpenWater (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OpenWater as text
%        str2double(get(hObject,'String')) returns contents of OpenWater as a double


% --- Executes during object creation, after setting all properties.
function OpenWater_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OpenWater (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PinP_Callback(hObject, eventdata, handles)
% hObject    handle to PinP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PinP as text
%        str2double(get(hObject,'String')) returns contents of PinP as a double


% --- Executes during object creation, after setting all properties.
function PinP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PinP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Right_Licks_counter_Callback(hObject, eventdata, handles)
% hObject    handle to Right_Licks_counter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Right_Licks_counter as text
%        str2double(get(hObject,'String')) returns contents of Right_Licks_counter as a double


% --- Executes during object creation, after setting all properties.
function Right_Licks_counter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Right_Licks_counter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Left_Licks_counter_Callback(hObject, eventdata, handles)
% hObject    handle to Left_Licks_counter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Left_Licks_counter as text
%        str2double(get(hObject,'String')) returns contents of Left_Licks_counter as a double


% --- Executes during object creation, after setting all properties.
function Left_Licks_counter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Left_Licks_counter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Hits_Left_Callback(hObject, eventdata, handles)
% hObject    handle to Hits_Left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Hits_Left as text
%        str2double(get(hObject,'String')) returns contents of Hits_Left as a double


% --- Executes during object creation, after setting all properties.
function Hits_Left_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Hits_Left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Hits_Right_Callback(hObject, eventdata, handles)
% hObject    handle to Hits_Right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Hits_Right as text
%        str2double(get(hObject,'String')) returns contents of Hits_Right as a double


% --- Executes during object creation, after setting all properties.
function Hits_Right_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Hits_Right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Open_left.
function Open_left_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Open_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Rotation_angle_Callback(hObject, eventdata, handles)
% hObject    handle to Rotation_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rotation_angle as text
%        str2double(get(hObject,'String')) returns contents of Rotation_angle as a double


% --- Executes during object creation, after setting all properties.
function Rotation_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rotation_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cue_Freqency_Callback(hObject, eventdata, handles)
% hObject    handle to Cue_Freqency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cue_Freqency as text
%        str2double(get(hObject,'String')) returns contents of Cue_Freqency as a double


% --- Executes during object creation, after setting all properties.
function Cue_Freqency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cue_Freqency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over StopButton.
function StopButton_ButtonDownFcn(hObject, eventdata, handles)
%KEEP_READING=0;  %AG added 6 March 2018
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on StopButton and none of its controls.
function StopButton_KeyPressFcn(hObject, eventdata, handles)
%KEEP_READING=0;  %AG added 6 March 2018
% hObject    handle to StopButton (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
