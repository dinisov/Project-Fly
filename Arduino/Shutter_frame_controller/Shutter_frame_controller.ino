const int FramePin =  4;      // recording (2P) pin
const int ShutterPin = 2; //shutter (controller box) pin

int signal;

void setup()
{

  //open serial channel
  Serial.begin(9600);

  //weirdly, setting the pinMode triggers the pin being set
  pinMode(ShutterPin, OUTPUT);
  pinMode(FramePin, OUTPUT);

  //start both shutter and frame pins LOW
  digitalWrite(ShutterPin, HIGH);
  delay(100);
  digitalWrite(ShutterPin,LOW);
  digitalWrite(FramePin, LOW);

}

void loop() {

	signal = Serial.read();

	if(signal == 'S'){
		digitalWrite(ShutterPin, !digitalRead(ShutterPin));//toggle shutter
	}

	if(signal == 'F'){
		digitalWrite(FramePin, !digitalRead(FramePin));//toggle frame recording
	}

}