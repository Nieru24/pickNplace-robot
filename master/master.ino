#include "movement.h"
#include "bluetooth.h"
#include "pins.h"

#include <SoftwareSerial.h>
SoftwareSerial NanoSerial(NANO_RX, NANO_TX);



void setup() {
  Serial.begin(9600);
  NanoSerial.begin(9600);

  // L298N Driver
  pinMode(ENA, OUTPUT); pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT);
  pinMode(ENB, OUTPUT); pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT);

  bluetoothSetup();
}

void loop() {

  switch (bluetoothLoop()) {
    case 'W': moveForward(150);       break;
    case 'S': moveReverse(150);       break;
    case 'D': turnRight(150);         break;
    case 'A': turnLeft(150);          break;
    case 'Q': stopMotors();           break;

    case 'O': NanoSerial.write('O');  break;
    case 'C': NanoSerial.write('C');  break;
    case 'U': NanoSerial.write('U');  break;
    case 'E': NanoSerial.write('D');  break;
  }
}