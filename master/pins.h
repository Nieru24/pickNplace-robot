#ifndef PINS_H
#define PINS_H

// L298N Driver Pins
const int ENA = 10;   // PWM   - Left
const int IN1 = 8;    // Left  - IN1
const int IN2 = 7;    // Left  - IN2

const int ENB = 9;    // PWM   - Right
const int IN3 = 4;    // Right - IN1
const int IN4 = 2;    // Right - IN2


// Slave Arduino Nano Pins
const int NANO_RX = A0;
const int NANO_TX = A1;


// HC-05 Bluetooth Module Pins 
const int BT_RX = A2;
const int BT_TX = A3;

#endif