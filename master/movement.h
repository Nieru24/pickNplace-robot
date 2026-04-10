#ifndef MOVEMENT_H
#define MOVEMENT_H

#include "pins.h"

extern int currentSpeed;

void setSpeed(int speed);
void increaseSpeed(int step);
void decreaseSpeed(int step);
void moveForward();
void moveReverse();
void turnRight();
void turnLeft();
void stopMotors();

#endif