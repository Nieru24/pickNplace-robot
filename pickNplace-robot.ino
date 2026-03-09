#include "movement.h"

void setup() {
  // Front driver
  pinMode(ENA, OUTPUT); pinMode(IN1, OUTPUT); pinMode(IN2, OUTPUT);
  pinMode(ENB, OUTPUT); pinMode(IN3, OUTPUT); pinMode(IN4, OUTPUT);

  // Back driver
  pinMode(ENC, OUTPUT); pinMode(IN5, OUTPUT); pinMode(IN6, OUTPUT);
  pinMode(END, OUTPUT); pinMode(IN7, OUTPUT); pinMode(IN8, OUTPUT);
}

void loop() {
  moveForward(150);
  delay(2000);

  moveReverse(150);
  delay(2000);

  turnRight(150);
  delay(800);

  turnLeft(150);
  delay(800);

  stopMotors();
  delay(2000);
}