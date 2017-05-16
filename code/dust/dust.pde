/*
 * Pixeldust first stab implemented as a class
 *
 * Pixels move by random walk
 *
 * Spencer Mathews, began: 3/2017
 */

Pixeldust pd;

void setup () {
  size(1, 1);
  surface.setResizable(true); // enable resizable display window

  pd = new Pixeldust("MandelaNew.jpg", 2, 5); // create PImage;

  surface.setSize(int(pd.imgWidth()), int(pd.imgHeight()));  // set display window to image size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  surface.setLocation(0, 0);
}

void draw() {
  pd.updateForward();
  pd.display();
}