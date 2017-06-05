import processing.sound.*;

/*
 * Pixeldust
 *
 * Spencer Mathews, began: 3/2017
 */

String[] csvFileNames = {"Mandela-timing.csv", "Davis-timing.csv"};

Pixeldust pd;
PixeldustSimulation sim;

int lastTime;  // keeps track of timer for fps in title

void setup () {
  size(1, 1, FX2D);
  surface.setResizable(true); // enable resizable display window

  noSmooth();  // may increase performance

  noLoop();
  begin();

  lastTime = 0;
}

void draw() {
  int isComplete = sim.run();  // iterate simulation
  //if (isComplete == 1) {
  //  noLoop();
  //}

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

  //String csvFileName = csvFileNames[int(random(csvFileNames.length))];
  String csvFileName = csvFileNames[1];
  float scaleImg = 4;
  int particlesPerPixel = 2;
  sim = new PixeldustSimulation(this, csvFileName, scaleImg, particlesPerPixel);

  surface.setSize(sim.width, sim.height);  // set display window to simulation size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  //surface.setLocation(0, 0);

  sim.begin();
  loop();
}