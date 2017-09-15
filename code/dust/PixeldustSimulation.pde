/* PixeldustSimulation Class
 *
 * requires Sound library
 */

float EXPONENT = 1.5;
float LIMIT_ACCELERATION = 10;  // 0-1, limits max acceleration which is calculated based on images progress
float LIMIT_ATTRACTION = 0.8;  // 0-1, attraction parameter at end of phase

class PixeldustSimulation {

  String audioFile;
  SoundFile audio;

  String[] imageFiles;
  Pixeldust[] images;
  int w;  // operating width of simulation, i.e. common width of scaled images
  int h;  // operating height of simulation, i.e. common height of scaled images

  int[] times;
  int[] transitions;  // 1 if we transition normally, 0 for no transition

  int currentIndex;        // controlling variable, set with setCurrent() since there is other work to be done
  Pixeldust currentImage;  // reference to images[curentIndex], for convenience
  int currentTime;         // reference to times[currentIndex], for convenience
  int currentInterval;     // total time we have to converge current image, calculated wrt simulation startTime

  Mover[] particles;  // array of particle positions, note: might want to save numParticles as field

  int startTime;  // set by begin() to track when audio starts


  /* Constructor
   *
   * It's rather silly that because of how SoundFile works we need to
   * pass the global PApplet reference. Maybe there is a more clever way?
   *
   * param ref     PApplet reference to global PApplet
   * param csvFile String name of csv file
   * should change to accept name of csv file!
   */
  PixeldustSimulation(PApplet ref, String csvFile, float scaleImg, int particlesPerPixel) {
    println("[" + millis() + "] Creating PixeldustSimulation");

    // parse control file and initialize audioFile, imageFiles, and times
    parse(csvFile);

    // initialize audio
    initAudio(ref);

    // initializes w, h, and images[]
    initImages(scaleImg, particlesPerPixel);  // args eventually passed through to Pixeldust constructors

    // initializes numParticles and particles[]
    initParticles();
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
    imageFiles = new String[numRows-1];
    transitions = new int[numRows-1];
    String[] timestamps = new String[numRows-1];
    for (int i = 1; i < numRows; i++) {
      imageFiles[i-1] = table.getString(i, 0);
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
    for (int i = 0; i < imageFiles.length; i++) {
      println("\t" + imageFiles[i] + ", " + timestamps[i] + ", " + times[i]);
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
  void initImages(float scaleImg, int particlesPerPixel) {
    w = 0;
    h = 0;

    // create and initialize images array
    images = new Pixeldust[imageFiles.length];
    for (int i = 0; i < imageFiles.length; i++) {
      images[i] = new Pixeldust(imageFiles[i], scaleImg, particlesPerPixel);

      // set simulation dimensions to the max of all images
      if (images[i].w > w) {
        w = images[i].w;
      }
      if (images[i].h > h) {
        h = images[i].h;
      }
    }

    // verify that all images are same dimsension, may want to relax later
    // or decouple simulation size from images so smaller images can be inserted
    for (Pixeldust img : images) {
      if (img.w != w || img.h != h) {
        println("Error: images must have same dimensions");
        exit();
      }
    }
    println("[" + millis() + "] Initialized", images.length, "images at", w + "x" + h);
  }


  /* Calculates numParticles and initializes particle[] with random particles
   *
   * Must be called after images array is initialized.
   *
   * Adapted from Pixeldust.initRandom() which is on its way to being deprecated.
   */
  void initParticles() {
    // determines the maximum number of particles over all Pixeldust images
    int maxParticles = 0;
    for (Pixeldust img : images) {
      maxParticles = max(img.numParticles, maxParticles);
    }

    particles = new Mover[maxParticles];
    // creates particles at random locations
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Mover(int(random(w)), int(random(h)), 10, 20);
    }

    println("[" + millis() + "] Initialized", nfc(particles.length), "particles");
  }


  /* Begin audio and set up for run
   *
   * Begin playing audio and set first image, now we can run().
   */
  void begin() {
    println("[" + millis() + "] Playing " + audioFile);
    audio.play();

    startTime = millis();  // marks the time the simulation starts

    setCurrent(0);
  }


  /* Pass control to a Pixeldust object
   *
   * Set currentIndex and pass particles to it.
   */
  void setCurrent(int i) {
    println("\telapsed time:", elapsedTime(), "| actual interval ->", currentInterval + elapsedTime() - currentTime);
    currentIndex = i;
    println("[" + millis() + "] Starting", imageFiles[i]);
    currentImage = images[i];
    currentTime = times[i];
    // computes target time relative to time elapsed since start of sim
    // will typically be some 10s of ms less than expected time because of error in catching the time condition
    currentInterval = (currentTime - elapsedTime());
    println("\tset: currentIndex =", currentIndex, "| currentTime =", currentTime, "| currentInterval =", currentInterval);

    currentImage.initParticles(particles);  // passes this particle[] array to the current Pixeldust image
    currentImage.countParticles();          // updates that object's imgParticles[] array with the new particles
  }


  /* Main event loop to be called from draw()
   *
   * Should not be called until after this.begin() has been called once
   *
   * returns 1 if simulation is complete, otherwise return 0
   */
  int run() {
    // assumes currentIndex, currentImage, and currentTime are up to date

    float pct;


    if (transitions[currentIndex] == 1) {
      // calculates progress of current image from 0 (start) to 1 (complete)
      pct = 1 - float(currentTime - elapsedTime()) / currentInterval;
      pct = constrain(pct, 0, 1);  // ensures pct stays in range 0-1 or else strange things happen
    } else {
      pct = 1;
    }

    // calculates some function on the segment progress
    float p = pow(pct, EXPONENT);  // exponent ==1 is linear, >1 stays low then rises sharply, <1 starts fast then levels off, is range of pow is 0-1 then range is 0-1

    float maxAcceleration = map(p, 0, 1, 0.1, LIMIT_ACCELERATION);
    float maxVelocity = maxAcceleration*10;

    // iterate current image
    currentImage.updateForward(constrain(p, 0, LIMIT_ATTRACTION), maxAcceleration, maxVelocity);

    // display current image
    //currentImage.displayPixels();
    currentImage.displayPixelsMasked(constrain(pct, 0, .5));  // set param to 0 for no masking, 1 for full masking

    if (debug) {
      // displays progress indicator for this segment
      stroke(1);
      fill(255, 0, 0);
      rect(0, height-4, map(pct, 0, 1, 0, width), 3);
    }

    // starts next image once we have reached desired convergence time, will typcally overshoot by 10s of ms
    if (elapsedTime() > currentTime) {
      // advance image if there are still more
      if (currentIndex < images.length-1) {
        setCurrent(currentIndex+1);  // set next to be current
      } else if (currentIndex == images.length-1) {
        // tests if we're actually done since audio may continue past timestamp of final image
        if (elapsedTime() > audio.duration()*1000) {
          audio.stop();
          println("complete @", elapsedTime(), "/", audio.duration()*1000);
          //background(255, 0, 0);
          return 1;  // all other conditions fall through to return 0
        } else {
          println( "wrapping up @", elapsedTime());
          //tint(255, 255, 0, 64);
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
}