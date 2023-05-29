// Example 1 - Receiving single characters

const int FramePin =  4; 

char receivedChar;
boolean newData = false;

void setup() {

    Serial.begin(9600);
    Serial.println("<Arduino is ready>");

    while(Serial.read() != 'S'){}

    pinMode(FramePin, OUTPUT);
    digitalWrite(FramePin, HIGH);
    delay(500);
    digitalWrite(FramePin, LOW);
    delay(500);

}

void loop() {
    recvOneChar();
    showNewData();
}

void recvOneChar() {
    if (Serial.available() > 0) {
        receivedChar = Serial.read();
        newData = true;
    }
}

void showNewData() {

    if (newData == true) {

        // if(receivedChar == 'S'){
        // }

        Serial.print("This just in ... ");
        Serial.println(receivedChar);
        newData = false;
    }
}