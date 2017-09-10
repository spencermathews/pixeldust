/* Translate Jesse's pixeldustsensor.py to Processing IO
 * and add SharedCanvasServer Net example
 */


import processing.io.*;
import processing.net.*;

Server s;
int serverPort = 12345;
int lastTime = 0;

boolean isPresent = true;

void setup() {
  size(100, 100);

  // Read output from PIR motion sensor (BOARD 11)
  GPIO.pinMode(17, GPIO.INPUT);

  // LED output pin (BOARD 3)
  GPIO.pinMode(2, GPIO.OUTPUT);

  s = new Server(this, serverPort);
}


void draw() {
  // only poll sensor every so often
  if (millis() - lastTime > 100) {
    pollSensor();
    lastTime = millis();
  }
}


void pollSensor() {

  int i = GPIO.digitalRead(17);

  // When output from motion sensor is LOW
  if (i == GPIO.LOW) {

    if (isPresent == true) {
      isPresent = false;
      println(frameCount, "Nobody is here", i);
      background(255, 0, 0);
    }

    // Turn OFF LED
    GPIO.digitalWrite(2, GPIO.LOW);

    // When output from motion sensor is HIGH
  } else if (i == GPIO.HIGH) {

    if (isPresent == false) {
      isPresent = true;
      println(frameCount, "Begin Pixeldust", i);
      background(0, 255, 0);
    }

    // Turn ON LED
    GPIO.digitalWrite(2, GPIO.HIGH);

    // notify client that prox sensor is triggered
    s.write(1);
  } else {
    println(frameCount, "Error!");
  }
}