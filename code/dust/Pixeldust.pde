// TODO maybe make Pixeldust a subclass of PImage?
class Pixeldust {

  PImage img;             // original image as loaded
  PImage imgPixels;       // reconstituted image for display, updated each iteration
  int[] imgParticles;     // maintain current number of particles which occupy each pixel coordinate

  PImage imgPixelsOrig;   // maintain the original image after scaling, for reference
  int[] imgParticlesOrig; // array like img but elements hold number of particles in corresponding pixel, for reference

  int width;   // width of scaled image (imgPixels)
  int height;  // height of scaled image (imgPixels)

  Mover[] particles;  // array of particle positions, note: might want to save numParticles as field

  float scaleImg;  // set scale factor on image, i.e. how much to shrink

  int brightnessPerParticle;  // color contribution of each particle

  int numParticles;  // number of particles in simulation

  int numPixelsOver = 0;   // tracks number of pixels with excess particles
  int numPixelsUnder = 0;  // tracks number of pixels with particle deficiencies


  /*
   * Constructor
   *
   * param imgFile           String path to image to load
   * param particlesPerPixel int    number of particles for each black pixel
   */
  Pixeldust(String imgFile, float scaleImg, int particlesPerPixel) {

    // TODO? ensure that full density -> pure black when reconstituted
    // TODO think about if this should be float or int, there are more particles when it's an int
    brightnessPerParticle = 255 / particlesPerPixel;

    this.scaleImg = scaleImg;

    img = loadImage(imgFile);                 // load image file
    imgPixels = img.copy();                   // copy image to rescale
    imgPixels.resize(floor(imgPixels.width/scaleImg), 0); // scale image
    imgPixelsOrig = imgPixels.copy();               // keep copy of scaled original image

    this.width = imgPixelsOrig.width;
    this.height = imgPixelsOrig.height;

    println("scaled", "x", scaleImg, "->", imgPixelsOrig.width + "x" + imgPixelsOrig.height);

    numParticles = numParticles();  // compute number of particles to work with

    println(nfc(numParticles), "particles from", nfc(imgPixelsOrig.pixels.length), "pixels");

    //imgStats();

    // Initializes particles[] and imgParticlesOrig[] arrays
    initParticles();

    // Initializes particles[] array
    initRandom(1);

    // Create imgParticles[]
    imgParticles = new int[imgPixelsOrig.pixels.length];  // create array for storing current particle count
    //arrayCopy(imgParticlesOrig, imgParticles);  // initialize as per original image
    countParticles();  // gives same result as arrayCopy here, but use for clarity and consistency
  }


  /*
   * Gather and print image statistics
   *
   * param img
   */
  void imgStats() {

    imgPixelsOrig.loadPixels();  // we only read so no need to updatePixels();

    // initialize vars to track max values
    float maxR = 0;
    float maxG = 0;
    float maxB = 0;
    float maxA = 0;
    float maxH = 0;
    float maxS = 0;
    float maxV = 0;

    // Loop through pixels in 1D
    for (int i = 0; i < imgPixelsOrig.pixels.length; i++) {
      color p = imgPixelsOrig.pixels[i];

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

    //int sumBrightness = 0;  // actually "darkness"
    //// Loop through pixels in 1D
    //for (int i = 0; i < imgPixelsOrig.pixels.length; i++) {
    //  color c = imgPixelsOrig.pixels[i];

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
   * Requires imgPixelsOrig field to be initialized.
   *
   * return number of particles
   */
  int numParticles() {

    imgPixelsOrig.loadPixels();  // we only read so no need to updatePixels();

    int sumParticles = 0;
    // Loop through pixels in 1D
    for (int i = 0; i < imgPixelsOrig.pixels.length; i++) {
      color c = imgPixelsOrig.pixels[i];
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


  /* Spawns a number of particles from image
   *
   * Creates and populates particle[], imgParticlesOrig[], and imgParticles[] arrays
   *
   * Uses pixelSplit().
   * Was named particleSplit().
   *
   * Requires fields imgPixelsOrig[] and numParticles to be initialized.
   */
  void initParticles() {

    particles = new Mover[numParticles];

    imgPixelsOrig.loadPixels();  // we only read so no need to updatePixels();
    imgParticlesOrig = new int[imgPixelsOrig.pixels.length];

    int i = 0;  // index into particles array
    // Loop through pixels in 2D
    // Loop through every pixel column
    for (int y = 0; y < imgPixelsOrig.height; y++) {
      // Loop through every pixel column
      for (int x = 0; x < imgPixelsOrig.width; x++) {
        // Use the formula to find the 1D location
        int loc = x + y * imgPixelsOrig.width;

        int n = pixelSplit(imgPixelsOrig.pixels[loc]);  // compute number of particles to spawn from this pixel
        imgParticlesOrig[loc] = n;                // store particles in each pixel in a separate array
        // create appropriate number of particles at this pixel location
        while (n > 0) {
          particles[i] = new Mover(x, y);  // set location of this particle
          n--;
          i++;
        }
      }
    }
  }


  /* Merge particles into image using pixelMerge()
   *
   * Requires imgParticles array to be current.
   */
  void particleMerge() {

    imgPixels.loadPixels();  // loads img pixels[] array so we can update it

    // convert pixel occupation to brightness inverted
    for (int i = 0; i < imgPixels.pixels.length; i++) {
      imgPixels.pixels[i] = pixelMerge(imgParticles[i]);
    }

    imgPixels.updatePixels();
  }


  /* Count particles occupying each pixel space and update imgParticles array
   */
  void countParticles() {
    // zeros array
    for (int i = 0; i < imgParticles.length; i++) {
      imgParticles[i] = 0;
    }

    for (int i = 0; i < particles.length; i++) {
      // finds the 1D location of particle on img grid and increment the particle count there
      int loc = int(particles[i].position.x) + int(particles[i].position.y) * imgPixels.width;
      imgParticles[loc]++;
    }
  }


  /* Dynamics moving toward image
   *
   * Naive implemenation only moves particles on pixels that are over-occupied.
   * An improvement recalculates overflow state after every move.
   * Consider adjusting move range depending on how overoccupied,
   * or maybe by comparing to adjacent pixels.
   */
  void updateForward(float p) {
    numPixelsOver = 0;  // counts number of overflowed pixels
    numPixelsUnder = 0; // counts number of underflowed pixels

    for (int i = 0; i < particles.length; i++) {
      // finds the 1D location of this particle on img grid
      int loc = int(particles[i].position.x) + int(particles[i].position.y) * imgPixels.width;

      float prob = random(1.0);
      // performs update step if this pixel has overflowed
      if (imgParticles[loc] > imgParticlesOrig[loc] || prob < p) {
        //particles[i].updateRandomWalkBasic();
        //particles[i].updateRandomWalkVonNeumann();
        //particles[i].updateRandomWalkMoore();
        particles[i].updateRandom(10);

        //particles[i].checkEdgesPeriodicSnap();
        //particles[i].checkEdgesPeriodic();
        //particles[i].checkEdgesReflectiveSnap();
        //particles[i].checkEdgesReflective();
        particles[i].checkEdgesMixed();

        numPixelsOver++;

        // cleverly updates imgPixels, since directly calling countParticles is wildy inefficient
        imgParticles[loc]--;  // decrement particle count of pixel at previous location
        loc = int(particles[i].position.x) + int(particles[i].position.y) * imgPixels.width;  // identify pixel where particle moved
        imgParticles[loc]++;  // increment particle count of pixel at new location
      } else if (imgParticles[loc] < imgParticlesOrig[loc]) {
        numPixelsUnder++;
      } // else would catch particles with correct occupation
    }

    // output how close we match original image
    if (frameCount % 10 == 0) {
      println(numPixelsOver + numPixelsUnder, "=", numPixelsOver, "+", numPixelsUnder);
    }

    // not needed as longs as as imgParticles is updated after every move
    //countParticles();  // updates imgParticles by counting particles in each pixel area
  }


  void update() {
    for (int i = 0; i < particles.length; i++) {
      //particles[i].updateRandomWalkBasic();
      //particles[i].updateRandomWalkVonNeumann();
      particles[i].updateRandomWalkMoore();
      //particles[i].updateRandom(2);
      //particles[i].updateMouse();

      //particles[i].checkEdgesPeriodicSnap();
      //particles[i].checkEdgesPeriodic();
      //particles[i].checkEdgesReflectiveSnap();
      //particles[i].checkEdgesReflective();
      particles[i].checkEdgesMixed();
    }

    // sort of unnecessary here since only updateForward() relies on values in imgParticles
    countParticles();  // updates imgParticles by counting particles in each pixel area
  }


  void display() {
    particleMerge();
    //img.loadPixels();
    //for (int i = 0; i < img.pixels.length; i++) {
    //  img.pixels[i] = color(255-imgParticles[i]*brightnessPerParticle);
    //}
    //img.updatePixels();
    image(imgPixels, 0, 0);
  }


  // TODO optimize! PShape? PGraphics?
  void displayParticles(int displayFrequency) {

    if (frameCount % displayFrequency == 0) {
      background(255);

      // draw using Mover.display
      for (int i = 0; i < particles.length; i++) {
        particles[i].display();
      }

      // draw using PShape - does not seem any faster!
      //PShape points;
      //points = createShape();
      //points.beginShape(POINTS);
      //points.stroke(0);
      //points.strokeWeight(1);
      //points.fill(0);
      //for (int i = 0; i < particles.length; i++) {
      //  points.vertex(particles[i].position.x, particles[i].position.y);
      //}
      //points.endShape();
      //shape(points);
    }
  }


  /*
   * Initializes particle array with random particles
   *
   * Creates a number appropriate for the image.
   *
   * Populates particles[].
   * Note: does not create imgParticlesOrig[] like initParticles() does.
   *
   * Requires fields imgPixelsOrig[] and numParticles to be initialized.
   *
   * param ySpread float number of pixels from "bottom" initially occupied by particles
   */
  void initRandom(float ySpread) {

    particles = new Mover[numParticles];

    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Mover(int(random(imgPixelsOrig.width)), int(random(imgPixelsOrig.height - ySpread, imgPixelsOrig.height)));  // creates a particle at random location
    }

  }
}