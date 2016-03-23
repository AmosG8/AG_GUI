function varargout = AG_GUI(varargin)
% 26 Jan 16
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

% Last Modified by GUIDE v2.5 23-Mar-2016 16:22:13

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


%1. Make sure stop button is not pressed
set(handles.StopButton,'Value',0);

%2. Collect all information that the USER has enetered
%2.1 transform sec to msec
params.SampleDuration = 1000* str2double(get(handles.Sample_Duration_Input,'String'));
params.RetentionDuration = 1000* str2double(get(handles.Retention_Duration_Input,'String'));
params.ResponseDuration = 1000* str2double(get(handles.Response_Duration_Input,'String'));
params.ITIDuration = 1000* str2double(get(handles.ITI_Duration_Input,'String'));
params.VacuumDuration = 1000* str2double(get(handles.Vacuum_Duration_Input,'String'));
params.ToneDuration = 1000* str2double(get(handles.Tone_Duration_Input,'String'));
params.PunishmentDuration = 1000* str2double(get(handles.Punishment_Duration_Input,'String'));
params.Nchoices = str2double(get(handles.Last_N_Choices,'String'));
params.Nlicks = str2double(get(handles.Last_N_Licks,'String'));
params.N_Trials_Exp = str2double(get(handles.N_Trials_Input,'String'));
params.MouseName=get(handles.MouseID_Input,'String');
params.TrainingStages=get(handles.TrainingStagesPopDown,'Value');

%3. generate the file name like "MouseID_Date", i.g: Miki_12Jan2011_14_41_19 
ExpTime=datestr(now); % => 12-Jan-2016 14:41:19
ExpTime=ExpTime(ExpTime~='-');  %12Jan2011 14:41:19
ExpTime=strrep(ExpTime, ' ', '_');%12Jan2011_14:41:19
ExpTime=strrep(ExpTime, ':', '_');%12Jan2011_14_41_19
params.MouseName=[params.MouseName,'_',ExpTime];%Miki_12Jan2016_14_52_45

% %tests for collecting the data provided by the USER
% fprintf ('sample duration is %d \n' ,params.SampleDuration); 
% fprintf ('retention duration is %d \n' ,params.RetentionDuration); 
% fprintf ('response duration is %d \n' ,params.ResponseDuration); 
% fprintf ('ITI duration is %d \n' ,params.ITIDuration); 
% fprintf ('vacuum duration is %d \n' ,params.VacuumDuration); 
% fprintf ('tone duration is %d \n' ,params.ToneDuration); 
% fprintf ('punishment duration is %d \n' ,params.PunishmentDuration); 
% fprintf ('sliding window of N last trials for choices is %d \n' ,params.Nchoices); 
% fprintf ('sliding window of N last licks is %d \n' ,params.Nlicks); 
% fprintf ('mouse name is %s \n' ,params.MouseName); 
% fprintf ('number of trials in the experiemnt %d \n' ,params.N_Trials_Exp); 
% fprintf ('the training stage is %d \n' ,params.TrainingStages); 

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
pause(2);
% s.ReadAsyncMode = 'manual';
% readasync(s); 

%5. sending data to the Arduino
%5.1 change the 'training stage' from a number (1 or 2 or 3 or 4) to what
%the arduino expects: A,B,C,D,S
switch (params.TrainingStages)
    case 1
        stage='A';
    case 2
        stage='B';
    case 3
        stage='C';
    case 4
        stage='D';
end %of switch for experiment stage

%5.2 sending 9 variables seq to Arduino
fprintf(s,'%s,',stage);                  fprintf(s,'%d,',params.N_Trials_Exp);
fprintf(s,'%d,',params.SampleDuration);  fprintf(s,'%d,',params.RetentionDuration);
fprintf(s,'%d,',params.ResponseDuration);fprintf(s,'%d,',params.ITIDuration);
fprintf(s,'%d,',params.VacuumDuration);  fprintf(s,'%d,',params.ToneDuration);
fprintf(s,'%d',params.PunishmentDuration);

% fprintf('%s ,',stage)                  
% fprintf('%d ,',params.N_Trials_Exp)
% fprintf('%d ,',params.SampleDuration)  
% fprintf('%d ,',params.RetentionDuration)
% fprintf('%d ,',params.ResponseDuration)
% fprintf('%d ,',params.ITIDuration)
% fprintf('%d ,',params.VacuumDuration)
% fprintf('%d ,',params.ToneDuration)
% fprintf('%d ',params.PunishmentDuration)

%6 operation
global KEEP_READING;
KEEP_READING=1;

switch (params.TrainingStages)
    case 1 %Once the user press 'start' the valves are opened until the user press on Stop
      %display of time 

      %At this stage of training, i'm only sending a start and a stop
        while KEEP_READING
            arduinoMessage = readAndParseArduionoSerialMessage(s);
            %check if message has content
                    if numel(arduinoMessage)>0
                      ExperimentTime=arduinoMessage.experimentElapsedTime/60000;%convert from msec to min
                      set (handles.ElapsedTime, 'string',ExperimentTime);
                    end %of if
             KEEP_READING= ~get(handles.StopButton,'Value');
             pause(0.0001);
        end %of while
        
    case {2,3}
    %There's a Response time, an ITI, and a punishment.
    %count licks in response time and licks in ITI
    %The only difference between cases 2 and 3 is that in #3
    % water is delivered only after the first lick that follows the tone
      TotalLicks=0;    
      NumberofTrials=0;
      %CorrectTimeLicks is a matrix in which
      % columns are licks
      % row 1 is 1 or 0 for within response time or not
      while KEEP_READING
         arduinoMessage = readAndParseArduionoSerialMessage(s);
         %check if message has content
         if numel(arduinoMessage)>0
             if arduinoMessage.trialBeginningEvent==1
                 NumberofTrials=NumberofTrials+1; %counting trials
                 set (handles.Current_Trial_Num, 'string', NumberofTrials);
             end %of if for trial begining
             ExperimentTime=arduinoMessage.experimentElapsedTime/60000;%convert from msec to min
             set (handles.ElapsedTime, 'string', ExperimentTime);
             set(handles.Stage_of_Trial, 'string', arduinoMessage.trailStage);
             if arduinoMessage.lickEventCorrectTiming == 1 %lick within
                                                      %Response time
                  TotalLicks=TotalLicks+1;
                  CorrectTimeLicks(TotalLicks)=1;
             elseif arduinoMessage.lickEventCorrectTiming ==0
                  TotalLick=TotalLick+1;
                  CorrectTimeLicks(TotalLicks)=0;   
             end %another possibility is arduinoMessage.lickEventCorrectTiming=-1 ->no lick
             
             %plot CorrectTimeLicks. Each N last licks are meaned and
             %displayed as another point. All points from the experiemnt
             % begining are displayed 
             
            if mod(TotalLicks,params.Nlicks)>0    
                Last_N_Values (mod(TotalLicks,params.Nlicks))...
                    =CorrectTimeLicks(TotalLicks);
            else  %when mod (TotalLicks,params.Nlickss)=0 
                 Last_N_Values(params.Nlicks)...
                    =CorrectTimeLicks(TotalLicks);
            end
            if length(Last_N_Values) == params.Nlicks%Last_N_Values is full
                axes(handles.Plot_Lick_Timing);
                Lick_TimingIndex=TotalLicks-params.Nlicks+1;
                Lick_Plot(Lick_TimingIndex)=mean(Last_N_Values);
                plot (Lick_Plot); 
            end
              if KEEP_READING %at end of experiemnt KEEP_READING= 0 and 
                 %there's no point checking the stop
                KEEP_READING= ~get(handles.StopButton,'Value');
                if ~KEEP_READING
                    stage='S';
                    fprintf(s,'%s',stage); 
                    fprintf(s,'%s',stage)
                end
             end
         end %of if corresponding to if there's content in the message
      pause(0.0001);
      end %of while reading loop for experiments #2 or #3
        

    case 4  %discrimination learning
    NumberofTrials=0;
    TotalLicks=0;
    GoCounter=0;
    textureOne=0;textureTwo=0;
   %KEEP_READING is set to 1 already at line 119
   while KEEP_READING     % reading data loop starts here
        arduinoMessage = readAndParseArduionoSerialMessage(s);
        %check if message has content
        if numel(arduinoMessage)>0
            
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
                    if arduinoMessage.thisTrialTexture==1
                        textureOne=textureOne+1;
                    elseif arduinoMessage.thisTrialTexture==2
                        textureTwo=textureTwo+1;
                    end
                        Temp=textureTwo-textureOne;
                        Temp
                    if NumberofTrials ==1 %at 1st time
                        arduinoMessage.Mouse=params.MouseName;%adding " mouse_Date "
                        set(handles.LicksDisplay, 'string', '0');
                        set(handles.HitsDisplay, 'string', '0');                     
                        set(handles.GoDisplay, 'string', '0');
                        set(handles.Display_END, 'string', 'RUNNING'); 
                    else
                        %GoNoGoM columns are trials
                        %row 1 is 0 for no-go, 1 for go
                        %row 2 is texture presented
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
                    set (handles.Current_Trial_Num, 'string', NumberofTrials);
                    
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
                        case -1 %no lick;   %0 incorrect time; 1 corect time
                            %MessageDone=1;
                            
                            %if there's a lick cases 0 or 1
                            %making a LickMatrix in which each lick is a
                            %column
                            %1st row is correct(1) or incorrect (0) time
                            %2nd row time of the lick from Ex begining
                            %3rd row is trial number
                            %4th row is trial stage

                        case 0 %lick outside of response time
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
                                GoTime=arduinoMessage.experimentElapsedTime;
                                GoTexture=arduinoMessage.thisTrialTexture;
                                HitOrMiss(1,GoCounter)=arduinoMessage.lickEventCorrectPort;
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
            KEEP_READING= ~get(handles.StopButton,'Value');
             if ~KEEP_READING
                    stage='S';
                    fprintf(s,'%s',stage); 
                    pause(0.001);
                    delete(instrfindall);
             end
        end
        pause(0.0001);
   end
   ReceivedDataFilename=['Received_', params.MouseName];
   save(ReceivedDataFilename,'ReceivedData'); % see line 266
            
            % end of the while reading loop
   %saving the 3 matrixes
    GoNoGoM_Filename=['GoNoGoM_', params.MouseName];
    save(GoNoGoM_Filename,'GoNoGoM');

    LickMatrix_Filename=['LickMatrix_', params.MouseName];
    save(LickMatrix_Filename,'LicksMatrix');

    HitOrMiss_Filename=['HitOrMiss_', params.MouseName];
    save(HitOrMiss_Filename,'HitOrMiss');
end %of switch for traing types. 



fclose (s);  % closing COM port
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



function edit37_Callback(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit37 as text
%        str2double(get(hObject,'String')) returns contents of edit37 as a double


% --- Executes during object creation, after setting all properties.
function edit37_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
