const int stimPin =  6;      // stimulus: on (pulsed) during stimulus bouts                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      const int stimPin =  6;      // stimulus: on (pulsed) during stimulus bouts
const int FramePin =  4;      // indicator: on (constant) during stimulus bouts
const int CamFramePin =  5;
const int initPin = 7;

void setup() {
  Serial.begin(9600);
  pinMode(stimPin, OUTPUT);
  pinMode(FramePin, OUTPUT);
  pinMode(CamFramePin, OUTPUT);
  pinMode(initPin, INPUT);
}

void loop() {
  Serial.print("S");
  digitalWrite(FramePin, HIGH);
  // delay(17.4+5*10*17.4);
  delay(1000);
  digitalWrite(FramePin, LOW);
  //Serial.println("E");
  delay(1000);
} 