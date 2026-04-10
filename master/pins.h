#ifndef PINS_H
#define PINS_H

// L298N Driver Pins
/* Initial Pins for reference

const int ENA = 10;   // PWM   - Left
const int IN1 = 8;    // Left  - IN1
const int IN2 = 7;    // Left  - IN2

const int ENB = 9;    // PWM   - Right
const int IN3 = 4;    // Right - IN1
const int IN4 = 2;    // Right - IN2
*/

const int ENA = 9;   // PWM   - Left
const int IN1 = 8;    // Left  - IN1
const int IN2 = 7;    // Left  - IN2

const int ENB = 6;    // PWM   - Right
const int IN3 = 5;    // Right - IN1
const int IN4 = 4;    // Right - IN2


// Slave Arduino Nano Pins
const int NANO_RX = 2; // PIN 3 OF ARDUINO NANO
const int NANO_TX = 3; // PIN 3 OF ARDUINO NANO


// HC-05 Bluetooth Module Pins 
const int BT_RX = A2; // TX OF HC-05
const int BT_TX = A3; // RX OF HC-05

#endif