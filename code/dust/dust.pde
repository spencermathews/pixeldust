/*
 * Pixeldust first stab implemented as a class
 *
 * Pixels move by random walk
 *
 * Spencer Mathews, began: 3/2017
 */

Pixeldust pd;
Attractor[] attractors;

void setup () {
  size(1, 1);
  surface.setResizable(true); // enable resizable display window

  pd = new Pixeldust("MandelaNew.jpg", 5); // create PImage;

  surface.setSize(int(pd.imgWidth()), int(pd.imgHeight()));  // set display window to image size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  surface.setLocation(0, 0);
  
  attractors = pd.createAttractors(4);
}

void draw() {
  //pd.update();
  pd.updateAttractors(attractors);

  pd.display();
}