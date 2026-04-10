#include "HardwareSerial.h"
#include "Print.h"
#include "Arduino.h"
#include "bluetooth.h"
#include "movement.h"


SoftwareSerial BTSerial(BT_RX, BT_TX);

void bluetoothSetup() {
  BTSerial.begin(9600);
  Serial.begin(9600);
  BTSerial.listen();
  Serial.println("BluetoothCpp Good");
  BTSerial.print(currentSpeed);
}

char bluetoothLoop() {
  if (BTSerial.available()) {
    char data = BTSerial.read();
    Serial.print("Data: ");
    Serial.println(data);
    return data;
  }
  return '\0';
}

void sendSpeed() {
  BTSerial.print(currentSpeed);
}
