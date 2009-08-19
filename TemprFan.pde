
// Program TemprFan

// *** Definitioner ***

// Vilken pinne tryckknappen är insatt i 
const byte BUTTON_PIN = 8;
const byte FAN_PIN    = 7;
const byte LED_PIN    = 6;
const byte TEST_PIN   = 5;

// Vilken pinne temperatur (LM35) sensorn är insatt i
const byte TEMPR_SENSOR_PIN = 1;


// *** Globala variablar ***

// Håller den inlästa temperaturen
int temperetatur  = -1;
float temprOld    = -1;

// För att undvika flytande värden, så spara det föregående tryck statusen på knappen
int buttonStateGammalt = 0;
int oldFanStatus = 0;


// *** Hjälp funktioner ***


// Läser ut nuvarande status på knappen
// För att undvika falska alarm så sov en stund om man har fått nytt värde
// 
// Returns: Returnerar true (1) om knappen är nedtryckt, annars false (0)
int readButtonStatus() {
  int buttonState = digitalRead(BUTTON_PIN);
  if ((buttonState == HIGH) && (buttonStateGammalt == LOW)) {
     buttonState = 1 - buttonState;
     delay(20);
     buttonStateGammalt = buttonState;
     return true;
  }
  
  return false;
}


// Mäter temperaturen från en LM35 sensor
// Mäter ett visst antal gånger och ger genomsnittsvärdet
// Funktionen har en inbyggd delay på några sekunder
//
// Return: Returnerar temperaturen i Celsius grader
float readTemprSensor() {
//  const int numMeasurements = 8;  // Hur många mätningar ska det göras, per returnerat värde
  
  float temprValue = 0;
  float sensorValue = analogRead(TEMPR_SENSOR_PIN);


  temprValue = ((5.0 * sensorValue * 100.0) / 1024.0);
//   samples[i] = (5.0 * sensorValue * 100.0)/1024.0;
//  temprValue = sensorValue;
    

/*
    Serial.println(sensorValue);
    Serial.println(samples[i]);
    Serial.println("");
*/    
    
    delay(1000);
  
//  return temprValue / numMeasurements;
  return temprValue;
}


void setFanOn() {
  digitalWrite(FAN_PIN, HIGH);
}

void setFanOff() {
  digitalWrite(FAN_PIN, LOW);
  delay(500);
}


void setLedOn() {
  digitalWrite(LED_PIN, HIGH);
}

void setLedOff() {
  digitalWrite(LED_PIN, LOW);
}



// Kontrollera fläkten från tryck knappen
bool fanOn = false;
void fanPushButton() {
  int buttonState = readButtonStatus();

  if ((buttonState == 1) && (fanOn == true)) {
    setFanOff();
    fanOn = false;
    delay(1000);
  }
  else if ((buttonState == 1) && (fanOn == false)) {
    setFanOn();
    fanOn = true;
    delay(1000);
  }
}

// Kontrollera fläkten från tangentbordet
// t = fläkt på
// f = fläkt av
void fanKeyboard() {
  char kbdChr;
  if (Serial.available() > 0) {
    kbdChr = Serial.read();
  }
  
  if (kbdChr == 't') {
    setFanOn();
  digitalWrite(TEST_PIN, HIGH);
  }
  else if (kbdChr == 'f') {
    setFanOff();
  digitalWrite(TEST_PIN, LOW);
  }
}

// *** Arduino funktioner ***

void setup() {
  Serial.begin(9600);
  pinMode(BUTTON_PIN,       INPUT);
  pinMode(TEMPR_SENSOR_PIN, INPUT);

  pinMode(FAN_PIN,          OUTPUT);
  pinMode(LED_PIN,          OUTPUT);
  pinMode(TEST_PIN,         OUTPUT);

}

void loop() {

  float sensorValue = analogRead(TEMPR_SENSOR_PIN);
  fanPushButton();
  fanKeyboard();
  float temprValue = readTemprSensor();
  if (temprValue != temprOld) {
    Serial.println(temprValue);    
  }
  temprOld = temprValue;
  if (temprValue >= 28) {
    setFanOn();
  }
  else {
    setFanOff();
  }
}
