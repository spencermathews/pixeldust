/*
 * Pixeldust first stab
 *
 * Pixels move by random walk
 *
 * Spencer Mathews, began: 3/2017
 */

PImage img;
PVector[] particles;

// set scale factor on image, i.e. how much to shrink
float scaleImg = 2;

// should adjust this so that we specify how many particles per pure black pixel
// and also ensure that full density -> pure black when reconstituted
// set scale factor for splitting pixels
int scaleSplit = 255/5;  // denominator is how many particles to spawn for each pure black pixel

void setup () {
  size(1, 1);
  surface.setResizable(true); // enable resizable display window

  img = loadImage("MandelaNew.jpg");        // create PImage
  img.resize(floor(img.width/scaleImg), 0); // scale image

  surface.setSize(img.width, img.height); // set display window to image size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  surface.setLocation(0, 0);

  imgStats(img);

  // make sure we don't overflow int range
  particles = particleSplit(img);

  println(Integer.MIN_VALUE, Integer.MAX_VALUE);
}

void draw() {

  moveParticles(particles, img);
  particleMerge(particles, img);

  image(img, 0, 0);
}


/*
 * Gather and print image statistics
 *
 * param img
 */
void imgStats(PImage img) {

  img.loadPixels();
  println(img.pixels.length, "pixels");

  /* initialize vars to track max values */
  float maxR = 0;
  float maxG = 0;
  float maxB = 0;
  float maxA = 0;
  float maxH = 0;
  float maxS = 0;
  float maxV = 0;

  // Loop through pixels in 1D
  for (int i = 0; i < img.pixels.length; i++) {
    color p = img.pixels[i];

    /* decompose pixel */
    float r = red(p);
    float g = green(p);
    float b = blue(p);
    float a = alpha(p);
    float h = hue(p);
    float s = saturation(p);
    float v = brightness(p);

    /* update max values */
    if (r > maxR) maxR=r;
    if (g > maxG) maxG=g;
    if (b > maxB) maxB=b;
    if (a > maxA) maxA=a;
    if (h > maxH) maxH=h;
    if (s > maxS) maxS=s;
    if (v > maxV) maxV=v;
  }

  println("RGBA(", maxR, maxG, maxB, maxA, ")");
  println("HSBA(", maxH, maxS, maxV, maxA, ")");

  //img.updatePixels();
}

/*
 * Determine number of particles in entire image
 *
 * Assuming a pixels spawns a number of particles equal to its brightness (v).
 *
 * Note: Processing does not have unsigned int, and lacks real support for long
 *
 * param img
 * return number of particles
 */
int numParticles(PImage img) {

  img.loadPixels();  // make pixels[] array available

  int sumV = 0;
  // Loop through pixels in 1D
  for (int i = 0; i < img.pixels.length; i++) {
    color c = img.pixels[i];

    sumV += pixelSplit(c);  // int cast redundant when incrementing an int var
  }

  println(sumV, "particles from", img.pixels.length, "pixels");

  //img.updatePixels();

  return sumV;
}

/*
 * Decompose pixels into particles based on darkness
 *
 * Uses global scale factor and inverts brightness, pure black pixel will spawn 255 particles.
 *
 * param  c color
 * return   int   number of effective particles
 */
int pixelSplit(color c) {
  return int((255-brightness(c))/scaleSplit);
}

/*
 * Merge pixels, should probably modify to take a color and pick it apart in the function
 *
 * Convert particle density to color value. 
 *
 * param  b int   brightness
 * return   color
 */
color pixelMerge(int b) {
  float v = 255 - b * scaleSplit;
  return color(v);
}


/*
 * Create particles
 *
 * Spawns a number of particles from image using pixelSplit
 *
 * Could be merged with numParticles, but kept separate for clarity.
 *
 * param  img PImage
 * return     PVector[]
 */
PVector[] particleSplit(PImage img) {

  /* declare and initialize particle vector */
  int numParticles = numParticles(img);

  PVector[] particles = new PVector[numParticles];
  for (int i = 0; i < particles.length; i++) {
    particles[i] = new PVector();  // could be combined with assignment below
  }

  img.loadPixels();

  int i = 0;
  // Loop through pixels in 2D
  // Loop through every pixel column
  for (int y = 0; y < img.height; y++) {
    // Loop through every pixel column
    for (int x = 0; x < img.width; x++) {
      // Use the formula to find the 1D location
      int loc = x + y * img.width;

      int n = pixelSplit(img.pixels[loc]);  // compute number of particles to spawn from this pixel
      while (n>0) {
        particles[i].set(x, y);  // set location of this particle
        n--;
        i++;
      }
    }
  }

  //img.updatePixels();

  return particles;
}

/*
 * Merge particles into image
 *
 * Merge particles using pixelMerge
 *
 * param particles PVector[] array of particle positions
 * param img       PImage    image to populate
 */
void particleMerge(PVector[] particles, PImage img) {
  //img = new PImage;
  img.loadPixels();

  /* zero image */
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color(0);
  }

  /* sum particle density through pixel brightness */
  for (int i = 0; i < particles.length; i++) {
    // find the 1D location of particle in img
    int loc = int(particles[i].x) + int(particles[i].y) * img.width;
    // hack, to accumulate values in img, scale later
    int particleCount = int(brightness(img.pixels[loc]));
    img.pixels[loc] = color(particleCount + 1);
  }

  /* scale image and invert */
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = pixelMerge(int(brightness(img.pixels[i])));
  }

  img.updatePixels();
}

/*
 * Update particles
 *
 * Testing
 *
 * param particles PVector[] array of particle positions
 * param img       PImage    image reference
 */
void moveParticles(PVector[] particles, PImage img) {

  int moveX, moveY;
  for (int i = 0; i < particles.length; i++) {
    if (random(-1, 1) < 0) {
      moveX = -1;
    } else {
      moveX = 1;
    }
    if (random(-1, 1) < 0) {
      moveY = -1;
    } else {
      moveY = 1;
    }
    
    particles[i].x = constrain(particles[i].x + moveX, 0, img.width-1);
    particles[i].y = constrain(particles[i].y + moveY, 0, img.height-1);
  }
}