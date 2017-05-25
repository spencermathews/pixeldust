import processing.sound.*;

/*
 * Pixeldust
 *
 * Spencer Mathews, began: 3/2017
 */

Pixeldust pd;
PixeldustSimulation sim;

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

  surface.setTitle(int(frameRate) + " fps");
}