#include <SoftwareSerial.h>
#include <Servo.h>
#include "pins-slave.h"

SoftwareSerial MasterSerial(NANO_RX, NANO_TX);

Servo servoLeftLift;
Servo servoLeftElbow;
Servo servoRightLift;
Servo servoRightElbow;
Servo servoRightGrip;

int leftLiftAngle = 90;
int leftElbowAngle = 90;
int rightLiftAngle = 90;
int rightElbowAngle = 90;
int rightGripAngle = 100;

const int STEP = 10;

int clampServoAngle(int angle) {
  if (angle < 0) return 0;
  if (angle > 180) return 180;
  return angle;
}

void applyServoPositions() {
  servoLeftLift.write(leftLiftAngle);
  servoLeftElbow.write(leftElbowAngle);
  servoRightLift.write(rightLiftAngle);
  servoRightElbow.write(rightElbowAngle);
  servoRightGrip.write(rightGripAngle);
}

void resetArm() {
  leftLiftAngle = 90;
  leftElbowAngle = 90;
  rightLiftAngle = 90;
  rightElbowAngle = 90;
  rightGripAngle = 100;
  applyServoPositions();
}

void setup() {
  Serial.begin(9600);
  MasterSerial.begin(9600);
  MasterSerial.listen();

  servoLeftLift.attach(SERVO_LEFT_LIFT);
  servoLeftElbow.attach(SERVO_LEFT_ELBOW);
  servoRightLift.attach(SERVO_RIGHT_LIFT);
  servoRightElbow.attach(SERVO_RIGHT_ELBOW);
  servoRightGrip.attach(SERVO_RIGHT_GRIP);

  resetArm();
}

void loop() {
  if (MasterSerial.available()) {
    char data = MasterSerial.read();
    Serial.print("Command received: ");
    Serial.println(data);

    switch (data) {
      case 'I': // Left lift up
        leftLiftAngle = clampServoAngle(leftLiftAngle + STEP);
        break;
      case 'K': // Left lift down
        leftLiftAngle = clampServoAngle(leftLiftAngle - STEP);
        break;
      case 'J': // Left elbow up
        leftElbowAngle = clampServoAngle(leftElbowAngle + STEP);
        break;
      case 'L': // Left elbow down
        leftElbowAngle = clampServoAngle(leftElbowAngle - STEP);
        break;
      case 'T': // Right lift up
        rightLiftAngle = clampServoAngle(rightLiftAngle + STEP);
        break;
      case 'G': // Right lift down
        rightLiftAngle = clampServoAngle(rightLiftAngle - STEP);
        break;
      case 'Y': // Right elbow up
        rightElbowAngle = clampServoAngle(rightElbowAngle + STEP);
        break;
      case 'H': // Right elbow down
        rightElbowAngle = clampServoAngle(rightElbowAngle - STEP);
        break;
      case 'U': // Right grip open
        rightGripAngle = clampServoAngle(rightGripAngle + STEP);
        break;
      case 'N': // Right grip close
        rightGripAngle = clampServoAngle(rightGripAngle - STEP);
        break;
      case 'X': // Reset arm
        resetArm();
        return;
      default:
        break;
    }

    applyServoPositions();
  }
}