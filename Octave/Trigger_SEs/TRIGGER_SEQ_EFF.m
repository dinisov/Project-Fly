function TRIGGER_SEQ_EFF

clear; close all;

panelFrequency = 58; %currently the projector is doing 60 Hz only (58 Hz really)

hardIFI = 1/panelFrequency;

%% start python script to turn on/off projector

% system('python ../dlpdlcr230np_python_support_code/dlpdldcr230npevm_python_support_software_1.0/on_off_socket.py');
% 
% WaitSecs(2);

%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% length of each block
blockLength = 5;

% pause between blocks (in seconds)
interBlockTime = 1;

% bar colour (choice of "green" or "blue")
colour = "blue";

%frequency (choice of 4, 6 or 12 Hz)
frequency = 6;

%number of blocks (usually 4500 for SEs)
%must be even number
%WARNING: this could make for long experiments
numberOfBlocks = 1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch frequency

    case 4

    % 4 Hz (1/2 duty cycle)
    nFlipsISI = 10;
    nFlipsSD = 5;

    case 6

    % 6 Hz (1/4 duty cycle)
    nFlipsISI = 8;
    nFlipsSD = 2;

    case 12

    % 12 Hz (1/4 duty cycle)
    nFlipsISI = 4;
    nFlipsSD = 1;

end

ISI = hardIFI*nFlipsISI;
stimulusDisplayTime = hardIFI*nFlipsSD;

% display the frequency
disp(['Frequency: ' num2str(1/(ISI+stimulusDisplayTime))]);

sequenceLength = numberOfBlocks*blockLength;

% display the amount of time the experiment will run for
disp(['Experiment duration: ' num2str((ISI+stimulusDisplayTime)*sequenceLength/60 + (numberOfBlocks*interBlockTime)/60) ' minutes']);

barWidth = 80;%keep this an even number

if strcmp(colour,"green")
    barColour = [0 255 0];
    backgroundColour = [0 0 0];
elseif strcmp(colour,"blue")
    barColour = [0 0 255];
    backgroundColour = [0 0 0];
end

%random binary sequence with exactly the same number of 1's and 0's
randomSequence = [ones(1,sequenceLength/2) 2*ones(1,sequenceLength/2)];

randomSequence = randomSequence(randperm(sequenceLength)); %Randomised left and right

overrideScreenSize = 1;

try
    %% setip tcp/ip link to turn on/off the projector

    pkg load instrument-control;

    t = tcpclient('127.0.0.1',65432);

    %% setup serial link %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % most comments here are Mario Kleiner's for reference

    % this is the expected frequency of triggering
    % probably overkill but it does not matter
    sampleFreq = 120;

    % this needs to be set to the arduino baud rate
    baudRate = 9600;

    % this will probably work if the only thing connected via USB to the
    % RPi is the Arduino, but may fail otherwise
    portSpec = FindSerialPort([], 1);

    % Compute maximum input buffer size for 1 hour worth of triggers coming
    % in at a expected sampleFreq Hz with a size of at most 1 Bytes each:
    InputBufferSize = sampleFreq * 3600;
    
    % Assign an interbyte readtimeout which is either 15 seconds, or 10 times
    % the expected time between consecutive datapackets at the given sampleFreq
    % sampling frequency, whatever's higher. Could go higher or lower than
    % this, but this seems a reasonable starter: Will give code and devices
    % time to start streaming, but will prevent script from hanging longer than
    % 15 seconds if something goes wrong with the connection:
    readTimeout = max(10 * 1/sampleFreq, 15);
    
    % HACK: Restrict maximum timeout to 21 seconds. This is needed on Macintosh
    % computers, because at least OS/X 10.4.11 seems to have a bug which can
    % cause the driver to hang when trying to stop at the end of a session if
    % the timeout value is set higher than 21 seconds!
    readTimeout = min(readTimeout, 21);
    
    % Assemble initial configuration string for opening the port with
    % reasonable settings: Given special settings, baudrate, inputbuffersize.
    % Also set the special delimiter character code 'lineTerminator' that
    % signals the end of a valid data packet:
    portSettings = sprintf('%s %s BaudRate=%i InputBufferSize=%i Terminator=0 ReceiveTimeout=%f ReceiveLatency=0.0001', '', [], baudRate, InputBufferSize, readTimeout);
    
%     fprintf('Link online: Hit a key on keyboard to start trigger recording, after that hit any key to finish trigger collection.\n');
%     KbStrokeWait;
    
    % ---- Here you'd put any IOPort setup calls, e.g., write and read commands
    % to setup your device, enable streaming of data etc...
    
    
    % ---- End of device specific setup ----
    
    % Start asynchronous background trigger collection and timestamping. Use
    % blocking mode for reading data -- easier on the system:
    asyncSetup = sprintf('%s BlockingBackgroundRead=1 StartBackgroundRead=1', '');
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    KbName('UnifyKeyNames');
     screenNumber=max(Screen('Screens'));
%    screenNumber=3;

    % System tests
    % just set SupressAllWarnings to 0 to see the outputs
    Screen('Preference', 'SuppressAllWarnings', 0);
    Screen('Preference', 'SkipSyncTests', 0); % set it to '0' to see all 
    % of the warnings
%     Screen('Preference','VisualDebugLevel', 0); % can use values 0 to 5

    [win,~]=Screen('OpenWindow',screenNumber, backgroundColour,[],32,2);

    [width, height] = Screen('WindowSize', win); 

    ifi=Screen('GetFlipInterval', win);
    
    disp(['IFI: ',num2str(ifi)]);%, VBL: ',num2str(vbl)])
    
    Screen('FillRect', win, backgroundColour);
    Screen('Flip', win); %clear the stimulus
    
    HideCursor;
%     ListenChar(2); %stop taking input from the keyboard
    
    %set priority to the maximum possible
    priorityLevel=MaxPriority(win);
    Priority(priorityLevel);
    if ~overrideScreenSize
        [width, height]=Screen('WindowSize', screenNumber); %#ok<*ASGLU>
    end
    
    % manual position of bars for 1920x1080
    dotBoxes = [480-barWidth 0 480+barWidth height; 1440-barWidth 0 1440+barWidth height];
    
    % Open port portSpec with portSettings, return handle:
    myport = IOPort('OpenSerialPort', portSpec, portSettings);
    IOPort('ConfigureSerialPort', myport, asyncSetup);

    WaitSecs(2);%necessary so Arduino has opened serial port before we send an 'S'

    %start Arduino
    IOPort('Write',myport,'S');

%     disp('SERIAL PORT OPEN!');

    count = 0;

    [vbl,~] = Screen('Flip', win); %clear the stimulus

    %% main loop
    while count < numberOfBlocks

        % wait for two bytes (Arduino sends an S or E followed by \n)
        [pktdata, treceived] = IOPort('Read', myport, 1, 1);

%         WaitSecs(0.5);
        
        if char(pktdata(1)) == 'S'

            write(t,'S');

            for i = 1:blockLength
                %display the stimulus
                Screen('FillRect', win, barColour, [dotBoxes(randomSequence((count*blockLength)+i),:)]);
                [vbl,~] = Screen('Flip',win,vbl+(nFlipsISI-.5)*ifi,[],0); 
    
                % clear the stimulus
                Screen('FillRect', win, backgroundColour);
                [vbl,~] = Screen('Flip', win,vbl+(nFlipsSD-.5)*ifi,[],0);
            end 

            write(t,'E');
%     
            count = count + 1;

            disp(count);
% 
        end

    end

save -mat7-binary SE_fly2_exp2_5May2023.mat;
    
    KloseIt

catch
    KloseIt
%     write(t,'S');
    psychrethrow(psychlasterror);
end %try..catch..

function KloseIt
    IOPort('CloseAll');
    Screen('CloseAll');
    ShowCursor
    ListenChar(0);
    Priority(0);
