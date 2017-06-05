import processing.sound.*;

/*
 * Pixeldust
 *
 * Spencer Mathews, began: 3/2017
 */

String[] csvFileNames = {"Mandela-timing.csv", "Davis-timing.csv"};

PixeldustSimulation sim;

int lastTime;  // keeps track of timer for fps in title

int isComplete;

void setup () {
  size(100, 100);
  surface.setResizable(true); // enable resizable display window

  noSmooth();  // may increase performance

  background(0, 255, 0);

  lastTime = 0;
  isComplete = 1;
}

void draw() {
  // Seemingly reduntant, but we want to enable a stopped state
  // however draw is still run once even if we stop loop
  if (isComplete == 0) {
    run();
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
  begin();
}