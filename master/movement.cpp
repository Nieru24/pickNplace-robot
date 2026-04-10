#include "Arduino.h"
#include "movement.h"

int currentSpeed = 150;

void setSpeed(int speed) {
  currentSpeed = constrain(speed, 10, 250);
  analogWrite(ENA, currentSpeed);
  analogWrite(ENB, currentSpeed);
}

void increaseSpeed(int step) { setSpeed(currentSpeed + step); }
void decreaseSpeed(int step) { setSpeed(currentSpeed - step); }

void moveForward() {
  setSpeed(currentSpeed);
  digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);   // Left  - Fwd
  digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);   // Right - Fwd
}

void moveReverse() {
  setSpeed(currentSpeed);
  digitalWrite(IN1, LOW); digitalWrite(IN2, HIGH);   // Left  - Rev
  digitalWrite(IN3, LOW); digitalWrite(IN4, HIGH);   // Right - Rev
}

void turnRight() {
  setSpeed(currentSpeed);
  digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);   // Left  - Fwd
  digitalWrite(IN3, LOW);  digitalWrite(IN4, HIGH);  // Right - Rev
}

void turnLeft() {
  setSpeed(currentSpeed);
  digitalWrite(IN1, LOW);  digitalWrite(IN2, HIGH);  // Left  - Rev
  digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);   // Right - Fwd
}

void stopMotors() {
  analogWrite(ENA, 0);
  analogWrite(ENB, 0);
  digitalWrite(IN1, LOW); digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW); digitalWrite(IN4, LOW);
}