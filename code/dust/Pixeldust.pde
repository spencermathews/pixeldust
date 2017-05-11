class Pixeldust {

  PImage img;
  PImage originalImg;
  Mover[] particles;  // array of particle positions

  float scaleImg = 2;  // set scale factor on image, i.e. how much to shrink

  int brightnessPerParticle;  // color contribution of each particle

  /*
   * Constructor
   *
   * param imgFile           String path to image to load
   * param particlesPerPixel int    number of particles for each black pixel
   */
  Pixeldust(String imgFile, int particlesPerPixel) {

    // TODO? ensure that full density -> pure black when reconstituted
    // TODO think about if this should be float or int, there are more particles when it's an int
    brightnessPerParticle = 255 / particlesPerPixel;

    img = loadImage(imgFile);                 // create PImage
    img.resize(floor(img.width/scaleImg), 0); // scale image
    originalImg = img.copy();                 // keep copy of scaled original image

    imgStats();

    initParticles();
    //initRandom();
  }

  /*
   * Gather and print image statistics
   *
   * param img
   */
  void imgStats() {

    img.loadPixels();  // we only read so no need to img.updatePixels();

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

    println(numParticles(), "particles from", img.pixels.length, "pixels");

    //int sumBrightness = 0;  // actually "darkness"
    //// Loop through pixels in 1D
    //for (int i = 0; i < img.pixels.length; i++) {
    //  color c = img.pixels[i];

    //  sumBrightness += 255 - brightness(c);
    //}
    //println("Would have been:", int(sumBrightness / brightnessPerParticle));
  }

  /*
   * Determine number of particles in entire image
   *
   * Assuming a pixels spawns a number of particles equal to its brightness.
   *
   * Note: Processing does not have unsigned int, and lacks real support for long
   * TODO make sure we don't overflow int range
   * //println(Integer.MIN_VALUE, Integer.MAX_VALUE);
   *
   * return number of particles
   */
  int numParticles() {

    img.loadPixels();  // we only read so no need to img.updatePixels();

    int sumParticles = 0;
    // Loop through pixels in 1D
    for (int i = 0; i < img.pixels.length; i++) {
      color c = img.pixels[i];
      sumParticles += pixelSplit(c);  // int cast redundant when incrementing an int var
    }

    return sumParticles;
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
   * Used to convert particle density to color value. 
   *
   * param  numParticles int
   * return              color
   */
  color pixelMerge(int numParticles) {
    float b = 255 - numParticles * brightnessPerParticle;
    return color(b);
  }

  /*
   * Create particles from image
   *
   * Spawns a number of particles from image. Uses pixelSplit.
   *
   * Was named particleSplit.
   */
  void initParticles() {

    int numParticles = numParticles();  // declare and initialize particle vector

    particles = new Mover[numParticles];

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
        // create appropriate number of particles at this pixel location
        while (n > 0) {
          particles[i] = new Mover(x, y);  // set location of this particle
          n--;
          i++;
        }
      }
    }
  }

  /*
   * Merge particles into image
   *
   * Uses pixelMerge.
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
      int loc = int(particles[i].position.x) + int(particles[i].position.y) * img.width;
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
   * Move particles using random walk
   *
   * Note: movement constrained to display window
   *
   * TODO parameterize by magnitude and/or randomize magnitude
   */
  void moveRandomWalk() {

    float moveX, moveY;
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
      //float range = 10;
      //moveX = random(-range, range);
      //moveY = random(-range, range);

      particles[i].position.x = constrain(particles[i].position.x + moveX, 0, img.width-1);
      particles[i].position.y = constrain(particles[i].position.y + moveY, 0, img.height-1);
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
    moveRandomWalk();
  }

  void display() {
    particleMerge();
    image(img, 0, 0);
  }

  /*
   * Initialize with random particles
   *
   * Create a number appropriate for the image.
   */
  void initRandom() {

    int numParticles = numParticles();  // declare and initialize particle vector

    particles = new Mover[numParticles];
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Mover(random(img.width), random(img.height));
    }
  }

  //void constrain
}