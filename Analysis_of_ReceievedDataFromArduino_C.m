%% the user selects files that were received from arduino to open 
%and place all summary data into an output structure called day_summary
clear all;
day_summary={};
%[file,path] = uigetfile('Select at least 2 Files', 'MultiSelect', 'on');
[file,path] = uigetfile('Select at least 2 Files', 'MultiSelect', 'on');
[m n]=size(file); %n is the number of files choosen

skipped=0; ex_stage=0;
for selected_file=1:n
    time=[0];Licks=[0];total_Licks=0;
    data=open (char( fullfile(path, file(1,selected_file))) );
    
 %% check if the current file is a valid file (aka begins with 'Received_' 'digit digit digit')
 if sum(file{1,selected_file}(1:8)=='Received')==8 && ...
         sum(isstrprop(file{1,selected_file}(10:12),'digit'))==3
     ContinueFlag_ValidFile=1;
 else
     ContinueFlag_ValidFile=0;
     skipped=skipped+1;%to mach with indexing of the selected file
 end
 
    %% total time of the session in seconds 
   if ContinueFlag_ValidFile 
    time = extractfield(data.ReceivedData,'experimentElapsedTime');
   end
    
    %% skip a file if experiment time < = 5min go to the next file and don't write anything 
        
    if double(max(time))/1000 > 5*60 
%max(time)/1000 = length of the experiment in seconds 
        ContinueFlag_ExTimeLength=1;
        day_summary.ExLength_min(selected_file-skipped,1)=double(max(time))/60000;
        day_summary.filename(selected_file-skipped,1)=file(1,selected_file);
    else
        ContinueFlag_ExTimeLength=0;
        if ContinueFlag_ValidFile==1 %to not skip twice
         skipped=skipped+1;
        end
    end

        
    %%    determine the experiment stage
   if ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile
       Temp=file{1,selected_file}(end-21:end);
       ExDayMatFormat=strcat(Temp(1:2),'-',Temp(3:5),'-',Temp(6:9));
       ExDayMatFormat=datetime(ExDayMatFormat);
       switch file{1,selected_file}(10:12)
           case '170'             
               if(datetime('09-Oct-2018')-ExDayMatFormat)>0
                   ex_stage=1;
               else
                   ex_stage=2;
               end
           case '905'
               if(datetime('09-Oct-2018')-ExDayMatFormat)>0
                   ex_stage=1;
               else
                   ex_stage=2;
               end
           case '660'
               if(datetime('11-Oct-2018')-ExDayMatFormat)>0
                   ex_stage=1;
               else
                   ex_stage=2;
               end
           case '612'
               if(datetime('23-Oct-2018')-ExDayMatFormat)>0
                   ex_stage=1;
               else
                   ex_stage=2;
               end
           case '614'
               ex_stage=1;
       end
       
%       % for files acquired before 8-Oct-2018 automatically determine the experiemnt stage to 1
%         Temp=file{1,selected_file}(end-21:end);
%         %change ExDayTime to a datetime matlab structure
%         ExDayMatFormat=strcat(Temp(1:2),'-',Temp(3:5),'-',Temp(6:9));
%         ExDayMatFormat=datetime(ExDayMatFormat);
%         if (datetime('09-Oct-2018')-ExDayMatFormat)>0
%             ex_stage=1;
%         else     %do it manually 
%             fprintf('%s \n',file{1,selected_file}(:))
%             prompt = 'What is the stage of the experiment? \n 1 for A (licking) \n 2 for B (s-r association)\n 3 for C (random presentation) \n 4 for D (delay) \n';
%             ex_stage = input(prompt)
%         end
    day_summary.ExStage(selected_file-skipped,1)=ex_stage;
   end
    %% test if the presentation was random. Relevant for training-stages 3,4,5
    if ex_stage>2 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile
        BeginningEvent = extractfield(data.ReceivedData,'trialBeginningEvent');
        Indexes_of_trialBeginningEvent=find(BeginningEvent);
        Texture = extractfield(data.ReceivedData,'thisTrialTexture');
        mean(Texture(Indexes_of_trialBeginningEvent))
    end
    %% total number of licks based on the correct port column in the received data 
    if ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile
        if ex_stage==1  %in stage 1 there is nothing in correct port column 
            %   in stage 2 there was a bug in correct timing column
            Licks = extractfield(data.ReceivedData,'lickEventCorrectTiming');
        elseif ex_stage==2
            Licks = extractfield(data.ReceivedData,'lickEventCorrectPort');
        end
        total_Licks=length(find(Licks));

        day_summary.total_Licks(selected_file-skipped,1)=total_Licks;%easier to read
        day_summary.Percent_One_licks(selected_file-skipped,1)=(length(find(Licks==1))/total_Licks) *100;
        %Percent_Two_licks=(length(find(t==2))/total) *100
        day_summary.licksPerSec(selected_file-skipped,1) = total_Licks/(double( max(time)/1000) ); 
   
    end
    %% plots
    if ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile
        figure(1);
        Lick_One=[];
        Lick_Two=[];
        %LickAtOne=[];LickAtTwo=[];
        
        %prepare the data
        if ex_stage==1  %in stage 1 there is nothing in correct port column 
            Licks = extractfield(data.ReceivedData,'lickEventCorrectTiming');
        %   in stage 2 there was a bug in correct timing column
        %correct port doesn't say the identity
        %correct port is 1 for correct 2 for not correct 0 for not a lick
        elseif ex_stage==2
            Licks = extractfield(data.ReceivedData,'lickEventCorrectPort');
            Texture = extractfield(data.ReceivedData,'thisTrialTexture');
        end

        if ex_stage==1 
            Lick_One(1,:)=double(time(find(Licks==1))); %index for the message vector
            Lick_One(1,:)=Lick_One(1,:)/(1000*60);   
            %licks are based on 'correct time' columnX
            Lick_One(2,:)=1;
            Lick_Two(1,:)=double(time(find(Licks==2)));
            Lick_Two(1,:)=Lick_Two(1,:)/(1000*60);
            Lick_Two(2,:)=1.05;
        elseif ex_stage==2
            Lick_One = find( ((Licks==1) & (Texture==1)) | ((Licks==2) & (Texture==2)) );
            Lick_Two = find( ((Licks==1) & (Texture==2)) | ((Licks==2) & (Texture==1)) );
            %time = extractfield(data.ReceivedData,'experimentElapsedTime');
            Lick_One(1,:)=double( time(Lick_One) );
            Lick_One(1,:)=Lick_One(1,:)/(60*1000);
            Lick_One(2,:)=1;
            Lick_Two(1,:)=double( time(Lick_Two) );
            Lick_Two(1,:)=Lick_Two(1,:)/(60*1000);
            Lick_Two(2,:)=1.05;
        end
            plot(Lick_One(1,:),Lick_One(2,:), 'K.', Lick_Two(1,:),Lick_Two(2,:), 'R.')
            ylim([0.5 1.5]);
            title(file{1,selected_file}(10:end-4),'FontWeight','normal','FontName','FixedWidth' );
    % allow the user to skip the current file based on it's plot 
            prompt = 'For continuing with this file press 1 \n for suspecious flag press 5 \n otherwise press 0 \n ';
            PlotContinue= input(prompt)
            if PlotContinue==0
                skipped=skipped+1;
            elseif PlotContinue==5
                day_summary.suspecious(selected_file-skipped,1)=1;
            else 
                day_summary.suspecious(selected_file-skipped,1)=0;
            end
            close(figure(1));
    end
    

    %% percent of licks at the right time stages 2 3 4
    %there were 2 bugs in Aruduino fixed (14-10-18) 
    %1. the bug caused the column of lick timing to be irrelevant.
    %that forced me to:
    %extract if the lick was at the corrct timing by the trial-stage column
    %and to extract the location based on the 'correct port' column
    %2. there were also Rr trials that practially were Sa
    
    if ex_stage>1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
      
        SaOrITI = extractfield(data.ReceivedData,'trailStage');
        %I'm now changing Sa and Rr to 1 and It to 0
        for index=1:length(SaOrITI)  
            if strfind(SaOrITI{index},'It')
                SaOrITI{index}=0;
            end
            if strfind(SaOrITI{index},'Rr')
                SaOrITI{index}=1;
            end
            if strfind(SaOrITI{index},'Sa')
                SaOrITI{index}=1;
            end
            if strfind(SaOrITI{index},'Ur')
                SaOrITI{index}=-5;
            end
        end
        SaOrITI = cell2mat(SaOrITI);
        IndexesSa=find(SaOrITI==1);
        IndexITI=find(SaOrITI==0);

        %now find licks that were at Sa/Rr => Licks_on_time
        %other licks are Licks_NOT_on_time
        Licks = extractfield(data.ReceivedData,'lickEventCorrectPort');
        Total_correct_Time_Licks=sum((Licks(IndexesSa))>0);% Licks(IndexesSa)) contains 0 1 2 
        Total_ITI_Licks=sum((Licks(IndexITI))==0);
       
        day_summary.Percent_Time_Licks(selected_file-skipped,1)=(Total_correct_Time_Licks/total_Licks) *100;
        day_summary.Total_Licks(selected_file-skipped,1)=sum((Licks(:))>0);
        %(find(Licks==1||licks==2)         %licks=1 or 2 means there was a lick   
    elseif ex_stage==1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
         day_summary.Total_Licks(selected_file-skipped,1)=NaN;
         day_summary.Percent_Time_Licks(selected_file-skipped,1)=NaN;
    end
    
    %% percent of licks at the right location stage 2 3 4
    if ex_stage>1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        CorrectPort = extractfield(data.ReceivedData,'lickEventCorrectPort');%1 correct 2 incorrect 0 no lick
        day_summary.Percent_CorrectLocation_Licks(selected_file-skipped,1)=length(find(CorrectPort==1))/sum((Licks(:))>0) *100;
    elseif ex_stage==1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        day_summary.Percent_CorrectLocation_Licks(selected_file-skipped,1)=NaN;
    end
    %% percent of licks at the right location and at the right time
    if ex_stage>1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        Indexes_of_Correct_Port_and_Time=find(CorrectPort(IndexesSa)==1);
        day_summary.Total_correct_time_N_port(selected_file-skipped,1)=length(Indexes_of_Correct_Port_and_Time);        
        day_summary.Percent_correct_location_time(selected_file-skipped,1)=length(Indexes_of_Correct_Port_and_Time)/sum((Licks(:))>0) *100;        
    elseif ex_stage==1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        day_summary.Total_correct_time_N_port(selected_file-skipped,1)=NaN;
        day_summary.Percent_correct_location_time(selected_file-skipped,1)=NaN;
    end
    
    
    
    %% A single trial analysis (hit miss or no go)
    if ex_stage>1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        % find indexes of trial beginings
        trialBeginningEventIndexes = find(extractfield(data.ReceivedData,'trialBeginningEvent')>0);
            %I'm now slicing each single trial within correctport into a vector
            %(over-writting) called vector_of_single_trial_correctPort
            hit=0;miss=0;nogo=0;
        for number_of_trials=1:(length(trialBeginningEventIndexes)-1)
    %         first=trialBeginningEventIndexes(number_of_trials);
    %         second=trialBeginningEventIndexes(number_of_trials+1);
            vector_of_single_trial_correctPort = CorrectPort(trialBeginningEventIndexes(number_of_trials):trialBeginningEventIndexes(number_of_trials+1));

        % go along the vector of correct port between the trial beining events indexes
        % and if no item above 0 - missm else find the 1st>0 if it's 1 hit if it's 2 miss 
        %vector_of_single_trial_correctPort looks like [ 0 0 0 1 1 1 2 0 0 ]
            if any(vector_of_single_trial_correctPort)>0
                %it's a go trial
                counter=1;
                while counter < length(vector_of_single_trial_correctPort)
                    if vector_of_single_trial_correctPort(counter)==1%hit 
                        hit=hit+1;
                        counter=length(vector_of_single_trial_correctPort);%decided, so break for this trial, continue to decide on the next trial
                    elseif vector_of_single_trial_correctPort(counter)==2 %miss
                        miss=miss+1;
                        counter=length(vector_of_single_trial_correctPort);%decided, so break for this trial, continue to decide on the next trial
                    end
                    counter=counter+1;%would continue as lons as encountering 0s
                end
            else%no go trial
                nogo=nogo+1;
            end
        end%of for loop along all single trials
        % write the results into the summary table
        day_summary.Trialhits(selected_file-skipped,1)=hit/length(trialBeginningEventIndexes) *100;
        day_summary.Trialmiss(selected_file-skipped,1)=miss/length(trialBeginningEventIndexes) *100;
        day_summary.Trialnogo(selected_file-skipped,1)=nogo/length(trialBeginningEventIndexes) *100;
        day_summary.PercentTrialhits_ofGO(selected_file-skipped,1)=hit/(length(trialBeginningEventIndexes)-nogo) *100;
    elseif ex_stage==1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        day_summary.Trialhits(selected_file-skipped,1)=NaN;
        day_summary.Trialmiss(selected_file-skipped,1)=NaN;
        day_summary.Trialnogo(selected_file-skipped,1)=NaN;
        day_summary.PercentTrialhits_ofGO(selected_file-skipped,1)=NaN;
    end
    %% extract the mouse name  
    if ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
     day_summary(:).MouseName{selected_file-skipped,1} = file{1,selected_file}(10:12);
    end
    %% extract the date and time of when the experiemnt run
    if ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
       Temp=file{1,selected_file}(end-21:end);
       ExDayMatFormat=strcat(Temp(1:2),'-',Temp(3:5),'-',Temp(6:9));
       ExDayMatFormat=datetime(ExDayMatFormat); 
       day_summary(:).ExDate{selected_file-skipped,1} = ExDayMatFormat;    
    end
    
   
end %next file

%% output
Table_day_summary = struct2table(day_summary);
save('Table_day_summary','Table_day_summary');
save('Struct_day_summary','day_summary');

%% create the dataset
% create a structure 'mice' 
%with 2 fields: mouse name, results which is a structure 
mice_names={'660','905','170','612','614'};
for mouse_num=1:length(mice_names)
    mice(mouse_num).name=mice_names(mouse_num);
    mice(mouse_num).results=struct;

end

%% extract single mouse data from the table "Table_day_summary"
%load Table_day_summary;
Table_day_summary.StringMouseName = string(Table_day_summary.MouseName);
%rows = Table_day_summary.StringMouseName == "660";
for mouse_num=1:length(mice_names)
    rows = Table_day_summary.StringMouseName == mice_names(mouse_num);
    mice(mouse_num).results=Table_day_summary(rows, :);
end
%% save ouput
save('AG_Mice_Dataset','mice');