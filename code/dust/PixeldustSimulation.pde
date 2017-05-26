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

  int currentIndex;

  int numParticles;   // number of particles in simulation
  Mover[] particles;  // array of particle positions, note: might want to save numParticles as field

  int startTime;


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


  /* Parses controlling csv file and sets audioFiles, imageFiles, and times fields
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

    // converts M:S to seconds
    times = new int[timestamps.length];
    for (int i = 0; i < timestamps.length; i++) {
      times[i] = convertTime(timestamps[i]);
    }

    // TODO validate data and that times are well ordered
    for (int i = 0; i < imageFiles.length; i++) {
      println(imageFiles[i], timestamps[i], times[i]);
    }
  }

  // helper function to convert minutes:seconds to seconds
  int convertTime(String timestamps) {
    String[] time = split(timestamps, ':');
    if (time.length != 2) {
      println("Error: time format");
      exit();
    }
    int minutes = int(time[0]);
    int seconds = int(time[1]);
    return minutes * 60 + seconds;
  }


  /* Initializes audio field
   *
   * Must be called after audioFile initialized in parse()
   */
  void initAudio(PApplet ref) {
    audio = new SoundFile(ref, audioFile);

    println("\nSimulation with audio file with", audio.duration(), "duration");
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
    numParticles = maxParticles;  // assigns 

    particles = new Mover[numParticles];
    // creates particles at random locations
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Mover(int(random(this.width)), int(random(this.height)));
    }

    println("\nSimulation uses", nfc(numParticles), "particles");
  }


  /* Begin audio and set up for run
   *
   * Begin playing audio and set first image, now we can run().
   */
  void begin() {
    audio.play();
    startTime = millis();
    setCurrentImage(0);
  }


  /* Pass control to a Pixeldust object
   *
   * Set currentIndex and pass particles to it.
   */
  void setCurrentImage(int i) {
    currentIndex = i;
    Pixeldust currentImage = images[i];

    currentImage.initParticles(particles);  // pass this particle[] array to the current Pixeldust image
    currentImage.countParticles();          // update that object's imgParticles[] array with the new particles
  }


  /* Main event loop to be called from draw()
   */
  void run() {
    // get current image and time
    // later consider keeping refs to avoid repetition each frame
    Pixeldust currentImage = images[currentIndex];
    float nextTime = times[currentIndex];

    currentImage.updateForward(0);
    //currentImage.updateForward(map(mouseX, 0, width, 1, -0.1));
    currentImage.display();
  }



  /* Extract reverse frames from Pixeldust
   *
   *
   */
  void reverseFrames() {
  }
}