#include <Servo.h>
#include <SoftwareSerial.h>
#include <AFMotor.h>

SoftwareSerial BTSerial(A0, A1);

const int servo1pin = 10;
const int servo2pin = 7;
const int servo3pin = 4;

int servo1angle = 90;
int servo2angle = 90;
int servo3angle = 90;

Servo servo1;
Servo servo2;
Servo servo3;

void setup() {
  servo1.attach(servo1pin);
  servo2.attach(servo2pin);
  servo3.attach(servo3pin);

  Serial.begin(9600);
  BTSerial.begin(38400);
}

void loop() {
  if (BTSerial.available()) {
    char data = BTSerial.read(); // Read the character sent from the app
    Serial.print("Command sent:");
    Serial.println(data);

    if(data == 'A'){ 
        if(servo1angle < 180) servo1angle += 5; // Increase by 5 for smoother/faster feel
      }
      else if(data == 'B'){ 
        if(servo1angle > 0) servo1angle -= 5;
      }
      
      // Servo 2: Shoulder
      else if(data == 'C'){ 
        if(servo2angle < 180) servo2angle += 5;
      }
      else if(data == 'D'){ 
        if(servo2angle > 0) servo2angle -= 5;
      }
      
      // Servo 3: Elbow/Gripper
      else if(data == 'F'){ 
        if(servo3angle < 180) servo3angle += 5;
      }
      else if(data == 'G'){ 
        if(servo3angle > 0) servo3angle -= 5;
      }

    servo1angle = min(servo1angle,180);
    servo1angle = max(servo1angle,0);
    servo2angle = min(servo2angle,180);
    servo2angle = max(servo2angle,0);
    servo3angle = min(servo3angle,180);
    servo3angle = max(servo3angle,0);

    servo1.write(servo1angle);
    servo2.write(servo2angle);
    servo3.write(servo3angle);

    Serial.print(servo1angle);
    Serial.print(" ");
    Serial.print(servo2angle);
    Serial.print(" ");
    Serial.println(servo3angle);

    delay(1);
  }

}