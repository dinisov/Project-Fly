function MOVING_BLUE_BAR

numberofTrials = 4 ;

barColour = [0 0 255];

barSpeed = 10; %bar speed in pixels per flip
barWidth = 80 ;  

%random directions (from left to right and right to left)
direction = [ones(1,numberofTrials/2) -ones(1,numberofTrials/2)];
direction = direction(randperm(numberofTrials));
disp(direction);
barSpeed = barSpeed*direction;

try
    KbName('UnifyKeyNames'); 
    screenNumber=max(Screen('Screens'));
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    grey=(white+black)/2;
    
    % System tests
    % just set SupressAllWarnings to 0 to see the outputs
    Screen('Preference', 'SuppressAllWarnings', 0);
    Screen('Preference', 'SkipSyncTests', 0); % set it to '0' to see all of the warnings
    Screen('Preference','VisualDebugLevel', 0); % can use values 0 to 5

    [win,screenRect]=Screen('OpenWindow',screenNumber, 128,[],32,2);

    [w, h] = Screen('WindowSize', win); 
    
    ifi=Screen('GetFlipInterval', win);
	disp(ifi);
    vbl=Screen('Flip', win);
    
    HideCursor;

    ListenChar(2);
    
    %set priority to the maximum possible
    priorityLevel=MaxPriority(win);
    Priority(priorityLevel);
    
    width = screenRect(3); height = screenRect(4);
    
    [a,b]=RectCenter(screenRect);
%     fprintf('Screen is %d by %d pix and the centre is %d %d\n', width,height,a,b);
%     Screen('TextSize',win, textSize);
 
%     Screen('DrawText', win, 'Press any key (on the keyboard) to start.', a-500, b, [0 0 0]);
%     vbl = Screen('Flip', win, vbl  + .5*ifi);
%     KbWait;
    
    %
    Screen('FillRect', win, black);
    vbl = Screen('Flip', win, vbl  + .5*ifi);

    button = 0;

    %
    for i=1:numberofTrials 

        while any(button) % wait for release
        [x,y,button] = GetMouse;
        end

        % Init defaults (bar starts on the left for rightward motion and vice-versa)
        if direction(i) > 0
            x=0;
            button = 0;
        else
            x = w+barWidth;
            button = 0;
        end

        % Run until left mouse button is pressed:
        while ~button(1)
            % Query mouse:
            [xm, ym, button] = GetMouse;
        
            % Move line pair by 'xv' unless right mouse button is pressed, which
            % will pause the animation:
            if button(2)==0
                x=mod(x+barSpeed(i), w+barWidth);
            end 
        
            %draw bar
            Screen('FillRect',win,barColour,[x-barWidth 0 x h]);
 
            % We use 'vbl' based timing, just that the frame-skip detector
            % works 
            % accurately and we get notified of possibly skipped frames -- Allows
            % to see if perceived je rks come frome timing issues or are induced by
            % the display or perception: 
            vbl=Screen('Flip', win,vbl+ifi/2,[],0);
        end
          
    end
    
     KloseIt
 
catch
    KloseIt
    psychrethrow(psychlasterror);
end %try..catch..

function KloseIt
Screen('CloseAll');
ShowCursor;
Priority(0);
ListenChar(0);
