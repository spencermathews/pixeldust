import processing.sound.*;

/*
 * Pixeldust
 *
 * Spencer Mathews, began: 3/2017
 */

Pixeldust pd;
PixeldustSimulation sim;

int lastTime;

void setup () {
  size(1, 1);
  surface.setResizable(true); // enable resizable display window

  String csvFileName = "Mandela-timing.csv";
  float scaleImg = 2;
  int particlesPerPixel = 4;
  sim = new PixeldustSimulation(this, csvFileName, scaleImg, particlesPerPixel);

  surface.setSize(sim.width, sim.height);  // set display window to simulation size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  //surface.setLocation(0, 0);

  noSmooth();  // may increase performance

  sim.begin();
}

void draw() {
  sim.run();

  int currentTime = millis();
  if (millis() - lastTime > 100) {
    int elapsedTime = (millis() - sim.startTime)/1000;
    int min = elapsedTime/60;  // use int division to our advantage
    int sec = elapsedTime % 60;
    
    surface.setTitle(min + ":" + nf(sec,2) + " / " + int(frameRate) + " fps");
    
    lastTime = millis();
  }
}