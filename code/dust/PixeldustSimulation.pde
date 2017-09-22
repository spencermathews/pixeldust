/* PixeldustSimulation Class
 *
 * requires Sound library
 */

//float EXPONENT = 1.5;
//float LIMIT_ACCELERATION = 10;  // 0-1, limits max acceleration which is calculated based on images progress
//float LIMIT_ATTRACTION = 0.8;  // 0-1, attraction parameter at end of phase

class PixeldustSimulation {

  String audioFile;
  SoundFile audio;

  int w;  // operating width of simulation, i.e. max width of all scaled images
  int h;  // operating height of simulation, i.e. max height of all scaled images

  int[] times;
  int[] transitions;  // 1 if we transition normally, 0 for no transition

  int currentTime;      // reference to times[imgIndex], for convenience
  int currentInterval;  // total time we have to converge current image, calculated wrt simulation startTime

  ArrayList<Particle> particles = new ArrayList<Particle>();

  int startTime;  // set by begin() to track when audio starts

  PImage[] imgs = new PImage[0];
  String[] imgNames;  // was imageFiles
  int imgIndex = -1;  // currentIndex was folded into here

  float brightnessThreshold = 254;  // do no create particles from pixels lighter than this


  /* Constructor
   *
   * It's rather silly that because of how SoundFile works we need to
   * pass the global PApplet reference. Maybe there is a more clever way?
   *
   * param ref     PApplet reference to global PApplet
   * param csvFile String name of csv file
   * should change to accept name of csv file!
   */
  PixeldustSimulation(PApplet ref, String csvFile, float scaleImg) {
    println("[" + millis() + "] Creating PixeldustSimulation");

    // parse control file and initialize audioFile, imageFiles, and times
    parse(csvFile);

    // initialize audio
    initAudio(ref);

    // initializes w, h, and imgs[]
    initImages(scaleImg);
  }

  PixeldustSimulation(PApplet ref, String csvFile, float scaleImg, ArrayList<Particle> particles) {
    this(ref, csvFile, scaleImg);

    this.particles = particles;  // initializes with particles that were passed in
  }


  /* Parses controlling csv file and sets audioFile, imageFiles, and times fields
   *
   * Assume first row is audio file and remaining rows are image/time pairs.
   *
   * Ref: Handbook Ch 32 (Data)
   */
  void parse(String csvFile) {

    Table table = loadTable(csvFile);
    println("[" + millis() + "] Parsing", csvFile, "with", table.getRowCount(), "rows and", table.getColumnCount(), "columns");

    int numRows = table.getRowCount();

    // gets name of audio file
    audioFile = table.getString(0, 0);
    println("\t" + audioFile);

    // gets names of image files and their times
    imgNames = new String[numRows-1];
    transitions = new int[numRows-1];
    String[] timestamps = new String[numRows-1];
    for (int i = 1; i < numRows; i++) {
      imgNames[i-1] = table.getString(i, 0);
      timestamps[i-1] = table.getString(i, 1);
      transitions[i-1] = table.getInt(i, 2);
    }

    // converts M:S to milliseconds
    times = new int[timestamps.length];
    for (int i = 0; i < timestamps.length; i++) {
      times[i] = convertTime(timestamps[i]);
    }

    times = new int[timestamps.length];
    for (int i = 0; i < timestamps.length; i++) {
      times[i] = convertTime(timestamps[i]);
    }  

    // TODO validate data and that times are well ordered
    for (int i = 0; i < imgNames.length; i++) {
      println("\t" + imgNames[i] + ", " + timestamps[i] + ", " + times[i]);
    }
  }

  // helper function to convert minutes:seconds to milliseconds
  int convertTime(String timestamps) {
    String[] time = split(timestamps, ':');
    if (time.length != 2) {
      println("Error: time format");
      exit();
    }
    int minutes = int(time[0]);
    int seconds = int(time[1]);
    return (minutes * 60 + seconds)*1000;
  }


  /* Initializes audio field
   *
   * Must be called after audioFile initialized in parse()
   */
  void initAudio(PApplet ref) {
    println("[" + millis() + "] Initializing " + audioFile);
    audio = new SoundFile(ref, audioFile);

    println("\tSFSampleRate= " + audio.sampleRate() + " Hz");
    println("\tSFSamples= " + audio.frames() + " samples");
    println("\tSFDuration= " + audio.duration() + " seconds");
  }


  /* Initializes w, h, and images[] fields
   *
   * Must be called after imagesFiles array is initialized in parse()
   */
  void initImages(float scaleImg) {
    w = 0;
    h = 0;

    for (int i = 0; i < imgNames.length; i++) {
      println("[" + millis() + "] Loading", imgNames[i]);
      PImage newImg = loadImage(imgNames[i]);
      newImg.resize(floor(newImg.width/scaleImg), 0);
      imgs = (PImage[])append(imgs, newImg);

      // set simulation dimensions to the max of all images
      if (imgs[i].width > w) {
        w = imgs[i].width;
      }
      if (imgs[i].height > h) {
        h = imgs[i].height;
      }
    }

    for (PImage img : imgs) {
      if (img.width != w || img.height != h) {
        println("Warning: Images have different dimensions");
      }
    }

    println("[" + millis() + "] Initialized", imgs.length, "images at", w + "x" + h);
  }


  /* Begin audio and set up for run
   *
   * Begin playing audio and set first image, now we can run().
   */
  void begin() {
    println("[" + millis() + "] Playing " + audioFile);
    audio.play();

    startTime = millis();  // marks the time the simulation starts

    nextImage();  // imgIndex is initialized to -1 so we start off correctly
  }


  /* Main event loop to be called from draw()
   *
   * Should not be called until after this.begin() has been called once
   *
   * returns 1 if simulation is complete, otherwise return 0
   */
  int run() {
    float pct;

    if (transitions[imgIndex] == 1) {
      // calculates progress of current image from 0 (start) to 1 (complete)
      pct = 1 - float(currentTime - elapsedTime()) / currentInterval;
      pct = constrain(pct, 0, 1);  // ensures pct stays in range 0-1 or else strange things happen
    } else {
      pct = 1;
    }

    //// calculates some function on the segment progress
    //float p = pow(pct, EXPONENT);  // exponent ==1 is linear, >1 stays low then rises sharply, <1 starts fast then levels off, is range of pow is 0-1 then range is 0-1

    //float maxAcceleration = map(p, 0, 1, 0.1, LIMIT_ACCELERATION);
    //float maxVelocity = maxAcceleration*10;

    g.beginDraw();
    g.background(255);
    for (int i = particles.size()-1; i > -1; i--) {
      particles.get(i).move();
      particles.get(i).draw(g);

      if (particles.get(i).isKilled) {
        float x1 = width/2 - this.w/2;  // gets upper left position of sim bounding box
        float y1 = height/2 - this.h/2;
        if (particles.get(i).isOutOfBounds(x1, y1, this.w, this.h)) {
          particles.remove(i);
        }
      }
    }
    g.endDraw();
    displayLetterbox();

    if (debug) {
      // displays progress indicator for this segment
      noStroke();
      fill(255, 0, 0);
      rect(0, height-4, map(pct, 0, 1, 0, width), 4);
    }

    // starts next image once we have reached desired convergence time, will typcally overshoot by 10s of ms
    if (elapsedTime() > currentTime) {
      // advance image if there are still more
      if (imgIndex < imgs.length-1) {
        nextImage();
      } else if (imgIndex == imgs.length-1) {
        // tests if we're actually done since audio may continue past timestamp of final image
        if (elapsedTime() > audio.duration()*1000) {
          audio.stop();
          println("complete @", elapsedTime(), "/", audio.duration()*1000);
          return 1;  // all other conditions fall through to return 0
        } else {
          println( "wrapping up @", elapsedTime());
        }
      }
    }
    return 0;  // indicates that we're still running
  }

  /* Returns elapsed time in milliseconds (elapsed time is time since begin() was called) 
   */
  int elapsedTime() {
    return millis() - startTime;
  }


  /**
   Dynamically adds/removes particles to make up the next image.
   *
   * Sets currentTime and currentInterval.
   */
  void nextImage() {

    // Moved here from setCurrent(), would be nice to eventually find a way to print this for last image, and maybe suppress for first
    println("\telapsed time:", elapsedTime(), "| actual interval ->", currentInterval + elapsedTime() - currentTime);

    // Switch index to next image. Note: logic in run() bounds tests this aleady but doesn't hurt to leave in.
    imgIndex++;
    if (imgIndex > imgs.length-1) {
      imgIndex = 0;
    }
    imgs[imgIndex].loadPixels();

    // Moved here from setCurrent()
    println("[" + millis() + "] Starting", imgNames[imgIndex]);
    currentTime = times[imgIndex];
    // computes target time relative to time elapsed since start of sim
    // will typically be some 10s of ms less than expected time because of error in catching the time condition
    currentInterval = (currentTime - elapsedTime());
    println("\tset: imgIndex =", imgIndex, "| currentTime =", currentTime, "| currentInterval =", currentInterval);

    // Create an array of indexes from particle array.
    ArrayList<Integer> particleIndexes = new ArrayList<Integer>();
    for (int i = 0; i < particles.size(); i++) {
      particleIndexes.add(i);
    }

    // Clears particleIndexes for an additive transition. Existing particles and targets remain.
    if (transitions[imgIndex] == 0) {
      // Clears particleIndexes so no particles will be reassigned. New particles will be created for all threshold pixels.
      particleIndexes.clear();
    }

    // Go through each pixel of the image.
    int pixelIndex = 0;
    for (int y = 0; y < imgs[imgIndex].height; y++) {
      for (int x = 0; x < imgs[imgIndex].width; x++) {
        // Get the pixel's color.
        color pixel = imgs[imgIndex].pixels[pixelIndex];

        pixelIndex += 1;

        // Do not assign a particle to this pixel under some conditions
        if (random(1.0) > loadPercentage*resSlider || brightness(pixel) > brightnessThreshold) {
          continue;
        }

        // Assigns particles to new pixels, creating new ones if needed 
        Particle newParticle;
        if (imgIndex == 0 && particleIndexes.isEmpty()) {
          // Initializes particles for the first image on the bottom edge if starting from scratch
          // If particles were passed in this block is skipped and we recycle them as usual, since aparticleIndexes will not be empty 
          float x1 = width/2 - this.w/2;  // gets upper left position of sim bounding box
          float y1 = height/2 - this.h/2;
          newParticle = new Particle(random(x1, x1 + this.w), y1 + this.h - 1);
          particles.add(newParticle);
        } else if (particleIndexes.size() > 0) {
          // Re-use existing particle.
          // JS Array splice can handle non-int params it seems, but ArrayList.remove fails, also was originally length-1
          int index = particleIndexes.remove(int(random(particleIndexes.size())));
          newParticle = particles.get(index);
        } else {
          // Create a new particle since all existing particles have already been used
          // Place new particle at the same location as a randomly selected existing particle
          Particle randomParticle = particles.get(int(random(particles.size())));
          newParticle = new Particle(randomParticle.pos.x, randomParticle.pos.y);
          particles.add(newParticle);
        }

        newParticle.target.x = x+width/2-imgs[imgIndex].width/2;
        newParticle.target.y = y+height/2-imgs[imgIndex].height/2;
        newParticle.currentColor = pixel;
        newParticle.currentSize = particleSizeSlider;
      }
    }

    // Kill off any left over particles that aren't assigned to anything.
    if (particleIndexes.size() > 0) {
      for (int i = 0; i < particleIndexes.size(); i++) {
        particles.get(particleIndexes.get(i)).kill();
      }
    }

    println("\tUsing", nfc(particles.size()), "particles w/", particleIndexes.size(), "killed");
  }


  // simply display particles, does not update or do bounds checking
  void display() {    
    background(255);
    for (int i = particles.size()-1; i > -1; i--) {
      particles.get(i).draw(g);
    }
    displayLetterbox();
  }


  void displayLetterbox() {
    float y1 = height/2 - this.h/2;  // gets top of sim bounding box
    noStroke();
    fill(0);
    rect(0, 0, width, y1);  // could be a little sloppy and off by 1 or so
    rect(0, y1 + this.h, width, y1);
  }
}