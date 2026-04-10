#include "movement.h"
#include "bluetooth.h"
#include "pins.h"

SoftwareSerial NanoSerial(NANO_RX, NANO_TX);

void setup() {
  NanoSerial.begin(9600);

  // L298N Driver
  pinMode(ENA, OUTPUT); pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT);
  pinMode(ENB, OUTPUT); pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT);

  bluetoothSetup();
}

void loop() {
  switch (bluetoothLoop()) {
    case 'W': moveForward();                    break;
    case 'S': moveReverse();                    break;
    case 'D': turnRight();                      break;
    case 'A': turnLeft();                       break;
    case 'Q': stopMotors();                     break;
    case '+': increaseSpeed(10); sendSpeed();   break;
    case '-': decreaseSpeed(10); sendSpeed();   break;

    case 'O': NanoSerial.write('O');            break;
    case 'C': NanoSerial.write('C');            break;
    case 'U': NanoSerial.write('U');            break;
    case 'E': NanoSerial.write('D');            break;

    case 'I': NanoSerial.write('I');            break;
    case 'K': NanoSerial.write('K');            break;
    case 'J': NanoSerial.write('J');            break;
    case 'L': NanoSerial.write('L');            break;
    case 'T': NanoSerial.write('T');            break;
    case 'G': NanoSerial.write('G');            break;
    case 'Y': NanoSerial.write('Y');            break;
    case 'H': NanoSerial.write('H');            break;
    case 'N': NanoSerial.write('N');            break;
    case 'X': NanoSerial.write('X');            break;
  }
}