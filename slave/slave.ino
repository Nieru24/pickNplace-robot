#include <SoftwareSerial.h>
#include <Servo.h>
#include "pins-slave.h"

SoftwareSerial MasterSerial(NANO_RX, NANO_TX);

Servo servoLeft1;   // Left  - Side
Servo servoLeft2;   // Left  - Elevation
Servo servoRight1;  // Right - Side
Servo servoRight2;  // Right - Elevation

void setup() {
  Serial.begin(9600);
  MasterSerial.begin(9600);

  servoLeft1.attach(SERVO_LEFT_1);
  servoLeft2.attach(SERVO_LEFT_2);
  servoRight1.attach(SERVO_RIGHT_1);
  servoRight2.attach(SERVO_RIGHT_2);
}

void loop() {
  if (MasterSerial.available()) {
    char cmd = MasterSerial.read();
    Serial.print("Command received: ");
    Serial.println(cmd);

    switch (cmd) {
      case 'O': // Open gripper
        servoLeft1.write(90);
        servoRight1.write(90);
        break;
      case 'C': // Close gripper
        servoLeft1.write(0);
        servoRight1.write(0);
        break;
      case 'U': // Elevate up
        servoLeft2.write(90);
        servoRight2.write(90);
        break;
      case 'D': // Elevate down
        servoLeft2.write(0);
        servoRight2.write(0);
        break;
    }
  }
}