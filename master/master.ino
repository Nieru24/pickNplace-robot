#include <SoftwareSerial.h>

#include "movement.h"
#include "bluetooth.h"

void setup() {
  Serial.begin(9600);

  // L298N Driver
  pinMode(ENA, OUTPUT); pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT);
  pinMode(ENB, OUTPUT); pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT);

  bluetoothSetup();
}

void loop() {

  switch (bluetoothLoop()) {
    case 'W': moveForward(150);  break;
    case 'S': moveReverse(150);  break;
    case 'D': turnRight(150);    break;
    case 'A': turnLeft(150);     break;
    case 'Q': stopMotors();      break;
  }
}