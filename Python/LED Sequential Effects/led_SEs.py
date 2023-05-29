from gpiozero import PWMLED
from time import sleep
import numpy as np

led1 = PWMLED(17)
led2 = PWMLED(27)

#pulse width modulation for both LEDs
pwm1 = .1
pwm2 = .1

#stimulus on and off times (in seconds)
#frequency is 1/(stimOn+stimOff)
stimOn = .1
stimOff = .7

numberOfBlocks = 2
blockLength = 5

interBlockPeriod = 2

sequenceLength = numberOfBlocks*blockLength

# this is ready to generate different proportions of both stimuli in the future
randomSequence = np.array([0] * int (sequenceLength/2) + [1] * int (sequenceLength/2))

np.random.shuffle(randomSequence)

trial = 0

for i in range(numberOfBlocks):

	for s in range(blockLength):

		led1.value = pwm1*randomSequence[trial]
		led2.value = pwm2*(1-randomSequence[trial])

		sleep(stimOn)

		led1.value = 0
		led2.value = 0

		sleep(stimOff)

		trial += 1

	sleep(interBlockPeriod)