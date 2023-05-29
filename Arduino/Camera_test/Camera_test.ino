const int stimPin =  6;      // stimulus: on (pulsed) during stimulus bouts
const int FramePin =  4;      // indicator: on (constant) during stimulus bouts
const int CamFramePin =  5;
const int initPin = 7;
const int redlaserPin = 11;

//GLOBAL VARIABLES:
boolean lastReading;  
boolean buttonState = HIGH;
boolean lastButtonState = HIGH;

void setup()
{

  pinMode(stimPin, OUTPUT);  
  pinMode(FramePin, OUTPUT); 
  pinMode(CamFramePin, OUTPUT); 
  pinMode(initPin, INPUT); 
  pinMode(redlaserPin, OUTPUT); 
}

void programRun(unsigned long initTime) {
  
 

  //------------------------------------------------------------------------------------ ENTER PROGRAM INFORMATION BELOW THIS LINE-----------------------------------------------
  
  digitalWrite(stimPin, LOW);
 
  // enter the pre-stimulus period here, in ms. (ex ""   delay(30000); "" )
  
  //  describe each block of stimuli with number of repeats, bout duration, recovery time between bouts, pulse frequency, pulse width and intensity (integer, precent of max).
  // example : runBlock(3, 10000, 10000, 100, 5, 128)  is 3 bouts of 10 second stimuli (5ms pulses, 100Hz, 50% intensity), with 10 seconds recovery between bouts.
  int exposure = 175;
  digitalWrite(FramePin, HIGH);
  delayMicroseconds (200);
  digitalWrite(FramePin, LOW);
  delay (100);
  
  for (int j = 0; j < 300; j++) {
    for (int i = 0; i < 300; i++) {
      delayMicroseconds (5000-exposure);
      digitalWrite(CamFramePin, HIGH);
      delayMicroseconds (exposure);
      digitalWrite(CamFramePin, LOW);
    }
    digitalWrite(redlaserPin, LOW);  
  }
  
  
//  for (int j = 0; j < 12; j++) {
//    for (int i = 0; i < 200; i++) {
//      delayMicroseconds (5000-exposure);
//      digitalWrite(CamFramePin, HIGH);
//      delayMicroseconds (exposure);
//      digitalWrite(CamFramePin, LOW);
//    }
//  }
//  digitalWrite(stimPin, LOW);
//  
//  for (int j = 0; j < 60; j++) {
//    for (int i = 0; i < 200; i++) {
//      delayMicroseconds (5000-exposure);
//      digitalWrite(CamFramePin, HIGH);
//      delayMicroseconds (exposure);
//      digitalWrite(CamFramePin, LOW);
//    }
//  }

  
 
// 
// 
// 
// delay(5000); 
// digitalWrite(FramePin, HIGH);
// delay (2);
// digitalWrite(FramePin, LOW); 
// delay(10000); 
// runBlock(1, 20000, 55000, 50, 5, 255);



  
  // enter the post-stimulus period here, in ms. (ex ""   delay(30000); "" )
  
  //------------------------------------------------------------------------------------ENTER PROGRAM INFORMATION ABOVE THIS LINE-----------------------------------------------------------  



}

void runBlock(int repeats, unsigned long duration, unsigned long recovery, long frequency, long pulse_width, int pwm) {
  for(int x = 0; x < repeats; x++) {
    pulseTrain(millis(), duration, frequency, pulse_width, pwm);
    delay(recovery);
  }
}

void pulseTrain(unsigned long pulseBegin, unsigned long duration, long frequency, long pulse_width, int pwm) {

  while ((millis() - pulseBegin) <= duration){
    analogWrite(stimPin, pwm);
    delay(pulse_width);
    digitalWrite(stimPin, LOW);
    delay((1000L/frequency) - pulse_width);
  }

}  
  

void loop() {
  

    if (lastButtonState == HIGH) {
      programRun(millis());
    }
    lastButtonState = LOW;

}
