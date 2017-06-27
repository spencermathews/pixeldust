/*
 * Pixeldust
 *
 * Spencer Mathews, began: 3/2017
 */

float SCALE_IMG = 4;
int PARTICLES_PER_PIXEL = 8;

import processing.sound.*;
import processing.net.*;

String[] csvFileNames = {"Anthony-timing.csv", "Chavez-timing.csv", "Chi-Minh-timing.csv", 
  "Davis-timing.csv", "Einstein-timing.csv", "Guevara-timing.csv", "Kahlo-timing.csv", 
  "Luxemburg-timing.csv", "Mandela-timing.csv", "Mother-Jones-timing.csv"};

PixeldustSimulation sim;

int lastTime;  // keeps track of timer for fps in title

// status variables, are (0,0) during running person, (1,0) after person/audio finished while we're dropping, and (1,1) when we are ready to restart i.e intermision
int isComplete;  // whether or not current person is complete, set to 0 in begin() and 1 in run() after audio finishes
int isReady;     // whether or not we can trigger again, since we need to drop pixels after completion, set to 0 in begin and 

boolean useNet = false;  // set to false to disable network triggering
boolean debug = false;

int fallThreshold = 50;  // threshold pixels from bottom of display, all particles must be in this window to be

void setup () {
  //size(100, 100);
  //surface.setResizable(true); // enable resizable display window
  fullScreen();

  frameRate(30);  // TODO set timebased throttle, esp with better performing configurations

  if (sketchFullScreen() == true) {
    println("Running fullScreen");
  }

  noSmooth();  // may increase performance

  lastTime = 0;
  isComplete = 1;  // start off stopped
  isReady = 1;     // start off stopped

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
    // iterates through particles and make them fall
    for (int i = 0; i < particles.length; i++) {
      particles[i].acceleration = new PVector(0, 0);
      particles[i].velocity = new PVector(random(-3, 3), .03*(sim.h - particles[i].position.y)*particles[i].mass);  // good params were tricky
      particles[i].update();
      particles[i].checkEdgesMixed(sim.w, sim.h);
      //particles[i].checkEdgesReflectiveSnap(sim.w, sim.h);
    }
    sim.currentImage.countParticles();
    sim.currentImage.displayPixelsMasked(0);

    // tests if we have fallen far enough, could maybe include in update loop? can shortcut eval here at the cost of a second loop
    boolean haveFallen = true;  // checks that all particles have fallen below a threshold
    for (int i = 0; i < particles.length; i++) {
      // indicates that fall is not complete if we spot any particles above a line
      if (particles[i].position.y < sim.h-fallThreshold) {
        haveFallen = false;
      }
    }

    // move on if fall is complete
    if (haveFallen == true) {
      isReady = 1;
    }
  } else if (sim != null) {
    // now we're in intermission and are ready to reset
    // null check is since we must init sim first, so must wait until after starting first sim
    // TODO parameterize sim.run then we can just call it here with random

    // move particles randomly within the fall window
    Mover[] particles = sim.particles;  // hack, get reference to particles in most recent sim
    for (int i = 0; i < particles.length; i++) {
      // hack way to update, should modify to update using forces as in the falling
      particles[i].updateRandom(.2, 2);
      // hack way to push down
      if (particles[i].position.y < sim.h - fallThreshold) {
        // use same update as falling
        particles[i].acceleration = new PVector(0, 0);
        particles[i].velocity = new PVector(random(-3, 3), .03*(sim.h - particles[i].position.y)*particles[i].mass);  // good params were tricky
        particles[i].update();
        particles[i].checkEdgesMixed(sim.w, sim.h);
        //particles[i].checkEdgesReflectiveSnap(sim.w, sim.h);
      }
      particles[i].checkEdgesMixed(sim.w, sim.h);
    }
    sim.currentImage.countParticles();
    sim.currentImage.displayPixelsMasked(0);
  } else {
    // before simulation, and when neither Complete nor Ready, and no sim object
    background(255);
  }

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
void begin(float scaleImg, int particlesPerPixel) {

  String csvFileName = csvFileNames[int(random(csvFileNames.length))];
  //String csvFileName = csvFileNames[2];
  sim = new PixeldustSimulation(this, csvFileName, scaleImg, particlesPerPixel);

  //surface.setSize(sim.w, sim.h);  // set display window to simulation size

  // a forum post says frame.setLocation() must be set in draw, confirm? is surface different?
  //surface.setLocation(0, 0);

  noTint();  // just in case
  sim.begin();
  isComplete = 0;
  isReady = 0;
}


/* Start simulation on left mouse click, force restart on right mouse click
 */
void mousePressed() {
  if (mouseButton == LEFT) {
    // begin a person if not already running
    if (isReady == 1) {
      println(" Starting (mouse)");
      begin(SCALE_IMG, PARTICLES_PER_PIXEL);
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
    begin(SCALE_IMG, PARTICLES_PER_PIXEL);
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
      begin(SCALE_IMG, PARTICLES_PER_PIXEL);
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