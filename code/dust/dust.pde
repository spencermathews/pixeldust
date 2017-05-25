import processing.sound.*;

/*
 * Pixeldust first stab implemented as a class
 *
 * Pixels move by random walk
 *
 * Spencer Mathews, began: 3/2017
 */

Pixeldust pd;
PixeldustSimulation sim;

void setup () {
  size(1, 1);
  surface.setResizable(true); // enable resizable display window

  String csvFileName = "Mandela-timing.csv";
  sim = new PixeldustSimulation(this, csvFileName);

  surface.setSize(sim.width, sim.height);  // set display window to simulation size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  surface.setLocation(0, 0);

  noSmooth();  // may increase performance
}

void draw() {


  surface.setTitle(int(frameRate) + " fps");
}