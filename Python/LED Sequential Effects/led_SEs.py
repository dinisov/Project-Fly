from gpiozero import PWMLED, OutputDevice
from time import sleep
import numpy as np
import serial

# establish serial link (Shutter_controller.ino Arduino script should be uploaded)
ser = serial.Serial('/dev/ttyACM0', 9600, timeout=1)

## pins for the two separate LEDs
led1 = PWMLED(17)
led2 = PWMLED(27)

#LED intensity by PWM
pwm1 = .1
pwm2 = .1

#stimulus on and off times (in seconds)
#frequency is 1/(stimOn+stimOff)
stimOn = .020
stimOff = .140

numberOfBlocks = 1000
blockLength = 5

recordingPeriod = 2

sequenceLength = numberOfBlocks*blockLength

# this is ready to generate different proportions of both stimuli in the future
randomSequence = np.array([0] * int (sequenceLength/2) + [1] * int (sequenceLength/2))

np.random.shuffle(randomSequence)

np.savetxt('fly2_exp3_15Jun23.csv',randomSequence,delimiter=",")

trial = 0

sleep(2)#give the serial link some time to startup

# ser.write('S'.encode())# close shutter

for i in range(numberOfBlocks):

	ser.write('S'.encode())# close shutter
	sleep(0.05)#wait 50 ms for shutter to fully close (protects PMT)

	# display part
	for s in range(blockLength):

		led1.value = 0
		led2.value = 0

		sleep(stimOff)

		led1.value = pwm1*randomSequence[trial]
		led2.value = pwm2*(1-randomSequence[trial])

		sleep(stimOn)

		trial += 1

	led1.value = 0
	led2.value = 0

	#recording part
	print(i)
	ser.write('S'.encode())# open shutter
	sleep(0.002)#wait 20 ms for shutter to fully open
	ser.write('F'.encode())#start recording (assumes frame pin in Arduino is LOW to start with
	sleep(recordingPeriod)
	ser.write('F'.encode())#end recording
