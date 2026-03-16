#include "Arduino.h"
#include "movement.h"


// Add delay for function?

void setSpeed(int speed) {
  analogWrite(ENA, speed);
  analogWrite(ENB, speed);
}

void moveForward(int speed) {
  setSpeed(speed);
  digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);   // Left  - Fwd
  digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);   // Right - Fwd
}

void moveReverse(int speed) {
  setSpeed(speed);
  digitalWrite(IN1, LOW); digitalWrite(IN2, HIGH);   // Left  - Rev
  digitalWrite(IN3, LOW); digitalWrite(IN4, HIGH);   // Right - Rev
}

void turnRight(int speed) {
  setSpeed(speed);
  digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);   // Left  - Fwd
  digitalWrite(IN3, LOW);  digitalWrite(IN4, HIGH);  // Right - Rev
}

void turnLeft(int speed) {
  setSpeed(speed);
  digitalWrite(IN1, LOW);  digitalWrite(IN2, HIGH);  // Left  - Rev
  digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);   // Right - Fwd
}

void stopMotors() {
  setSpeed(0);
  digitalWrite(IN1, LOW); digitalWrite(IN2, LOW);   // Left   - Stop
  digitalWrite(IN3, LOW); digitalWrite(IN4, LOW);   // Right  - Stop
}