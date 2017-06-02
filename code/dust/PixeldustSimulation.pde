/* PixeldustSimulation Class
 *
 * requires Sound library
 */
class PixeldustSimulation {

  String audioFile;
  SoundFile audio;

  String[] imageFiles;
  Pixeldust[] images;
  int width;
  int height;

  int[] times;

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
    // parse control file and initialize audioFile, imageFiles, and times
    parse(csvFile);

    // initialize audio
    initAudio(ref);

    // initializes width, height, and images[]
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
    println("Parsing", csvFile, "with", table.getRowCount(), "rows and", table.getColumnCount(), "columns");

    int numRows = table.getRowCount();

    // gets name of audio file
    audioFile = table.getString(0, 0);
    println(audioFile);

    // gets names of image files and their times
    imageFiles = new String[numRows-1];
    String[] timestamps = new String[numRows-1];
    for (int i = 1; i < numRows; i++) {
      imageFiles[i-1] = table.getString(i, 0);
      timestamps[i-1] = table.getString(i, 1);
    }

    // converts M:S to milliseconds
    times = new int[timestamps.length];
    for (int i = 0; i < timestamps.length; i++) {
      times[i] = convertTime(timestamps[i]);
    }

    // TODO validate data and that times are well ordered
    for (int i = 0; i < imageFiles.length; i++) {
      println(imageFiles[i], timestamps[i], times[i]);
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
    audio = new SoundFile(ref, audioFile);

    println("\nSFSampleRate= " + audio.sampleRate() + " Hz");
    println("SFSamples= " + audio.frames() + " samples");
    println("SFDuration= " + audio.duration() + " seconds");
  }


  /* Initializes width, height, and images[] fields
   *
   * Must be called after imagesFiles array is initialized in parse()
   */
  void initImages(float scaleImg, int particlesPerPixel) {
    this.width = 0;
    this.height = 0;

    // create and initialize images array
    images = new Pixeldust[imageFiles.length];
    for (int i = 0; i < imageFiles.length; i++) {
      println("\nCreating", imageFiles[i]);
      images[i] = new Pixeldust(imageFiles[i], scaleImg, particlesPerPixel);

      // set simulation dimensions to the max of all images
      if (images[i].width > this.width) {
        this.width = images[i].width;
      }
      if (images[i].height > this.height) {
        this.height = images[i].height;
      }
    }

    // verify that all images are same dimsension, may want to relax later
    // or decouple simulation size from images so smaller images can be inserted
    for (Pixeldust img : images) {
      if (img.width != this.width || img.height != this.height) {
        println("Error: images must have same dimensions");
        exit();
      }
    }

    println("\nSimulation with", images.length, "images at", this.width + "x" + this.height);
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
      particles[i] = new Mover(int(random(this.width)), int(random(this.height)));
    }

    println("\nSimulation uses", nfc(particles.length), "particles\n");
  }


  /* Begin audio and set up for run
   *
   * Begin playing audio and set first image, now we can run().
   */
  void begin() {
    audio.play();

    startTime = millis();  // marks the time the simulation starts

    setCurrent(0);
  }


  /* Pass control to a Pixeldust object
   *
   * Set currentIndex and pass particles to it.
   */
  void setCurrent(int i) {
    println("\nelapsed time:", elapsedTime(), "| actual interval ->", currentInterval + elapsedTime() - currentTime);
    currentIndex = i;
    currentImage = images[i];
    currentTime = times[i];
    // computes target time relative to time elapsed since start of sim
    // will typically be some 10s of ms less than expected time because of error in catching the time condition
    currentInterval = (currentTime - elapsedTime());
    println("set: currentIndex =", currentIndex, "| currentTime =", currentTime, "| currentInterval =", currentInterval);

    currentImage.initParticles(particles);  // passes this particle[] array to the current Pixeldust image
    currentImage.countParticles();          // updates that object's imgParticles[] array with the new particles
  }


  /* Main event loop to be called from draw()
   *
   * Should not be called until after 
   */
  void run() {
    // assumes currentIndex, currentImage, and currentTime are up to date

    //currentImage.updateForward(0);
    currentImage.updateForward(map(mouseX, 0, width, 1, -0.1));
    currentImage.display();

    // starts next image once we have reached desired convergence time, will typcally overshoot by 10s of ms
    if (elapsedTime() > currentTime && currentIndex < images.length-1) {
      setCurrent(currentIndex+1);  // set next to be current
    }
  }

  /* Returns elapsed time in milliseconds (elapsed time is time since begin() was called) 
   */
  int elapsedTime() {
    return millis() - startTime;
  }


  /* Extract reverse frames from Pixeldust
   *
   *
   */
  void reverseFrames() {
  }
}