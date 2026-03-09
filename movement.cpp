#include "Arduino.h"
#include "movement.h"

void setSpeed(int speed) {
  analogWrite(ENA, speed);
  analogWrite(ENB, speed);
  analogWrite(ENC, speed);
  analogWrite(END, speed);
}

void moveForward(int speed) {
  setSpeed(speed);
  // Front driver
  digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);   // Front Left  - Fwd
  digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);   // Front Right - Fwd
  // Back driver
  digitalWrite(IN5, HIGH); digitalWrite(IN6, LOW);   // Back Left   - Fwd
  digitalWrite(IN7, HIGH); digitalWrite(IN8, LOW);   // Back Right  - Fwd
}

void moveReverse(int speed) {
  setSpeed(speed);
  // Front driver
  digitalWrite(IN1, LOW); digitalWrite(IN2, HIGH);   // Front Left  - Rev
  digitalWrite(IN3, LOW); digitalWrite(IN4, HIGH);   // Front Right - Rev
  // Back driver
  digitalWrite(IN5, LOW); digitalWrite(IN6, HIGH);   // Back Left   - Rev
  digitalWrite(IN7, LOW); digitalWrite(IN8, HIGH);   // Back Right  - Rev
}

void turnRight(int speed) {
  setSpeed(speed);
  // Left side Forward, Right side Reverse
  digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);   // Front Left  - Fwd
  digitalWrite(IN3, LOW);  digitalWrite(IN4, HIGH);  // Front Right - Rev
  digitalWrite(IN5, HIGH); digitalWrite(IN6, LOW);   // Back Left   - Fwd
  digitalWrite(IN7, LOW);  digitalWrite(IN8, HIGH);  // Back Right  - Rev
}

void turnLeft(int speed) {
  setSpeed(speed);
  // Right side Forward, Left side Reverse
  digitalWrite(IN1, LOW);  digitalWrite(IN2, HIGH);  // Front Left  - Rev
  digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);   // Front Right - Fwd
  digitalWrite(IN5, LOW);  digitalWrite(IN6, HIGH);  // Back Left   - Rev
  digitalWrite(IN7, HIGH); digitalWrite(IN8, LOW);   // Back Right  - Fwd
}

void stopMotors() {
  setSpeed(0);
  digitalWrite(IN1, LOW); digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW); digitalWrite(IN4, LOW);
  digitalWrite(IN5, LOW); digitalWrite(IN6, LOW);
  digitalWrite(IN7, LOW); digitalWrite(IN8, LOW);
}