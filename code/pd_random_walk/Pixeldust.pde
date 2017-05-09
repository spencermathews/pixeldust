class Pixeldust {

  PImage img;
  PVector[] particles;  // array of particle positions

  // set scale factor on image, i.e. how much to shrink
  float scaleImg = 2;
  
  int particlesPerPixel = 6;  // if pixel is black
  
  // should adjust this so that we specify how many particles per pure black pixel
  // and also ensure that full density -> pure black when reconstituted
  // set scale factor for splitting pixels
  // TODO think about if this should be float or int, there are more particles when it's an int
  int brightnessPerParticle = 255 / particlesPerPixel;

  Pixeldust(String imgFile) {

    img = loadImage(imgFile);                 // create PImage
    img.resize(floor(img.width/scaleImg), 0); // scale image

    imgStats();

    // TODO make sure we don't overflow int range
    particleSplit();
    //println(Integer.MIN_VALUE, Integer.MAX_VALUE);
  }

  /*
   * Gather and print image statistics
   *
   * param img
   */
  void imgStats() {

    img.loadPixels();
    println(img.pixels.length, "pixels");

    // initialize vars to track max values
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

      // decompose pixel
      float r = red(p);
      float g = green(p);
      float b = blue(p);
      float a = alpha(p);
      float h = hue(p);
      float s = saturation(p);
      float v = brightness(p);

      // update max values
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
  int numParticles() {

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
    return int((255 - brightness(c)) / brightnessPerParticle);
  }

  /*
   * Determine pixel brightness based on how many particles occupy that pixel
   *
   * Convert particle density to color value. 
   *
   * param  numParticles int
   * return              color
   */
  color pixelMerge(int numParticles) {
    float b = 255 - numParticles * brightnessPerParticle;
    return color(b);
  }

  /*
   * Create particles
   *
   * Spawns a number of particles from image using pixelSplit
   *
   * Could be merged with numParticles, but kept separate for clarity.
   *
   */
  void particleSplit() {

    // declare and initialize particle vector
    int numParticles = numParticles();

    particles = new PVector[numParticles];
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new PVector();  // could be combined with assignment/set below
    }

    img.loadPixels();  // we only read so no need to img.updatePixels();

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
  }

  /*
   * Merge particles into image
   *
   * Merge particles using pixelMerge
   *
   */
  void particleMerge() {
    img.loadPixels();

    // zero image
    for (int i = 0; i < img.pixels.length; i++) {
      img.pixels[i] = color(0);
    }

    // sum particle density through pixel brightness
    for (int i = 0; i < particles.length; i++) {
      // find the 1D location of particle in img
      int loc = int(particles[i].x) + int(particles[i].y) * img.width;
      // hack, to accumulate values in img, scale later
      int particleCount = int(brightness(img.pixels[loc]));
      img.pixels[loc] = color(particleCount + 1);
    }

    // scale image and invert
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
   */
  void moveParticles() {

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

  // accessor function
  float imgWidth() {
    return img.width;
  }

  // accessor function
  float imgHeight() {
    return img.height;
  }

  void update() {
    moveParticles();
  }

  void display() {
    particleMerge();
    image(img, 0, 0);
  }
}