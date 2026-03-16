#include "Arduino.h"
#include "bluetooth.h"

SoftwareSerial BTSerial(BT_RX, BT_TX);

void bluetoothSetup() {
  BTSerial.begin(38400);
  Serial.println("Waiting for EduConnect commands...");
}

char bluetoothLoop() {
  if (BTSerial.available()) {
    char data = BTSerial.read();
    Serial.print("Command sent: ");
    Serial.println(data);
    return data;
  }
  return '\0';
}