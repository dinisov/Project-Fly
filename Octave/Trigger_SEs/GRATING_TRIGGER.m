function GRATING_TRIGGER

clear; close all;


%% grating parameters, as in parameters which are grating, I crack myself up

f=0.005;

% Speed of grating in cycles per second: 1 cycle per second by default. 
cyclespersecond=2;

angle=0;

movieDurationSecs=0.7;   % duration of each direction of the grating

numberofTrials = 100;

%random directions (from left to right and right to left)
direction = [ones(1,numberofTrials/2);zeros(1,numberofTrials/2)];
direction = direction(:).';% alternating directions
% direction = direction(randperm(numberofTrials));

try
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%

        % This script calls Psychtoolbox commands available only in OpenGL-based 
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    AssertOpenGL;

    % Get the list of screens and choose the one with the highest screen number.
    % Screen 0 is, by definition, the display with the menu bar. Often when 
    % two monitors are connected the one without the menu bar is used as 
    % the stimulus display.  Chosing the display with the highest dislay number is 
    % a best guess about where you want the stimulus displayed.  
    screens=Screen('Screens');
    screenNumber=max(screens);

    % Find the color values which correspond to white and black: Usually
    % black is always 0 and white 255, but this rule is not true if one of
    % the high precision framebuffer modes is enabled via the
    % PsychImaging() commmand, so we query the true values via the
    % functions WhiteIndex and BlackIndex:
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    gray=round((white+black)/2);

    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
        gray=white / 2;
    end

    % Contrast 'inc'rement range for given white and gray values:
    inc=white-gray;

    % Open a double buffered fullscreen window and set default background
    % color to gray:
    [w screenRect]=Screen('OpenWindow',screenNumber, [0 0 0]);

%     if drawmask
%         % Enable alpha blending for proper combination of the gaussian aperture
%         % with the drifting sine grating:
%         Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%     end
    
    % Calculate parameters of the grating:
    
    % First we compute pixels per cycle, rounded up to full pixels, as we
    % need this to create a grating of proper size below:
    p=ceil(1/f);
    
    % Also need frequency in radians:
    fr=f*2*pi;
    
    % This is the visible size of the grating. It is twice the half-width
    % of the texture plus one pixel to make sure it has an odd number of
    % pixels and is therefore symmetric around the center of the texture:
%     visiblesize=2*texsize+1;

    % Create one single static grating image:
    %
    % We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
    % define the whole grating! If the 'srcRect' in the 'Drawtexture' call
    % below is "higher" than that (i.e. visibleSize >> 1), the GPU will
    % automatically replicate pixel rows. This 1 pixel height saves memory
    % and memory bandwith, ie. it is potentially faster on some GPUs.
    %
    % However it does need 2 * texsize + p columns, i.e. the visible size
    % of the grating extended by the length of 1 period (repetition) of the
    % sine-wave in pixels 'p':
    x = meshgrid(-1280:1280 + p, 1);
    
    % Compute actual cosine grating:
    grating=gray + inc*cos(fr*x);

    % Store 1-D single row grating in texture:
    gratingtex=Screen('MakeTexture', w, grating);

    % Create a single gaussian transparency mask and store it to a texture:
    % The mask must have the same size as the visible size of the grating
    % to fully cover it. Here we must define it in 2 dimensions and can't
    % get easily away with one single row of pixels.
    %
    % We create a  two-layer texture: One unused luminance channel which we
    % just fill with the same color as the background color of the screen
    % 'gray'. The transparency (aka alpha) channel is filled with a
    % gaussian (exp()) aperture mask:
%     mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
%     [x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
%     mask(:, :, 2)= round(white * (1 - exp(-((x/90).^2)-((y/90).^2))));
%     masktex=Screen('MakeTexture', w, mask);

    % Query maximum useable priorityLevel on this system:
    priorityLevel=MaxPriority(w); %#ok<NASGU>

    % We don't use Priority() in order to not accidentally overload older
    % machines that can't handle a redraw every 40 ms. If your machine is
    % fast enough, uncomment this to get more accurate timing.
    %Priority(priorityLevel);
    
    % Definition of the drawn rectangle on the screen:
    % Compute it to  be the visible size of the grating, centered on the
    % screen:
    width = 1920;
    height = 1080;
    dstRect=[0 0 width height];
    dstRect=CenterRect(dstRect, screenRect);

    % Query duration of one monitor refresh interval:
    ifi=Screen('GetFlipInterval', w);
    
    % Translate that into the amount of seconds to wait between screen
    % redraws/updates:
    
    % waitframes = 1 means: Redraw every monitor refresh. If your GPU is
    % not fast enough to do this, you can increment this to only redraw
    % every n'th refresh. All animation paramters will adapt to still
    % provide the proper grating. However, if you have a fine grating
    % drifting at a high speed, the refresh rate must exceed that
    % "effective" grating speed to avoid aliasing artifacts in time, i.e.,
    % to make sure to satisfy the constraints of the sampling theorem
    % (See Wikipedia: "Nyquist?Shannon sampling theorem" for a starter, if
    % you don't know what this means):
    waitframes = 1;
    
    % Translate frames into seconds for screen update interval:
    waitduration = waitframes * ifi;
    
    % Recompute p, this time without the ceil() operation from above.
    % Otherwise we will get wrong drift speed due to rounding errors!
    p=1/f;  % pixels/cycle    


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

    myport = IOPort('OpenSerialPort', portSpec, portSettings);
    IOPort('ConfigureSerialPort', myport, asyncSetup);
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    WaitSecs(2);%necessary so Arduino has opened serial port before we send an 'S'

    %start Arduino
    IOPort('Write',myport,'S');


    count = 0;

    %% main loop
    while count < numberofTrials

        % wait for serial signal
        [pktdata, treceived] = IOPort('Read', myport, 1, 1);

        if char(pktdata(1)) == 'S'

            write(t,'S');
    
            % Translate requested speed of the grating (in cycles per second) into
            % a shift value in "pixels per frame", for given waitduration: This is
            % the amount of pixels to shift our srcRect "aperture" in horizontal
            % directionat each redraw:
            shiftperframe= (cyclespersecond * p * waitduration)*direction(count+1);
            
            % Perform initial Flip to sync us to the VBL and for getting an initial
            % VBL-Timestamp as timing baseline for our redraw loop:
            vbl=Screen('Flip', w);
        
            % We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
            vblendtime = vbl + movieDurationSecs;
            i=0;
            
            % Animationloop:
            while vbl < vblendtime
                % Shift the grating by "shiftperframe" pixels per frame:
                % the mod'ulo operation makes sure that our "aperture" will snap
                % back to the beginning of the grating, once the border is reached.
                % Fractional values of 'xoffset' are fine here. The GPU will
                % perform proper interpolation of color values in the grating
                % texture image to draw a grating that corresponds as closely as
                % technical possible to that fractional 'xoffset'. GPU's use
                % bilinear interpolation whose accuracy depends on the GPU at hand.
                % Consumer ATI hardware usually resolves 1/64 of a pixel, whereas
                % consumer NVidia hardware usually resolves 1/256 of a pixel. You
                % can run the script "DriftTexturePrecisionTest" to test your
                % hardware...
                xoffset = mod(i*shiftperframe,p);
                i=i+1;
                
                % Define shifted srcRect that cuts out the properly shifted rectangular
                % area from the texture: We cut out the range 0 to visiblesize in
                % the vertical direction although the texture is only 1 pixel in
                % height! This works because the hardware will automatically
                % replicate pixels in one dimension if we exceed the real borders
                % of the stored texture. This allows us to save storage space here,
                % as our 2-D grating is essentially only defined in 1-D:
                srcRect=[xoffset 0 xoffset + width height];
                
                % Draw grating texture, rotated by "angle":
                Screen('DrawTexture', w, gratingtex, srcRect, dstRect, angle,[],[],[0 0 255]);
        
        %         if drawmask==1
        %             % Draw gaussian mask over grating:
        %             Screen('DrawTexture', w, masktex, [0 0 visiblesize visiblesize], dstRect, angle);
        %         end
        
                % Flip 'waitframes' monitor refresh intervals after last redraw.
                % Providing this 'when' timestamp allows for optimal timing
                % precision in stimulus onset, a stable animation framerate and at
                % the same time allows the built-in "skipped frames" detector to
                % work optimally and report skipped frames due to hardware
                % overload:
                vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
        
                % Abort demo if any key is pressed:
                if KbCheck
                    break;
                end
            end
    
            % clear the grating
            Screen('FillRect', w, [0 0 0]);
            Screen('Flip',w);
    
            write(t,'E');

            count = count + 1;
    
            disp(count);

        end

    end

    save -mat7-binary grating_exp6_fly1_21jan2023.mat;
    
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