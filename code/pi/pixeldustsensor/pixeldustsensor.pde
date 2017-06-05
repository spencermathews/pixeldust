/* Translate Jesse's pixeldustsensor.py to Processing IO
 *
 */

//import RPi.GPIO as GPIO
import processing.io.*;

//import time

boolean isPresent = true;

void setup() {
  //GPIO.setwarnings(False)

  //GPIO.setmode(GPIO.BOARD)

  //GPIO.setup(11, GPIO.IN)         #Read output from PIR motion sensor
  GPIO.pinMode(17, GPIO.INPUT);

  //GPIO.setup(3, GPIO.OUT)         #LED output pin
  GPIO.pinMode(2, GPIO.OUTPUT);

  frameRate(10);
}

//while True:
void draw() {

  //       i=GPIO.input(11)
  int i = GPIO.digitalRead(17);

  //       if i==0:                 #When output from motion sensor is LOW
  if (i == GPIO.LOW) {

    //             print("Nobody is here",i)
    if (isPresent == true) {
      isPresent = false;
      println(frameCount, "Nobody is here", i);
      background(255, 0, 0);
    }

    //             GPIO.output(3, 0)  #Turn OFF LED
    GPIO.digitalWrite(2, GPIO.LOW);

    //             time.sleep(0.1)

    //       elif i==1:               #When output from motion sensor is HIGH
  } else if (i == GPIO.HIGH) {

    //             print("Begin Pixeldust",i)
    if (isPresent == false) {
      isPresent = true;
      println(frameCount, "Begin Pixeldust", i);
      background(0, 255, 0);
    }

    //             GPIO.output(3, 1)  #Turn ON LED
    GPIO.digitalWrite(2, GPIO.HIGH);

    //             time.sleep(0.1)
  } else {
    println(frameCount, "Error!");
  }
}