close all; clear;    


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

%% open serial port

% Open port portSpec with portSettings, return handle:
myport = IOPort('OpenSerialPort', portSpec, portSettings);
IOPort('ConfigureSerialPort', myport, asyncSetup);

WaitSecs(2);

IOPort('Write',myport,'S');