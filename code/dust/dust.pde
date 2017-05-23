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

  pd = new Pixeldust("MandelaNew.jpg", 2, 5); // create PImage;

  surface.setSize(int(pd.imgWidth()), int(pd.imgHeight()));  // set display window to image size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  surface.setLocation(0, 0);

  noSmooth();  // may increase performance
}

void draw() {
  //pd.updateForward(0);
  //pd.update();

  //pd.display();
  //pd.displayParticles(1);

  surface.setTitle(int(frameRate) + " fps");
}