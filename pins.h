#ifndef PINS_H
#define PINS_H

// ===============================
// Front Driver (L298N)
// ===============================
const int ENA = 10;  // PWM - Front Left
const int IN1 = 8;   // Front Left  - IN1
const int IN2 = 7;   // Front Left  - IN2

const int ENB = 9;   // PWM - Front Right
const int IN3 = 4;   // Front Right - IN1
const int IN4 = 2;   // Front Right - IN2

// ===============================
// Back Driver (L298N)
// ===============================
const int ENC = 6;   // PWM - Back Left
const int IN5 = 13;  // Back Left  - IN1 as
const int IN6 = 12;  // Back Left  - IN2

const int END = 5;   // PWM - Back Right
const int IN7 = A0;  // Back Right - IN1
const int IN8 = A1;  // Back Right - IN2 test testt

#endif