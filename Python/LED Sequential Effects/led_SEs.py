from gpiozero import PWMLED, OutputDevice
from time import sleep
import numpy as np

## pins for the two separate LEDs
led1 = PWMLED(17)
led2 = PWMLED(27)

# pins to start the 2P and close/open the shutter
shutterPin = OutputDevice(5)
framePin = OutputDevice(13)

#LED intensity by PWM
pwm1 = .1
pwm2 = .1

#stimulus on and off times (in seconds)
#frequency is 1/(stimOn+stimOff)
stimOn = .1
stimOff = .7

numberOfBlocks = 2
blockLength = 5

recordingPeriod = 2

sequenceLength = numberOfBlocks*blockLength

# this is ready to generate different proportions of both stimuli in the future
randomSequence = np.array([0] * int (sequenceLength/2) + [1] * int (sequenceLength/2))

np.random.shuffle(randomSequence)

trial = 0

# probably should pulse the shutter pin

for i in range(numberOfBlocks):

	# display part
	framePin.off()#stop recording
	shutterPin.off()#close shutter

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

	# open shutter and start recording
	shutterPin.on()#open shutter
	sleep(0.020)#enough time for shutter to be fully open
	framePin.on()#start recording


	sleep(recordingPeriod)
