const int stimPin =  6;      // stimulus: on (pulsed) during stimulus bouts                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      const int stimPin =  6;      // stimulus: on (pulsed) during stimulus bouts
const int FramePin =  4;      // indicator: on (constant) during stimulus bouts
const int CamFramePin =  5;
const int initPin = 7;
const int testPin = 2;
const int shutterPin = 2;

//GLOBAL VARIABLES:
boolean lastReading;
boolean buttonState = HIGH;
boolean lastButtonState = HIGH;
int randomSequence[10] ;

int stimulusTime = 1000;
int recordingTime = 2000;

void setup()
{
  // pinMode(stimPin, OUTPUT);
  // pinMode(FramePin, OUTPUT);
  pinMode(shutterPin, OUTPUT);
  // pinMode(CamFramePin, OUTPUT);
  // pinMode(initPin, INPUT);

  //open serial channel
  // Serial.begin(9600);

  // randomSeed(analogRead(A0));

  // //create random sequence
  //  for ( int i = 0; i < 10 ; i++) {
  // 		randomSequence[i] = random(2);
  // }
}

void programRun(unsigned long initTime) {

//   Serial.print("E");

//   // int exposure=2000;
//   delay(5000);


//   //leave this here it is important when doing 2P experiments in stimulus mode
	for (int i = 0; i < 5; i++){
	  digitalWrite(shutterPin, HIGH);
	  // digitalWrite(FramePin, HIGH);
	  delay(1000);
	  digitalWrite(shutterPin, LOW);
	  // digitalWrite(FramePin, LOW);
	  delay(1000);
	}

//   int nTriggers = 10;

// //  for (int j = 0; j < nTriggers; j++) {

// 	 for (int i = 0; i < nTriggers; i++) {

// 	 	//recordign phase (shutter open)
// 	   digitalWrite(FramePin, HIGH);
// 	   digitalWrite(TestPin, HIGH);
// 	   delay(recordingTime);

// 	   //stimulus phase (shutter closed)
// 	   digitalWrite(FramePin, LOW);
// 	   digitalWrite(TestPin, LOW);
// 	   delay(50);//small delay to make sure shutter is closed before turning on projector
// 	   Serial.print("S");//this starts the next bout of stimuli
// 	   delay(stimulusTime);//show some stimuli (e.g. train of 5 stimuli)
// 	 }


  // for (int i=0; i<10;i++){
  // 	Serial.print(randomSequence[i]);
  // }


}

// void runBlock(int repeats, unsigned long duration, unsigned long recovery, long frequency, long pulse_width, int pwm) {
//   for (int x = 0; x < repeats; x++) {
//     pulseTrain(millis(), duration, frequency, pulse_width, pwm);
//     delay(recovery);
//   }
// }

// void pulseTrain(unsigned long pulseBegin, unsigned long duration, long frequency, long pulse_width, int pwm) {

//   while ((millis() - pulseBegin) <= duration) {
//     analogWrite(stimPin, pwm);
//     delay(pulse_width);
//     digitalWrite(stimPin, LOW);
//     delay((1000L / frequency) - pulse_width);
//   }

// }

void loop() {

   // digitalWrite(FramePin, LOW);
   // delay(1000);
   // digitalWrite(FramePin, HIGH);
   // delay(1000);


  if (lastButtonState == HIGH) {
    programRun(millis());
  }
  lastButtonState = LOW;

}
