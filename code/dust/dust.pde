import processing.sound.*;
import processing.net.*;


/*
 * Pixeldust
 *
 * Spencer Mathews, began: 3/2017
 */

String[] csvFileNames = {"Mandela-timing.csv", "Davis-timing.csv"};
PixeldustSimulation sim;
int lastTime;  // keeps track of timer for fps in title
int isComplete;

Client c;
int lastNetTime; // timer for network client, trigger polling

boolean useNet = true;  // set to false to disable network triggering


void setup () {
  size(100, 100);
  surface.setResizable(true); // enable resizable display window

  noSmooth();  // may increase performance

  lastTime = 0;
  isComplete = 1;
  lastNetTime = 0;

  if (useNet == true) {
    c = new Client(this, "192.168.1.1", 12345);
  }
}

void draw() {
  // Seemingly reduntant, but we want to enable a stopped state
  // however draw is still run once even if we stop loop
  if (isComplete == 0) {
    run();
  }

  if (useNet == true) {
    // read byte from network trigger and begin person if ready for it
    // but need to clear buffer 
    int currentTime = millis();
    if (currentTime - lastNetTime > 1000) {
      // Receive data from server
      if (c.available() > 0) {
        int input = c.read();
        c.clear();  // clear buffer so bytes don't accumulate
        print("\nTrigger received:");

        // begin a person if not already running
        if (isComplete == 1) {
          println(" Starting");
          begin();
        } else {
          println(" Ignoring");
        }
      }
      lastNetTime = millis();
    }
  }
}


// interates a person/simulation object
void run() {
  // set isComplete to 1 after person is finished
  isComplete = sim.run();  // iterate simulation

  int currentTime = millis();
  if (currentTime - lastTime > 100) {
    int elapsedTime = (currentTime - sim.startTime)/1000;
    int min = elapsedTime / 60;  // use int division to our advantage
    int sec = elapsedTime % 60;

    surface.setTitle(min + ":" + nf(sec, 2) + " / " + int(frameRate) + " fps");

    lastTime = millis();
  }
}


void begin() {

  String csvFileName = csvFileNames[int(random(csvFileNames.length))];
  float scaleImg = 2;
  int particlesPerPixel = 4;
  sim = new PixeldustSimulation(this, csvFileName, scaleImg, particlesPerPixel);

  surface.setSize(sim.width, sim.height);  // set display window to simulation size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  //surface.setLocation(0, 0);

  sim.begin();
  isComplete = 0;
}


// start simulation on mousePressed
void mousePressed() {
  // Stop playing audio so we can begin again
  // Effectively identical to isComplete==0, but aways guarantees stop
  if (sim != null) {
    sim.audio.stop();  // hack, would be better to have sim.stop, but this is just for testing
  }
  begin();
}