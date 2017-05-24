/* PixeldustSimulation
 *
 * requires Sound library
 */

class PixeldustSimulation {

  String audioFile;
  SoundFile audio;

  String[] imageFiles;
  float[] times;
  Pixeldust[] images;

  int width;
  int height;

  int nextTime = 0;

  /* Constructor
   *
   * It's rather silly that because of how SoundFile works we need to
   * pass the global PApplet reference. Maybe there is a more clever way?
   *
   * param ref          PApplet reference to global PApplet
   * param soundFileName String name of audio file
   * should change to accept name of csv file!
   */
  PixeldustSimulation(PApplet ref, String csvFile) {
    // parse control file and initialize audioFile, imageFiles, and times
    parse(csvFile);

    // initialize audio
    audio = new SoundFile(ref, audioFile);

    width = 0;
    height = 0;
    // create and initialize images array
    images = new Pixeldust[imageFiles.length];
    for (int i = 0; i < imageFiles.length; i++) {
      println("\nCreating", imageFiles[i]);
      images[i] = new Pixeldust(imageFiles[i], 4, 2);

      // TODO actually make sure that all images are same dimensions
      // or decouple simulation size from images so smaller images can be inserted
      if (images[i].width > width) {
        width = images[i].width;
      }
      if (images[i].height > height) {
        height = images[i].height;
      }
    }

    bootstrap();
  }


  /* Parses controlling csv file and sets audioFiles, imageFiles, and times fields
   *
   * Assume first row is audio file and remaining rows are image/time pairs.
   *
   * Ref: Handbook Ch 32 (Data)
   */
  void parse(String csvFile) {

    Table table = loadTable(csvFile);
    println(csvFile, "has", table.getRowCount(), "rows and", table.getColumnCount(), "columns");

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
    times = new float[timestamps.length];
    for (int i = 0; i < timestamps.length; i++) {
      times[i] = convertTime(timestamps[i]);
    }

    // TODO validate data and that times are well ordered

    for (int i = 0; i < imageFiles.length; i++) {
      println(imageFiles[i], timestamps[i], times[i]);
    }
  }


  float convertTime(String timestamps) {
    String[] time = split(timestamps, ':');
    if (time.length != 2) {
      println("Error: time format");
      exit();
    }
    int minutes = int(time[0]);
    int seconds = int(time[1]);
    return minutes * 60 + seconds;
  }


  void bootstrap() {
    audio.play();
    // create particles or particleSystem
    // start things going
  }


  void update() {

    for (int i = 0; i < times.length; i++) {

      //if (millis() > nextTime) {
      //  println(brightness(g.backgroundColor));
      //  nextTime = times[i];
      //}
    }
  }

  void display() {
  }


  /* Extract reverse frames from Pixeldust
   *
   *
   */
  void reverseFrames() {
  }
}