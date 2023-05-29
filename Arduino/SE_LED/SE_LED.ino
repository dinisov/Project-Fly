const int stimPin =  6;      // stimulus: on (pulsed) during stimulus bouts                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      const int stimPin =  6;      // stimulus: on (pulsed) during stimulus bouts
const int FramePin =  4;      // indicator: on (constant) during stimulus bouts
const int CamFramePin =  5;
const int initPin = 7;


const int sequenceLength = 900;

//GLOBAL VARIABLES:
boolean lastReading;
boolean buttonState = HIGH;
boolean lastButtonState = HIGH;

int randomSequence[sequenceLength];
int lefRightPins[2];
int pin;


void setup()
{

  pinMode(stimPin, OUTPUT);
  pinMode(FramePin, OUTPUT);
  pinMode(CamFramePin, OUTPUT);
  pinMode(initPin, INPUT);

  //open serial channel
  Serial.begin(9600);

  randomSeed(analogRead(A0));

  //create random sequence
   for ( int i = 0; i < sequenceLength ; i++) {
  		randomSequence[i] = random(2);
  }

  //set pins
  lefRightPins[0] = 4; lefRightPins[1] = 7;
}

void programRun(unsigned long initTime) {

  // int exposure=2000;

  //------------------------------------------------------------------------------------ ENTER PROGRAM INFORMATION BELOW THIS LINE-----------------------------------------------

  digitalWrite(stimPin, LOW);

  // enter the pre-stimulus period here, in ms. (ex ""   delay(30000); "" )

  //  describe each block of stimuli with number of repeats, bout duration, recovery time between bouts, pulse frequency, pulse width and intensity (integer, precent of max).
  // example : runBlock(3, 10000, 10000, 100, 5, 128)  is 3 bouts of 10 second stimuli (5ms pulses, 100Hz, 50% intensity), with 10 seconds recovery between bouts.
  //  int exposure = 175;
  int nTriggers = 10;
  //  digitalWrite(stimPin, HIGH);

//  for (int j = 0; j < nTriggers; j++) {
//    digitalWrite(FramePin, HIGH);
////          digitalWrite(stimPin, HIGH);
////    digitalWrite(CamFramePin, HIGH);
//    delay(1800);
////          digitalWrite(stimPin, LOW);
//    digitalWrite(FramePin, LOW);
////    digitalWrite(CamFramePin, LOW);
//    delay(1000);
//  }

  // for (int j = 0; j < 120; j++) {
  //   for (int i = 0; i < 200; i++) {
  //     delayMicroseconds (5000-exposure);
  //     digitalWrite(CamFramePin, HIGH);
  //     delayMicroseconds (exposure);
  //     digitalWrite(CamFramePin, LOW);
  //   }
  // }
   // for (int j = 0; j < 1; j++) {
  for (int i = 0; i < sequenceLength; i++) {
		pin = lefRightPins[randomSequence[i]];
		digitalWrite(pin, HIGH);
		delay(10);
		digitalWrite(pin, LOW);
		delay(70);
     }

  // for (int i=0; i<10;i++){
  // 	Serial.print(randomSequence[i]);
  // }


}

void loop() {

  if (lastButtonState == HIGH) {
    programRun(millis());
  }
  lastButtonState = LOW;

}
