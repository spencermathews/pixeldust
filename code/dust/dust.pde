/*
 * Pixeldust first stab implemented as a class
 *
 * Pixels move by random walk
 *
 * Spencer Mathews, began: 3/2017
 */

Pixeldust pd;

float alpha = 0;

void setup () {
  size(1, 1);
  surface.setResizable(true); // enable resizable display window

  pd = new Pixeldust("MandelaNew.jpg", 2, 5); // create PImage;

  surface.setSize(int(pd.imgWidth()), int(pd.imgHeight()));  // set display window to image size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  surface.setLocation(0, 0);

  //noSmooth();  // may increase performance
}

void draw() {
  //background(255);
  if (frameCount<30) {
    pd.update();
    pd.display();
  } else {
    if (pd.numPixelsOver > 3000) {
      pd.updateForward();
      pd.display();
    } else {

      float target = 16;
      println(alpha);
      if (alpha < target) {
        pd.updateForward();
        pd.display();
        alpha += (target - alpha)/2;
        tint(255, alpha);
        //blendMode(DARKEST);
        image(pd.imgPixelsOrig, 0, 0);
      } else {
        //background(255);
        tint(255, 255);
        pd.update();
        pd.display();
      }
    }
  }

  surface.setTitle("frame " + frameCount + " @ " + int(frameRate) + " fps");
}