import processing.sound.*;
import processing.net.*;


/*
 * Pixeldust
 *
 * Spencer Mathews, began: 3/2017
 */

String[] csvFileNames = {"Mandela-timing.csv", "Davis-timing.csv", "Einstein-timing.csv", 
  "Chavez-timing.csv", "Guevara-timing.csv", "Kahlo-timing.csv", 
  "Mother-Jones-timing.csv", "Luxemburg-timing.csv", "Anthony-timing.csv"};
PixeldustSimulation sim;
int lastTime;  // keeps track of timer for fps in title
int isComplete;

boolean useNet = true;  // set to false to disable network triggering


void setup () {
  size(100, 100);
  surface.setResizable(true); // enable resizable display window

  noSmooth();  // may increase performance

  lastTime = 0;
  isComplete = 1;

  if (useNet == true) {
    Client c;
    c = new Client(this, "192.168.1.1", 12345);
  }
}

void draw() {
  // Seemingly reduntant, but we want to enable a stopped state
  // however draw is still run once even if we stop loop
  if (isComplete == 0) {
    run();
  }
}


// interates a person/simulation object
void run() {
  // set isComplete to 1 after person is finished
  isComplete = sim.run();  // iterate simulation

  int currentTime = millis();
  if (currentTime - lastTime > 100) {
    int elapsedTime = (currentTime - sim.startTime)/1000;
    int min = elapsedTime / 60;  // use int division to our advantage
    int sec = elapsedTime % 60;

    surface.setTitle(min + ":" + nf(sec, 2) + " / " + int(frameRate) + " fps");

    lastTime = millis();
  }
}


void begin() {

  String csvFileName = csvFileNames[int(random(csvFileNames.length))];
  //String csvFileName = csvFileNames[2];
  float scaleImg = 2;
  int particlesPerPixel = 4;
  sim = new PixeldustSimulation(this, csvFileName, scaleImg, particlesPerPixel);

  surface.setSize(sim.width, sim.height);  // set display window to simulation size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  //surface.setLocation(0, 0);

  noTint();  // just in case
  sim.begin();
  isComplete = 0;
}


// start simulation on mousePressed
void mousePressed() {
  // Stop playing audio so we can begin again
  // Effectively identical to isComplete==0, but aways guarantees stop
  if (sim != null) {
    sim.audio.stop();  // hack, would be better to have sim.stop, but this is just for testing
  }
  begin();
}

// Client param to callback function means c need not be global
void clientEvent(Client c) {
  // read byte from network trigger and begin person if ready for it
  int input = c.read();
  c.clear();  // clear buffer so bytes don't accumulate
  print("\nTrigger received:");

  // if we received a 1 from the server (i.e. triggered prox sensor)
  if (input == 1) {
    // begin a person if not already running
    if (isComplete == 1) {
      println(" Starting");
      begin();
    } else {
      println(" Ignoring");
    }
  }
}