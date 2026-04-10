#ifndef BLUETOOTH_H
#define BLUETOOTH_H

#include <SoftwareSerial.h>
#include "pins.h"

extern SoftwareSerial BTSerial;

void bluetoothSetup();
char bluetoothLoop();
void sendSpeed();

#endif