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

// status variables, are (0,0) during running person, (1,0) after person/audio finished while we're dropping, and (1,1) when we are ready to restart i.e intermision
int isComplete;  // whether or not current person is complete, set to 0 in begin() and 1 in run() after audio finishes
int isReady;     // whether or not we can trigger again, since we need to drop pixels after completion, set to 0 in begin and 

boolean useNet = false;  // set to false to disable network triggering
boolean debug = true;

int fallTime;  // hack to time falling, mark so we can check elapsed

void setup () {
  size(100, 100);
  surface.setResizable(true); // enable resizable display window
  //fullScreen();

  frameRate(30);  // TODO set timebased throttle, esp with better performing configurations

  if (sketchFullScreen() == true) {
    println("Running fullScreen");
  }

  noSmooth();  // may increase performance

  lastTime = 0;
  isComplete = 1;  // start off stopped
  isReady = 1;     // start off stopped
  fallTime = 0;

  if (useNet == true) {
    Client c;
    c = new Client(this, "192.168.1.1", 12345);
  }

  // only show cursor when in debug mode
  if (debug == false) {
    noCursor();
  }
}


void draw() {
  // Seemingly reduntant, but we want to enable a stopped state
  // however draw is still run once even if we stop loop

  if (isComplete == 0) {  // normal running
    run();
  } else if (isReady == 0) {  // person ended but still need to drop pixels etc.
    // HACK should likely be handled in sim, but timing and control is delicate
    Mover[] particles = sim.particles;  // hack, get reference to particles in most recent sim
    for (int i = 0; i < particles.length; i++) {
      particles[i].acceleration = new PVector(0, 0);
      particles[i].velocity = new PVector(random(-3, 3), .03*(sim.h - particles[i].position.y)*particles[i].mass);
      particles[i].update();
      particles[i].checkEdgesMixed(sim.w, sim.h);
      //particles[i].checkEdgesReflectiveSnap(sim.w, sim.h);
    }
    // mark when we enter this phase
    if (fallTime == 0) {
      fallTime = millis();
    }
    // move on once we have waited some time
    if (millis() - fallTime > 20000) {
      isReady = 1;
    }

    sim.currentImage.countParticles();
    sim.currentImage.displayPixelsMasked(0);
  } else {
    background(255);
  }
  //else if(sim != null) {  // now we're in intermission and are ready to reset
  // NOT WORKING!
  ////TODO move to sim class, so we can do some setup and then play with the next particle set
  ////better yet figure out how to work with one pixel set and change its size.

  //Mover[] particles = sim.particles;  // hack, get reference to particles in most recent sim
  //for (int i = 0; i < particles.length; i++) {
  //  PVector wind = new PVector(0.01, 0);
  //  PVector gravity = new PVector(0, 0.1*particles[i].mass);

  //  particles[i].applyForce(wind);
  //  particles[i].applyForce(gravity);

  //  particles[i].update();
  //  particles[i].checkEdgesMixed(sim.w, sim.h);
  //}
  //sim.currentImage.countParticles();
  //sim.currentImage.displayPixelsMasked(0);

  //
  // only output stats in debug mode
  // null check for before we first call begin() and initialize sim
  if (debug == true && sim != null) {
    debugMode();
  }
}


// interates a person/simulation object
void run() {
  // set isComplete to 1 after person is finished
  isComplete = sim.run();  // iterate simulation
}

// creates a new person/sim and set to run
void begin() {

  //String csvFileName = csvFileNames[int(random(csvFileNames.length))];
  String csvFileName = csvFileNames[0];
  float scaleImg = 2;
  int particlesPerPixel = 5;
  sim = new PixeldustSimulation(this, csvFileName, scaleImg, particlesPerPixel);

  surface.setSize(sim.w, sim.h);  // set display window to simulation size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  //surface.setLocation(0, 0);

  noTint();  // just in case
  sim.begin();
  isComplete = 0;
  isReady = 0;
  fallTime = 0;
}


/* Start simulation on left mouse click, force restart on right mouse click
 */
void mousePressed() {
  if (mouseButton == LEFT) {
    // begin a person if not already running
    if (isReady == 1) {
      println(" Starting (mouse)");
      begin();
    } else {
      println(" Ignoring (mouse)");
    }
  } else if (mouseButton == RIGHT) {
    println(" Restarting");
    // Stop playing audio so we can begin again - may not be necessary!
    // Effectively identical to isComplete==0, but aways guarantees stop
    // TODO make sure this is still needed, and maybe make a proper stop function for sim
    if (sim != null) {
      sim.audio.stop();  // hack, would be better to have sim.stop, but this is just for testing
    }
    begin();
  }
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
    if (isReady == 1) {
      println(" Starting (network)");
      begin();
    } else {
      println(" Ignoring (network)");
    }
  }
}

// call in draw to display on screen and in title bar
void debugMode() {
  int currentTime = millis();
  if (currentTime - lastTime > 10) {
    int elapsedTime = (currentTime - sim.startTime)/1000;
    int min = elapsedTime / 60;  // use int division to our advantage
    int sec = elapsedTime % 60;

    // display elapsed time and fps in title bar
    surface.setTitle(min + ":" + nf(sec, 2) + " / " + int(frameRate) + " fps");

    // draw elapsed time and fps in title bar, useful for fullScreen
    fill(0);
    rect(width-100, height-50, 98, 47);
    fill(255);
    text(min + ":" + nf(sec, 2) + " / " + int(frameRate) + " fps", width-88, height-22);

    lastTime = millis();
  }
}