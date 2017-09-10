/*
 * Pixeldust
 *
 * Spencer Mathews, began: 3/2017
 */

float SCALE_IMG = 4;
int PARTICLES_PER_PIXEL = 8;

import processing.sound.*;
import processing.net.*;

String[] csvFileNames = {"Anthony-timing.csv", "Chavez-timing.csv", 
  "Mother-Jones-timing.csv", "Guevara-timing.csv", "Davis-timing.csv", 
  "Einstein-timing.csv", "Luxemburg-timing.csv", "Mandela-timing.csv", 
  "Kahlo-timing.csv", "Chi-Minh-timing.csv"};

int nameIndex = int(random(csvFileNames.length));  // index for stepping through name array

PixeldustSimulation sim;

Client c;  // network client, only used if useNet == true

int lastTime;  // keeps track of timer for fps in title

// status variables, are (0,0) during running person, (1,0) after person/audio finished while we're dropping, and (1,1) when we are ready to restart i.e intermision
int isComplete;  // whether or not current person is complete, initialize to -1, then set to 0 in begin() and 1 in run() after audio finishes
int triggerState;  // trigger disabled (0), trigger active (1), triggered (2) 

boolean fullScreenMode = false;  // choose fullScreen or windowed mode
boolean useNet = false;  // set to false to disable network triggering
boolean debug = false;


/* Set full screen or not depending on value of fullScreen variable
 *
 * Done in settings() since this can't be done conditionally in setup()
 */
void settings () {
  if (fullScreenMode) {
    fullScreen();
  } else {
    size(150, 150);
  }
}

void setup () {
  if (!sketchFullScreen()) {
    // allows resizing window if running in windowed mode
    surface.setResizable(true); // enable resizable display window, probably best in setup?
  }
  
  frameRate(30);  // TODO set timebased throttle, esp with better performing configurations
  noSmooth();  // may increase performance

  lastTime = 0;
  isComplete = -1;  // start off with special value so draw loop is no-op until we setup first person
  triggerState = 1; // start off active

  if (useNet == true) {
    println("Connecting to network trigger...");

    c = new Client(this, "192.168.1.1", 12345);  // may try for a while
    if (!c.active()) {
      // java.net.ConnectException is thrown, but caught by the net library, so test active() state
      println("Network failed to connect!");
      exit();  // exit program when setup() finishes
      return;  // skip the rest of this function
    } else {
      println("Network active!");
      // spawn thread to check network state and reconnect if needed
      thread("watchNetwork");
    }
  }

  // Hides cursor if running fullscreen
  if (sketchFullScreen()) {
    noCursor();
  }
}


void draw() {
  // Seemingly reduntant, but we want to enable a stopped state
  // however draw is still run once even if we stop loop

  if (triggerState == 2) {
    // if trigger flag has been set then (re)start a simulation
    println("[" + millis() + "] Triggered!");
    begin(SCALE_IMG, PARTICLES_PER_PIXEL);
  } else if (isComplete == 0) {  // normal running
    run();
  } else if (isComplete == 1) {
    // person ended but still need to drop pixels etc.
    // HACK should likely be handled in sim, but timing and control is delicate
    Mover[] particles = sim.particles;  // hack, get reference to particles in most recent sim

    float triggerThreshold = sim.h*0.5;  // amount particles should fall before be we can retrigger

    // iterates through particles and make them fall
    for (int i = 0; i < particles.length; i++) {
      particles[i].acceleration = new PVector(0, 0);
      particles[i].velocity = new PVector(random(-3, 3), .03*(sim.h - particles[i].position.y)*particles[i].mass);
      particles[i].update();
      particles[i].updateRandom(random(20), random(40));  // adds a little bit of randomness to particles linger at bottom
      particles[i].checkEdgesMixed(sim.w, sim.h);
      //particles[i].checkEdgesReflectiveSnap(sim.w, sim.h);
    }

    // tests if we have fallen far enough, could maybe include in update loop? can shortcut eval here at the cost of a second loop
    boolean haveFallen = true;  // checks that all particles have fallen below a threshold
    for (int i = 0; i < particles.length; i++) {
      // indicates that fall is not complete if we spot any particles above a line
      if (particles[i].position.y < triggerThreshold) {
        haveFallen = false;
      }
    }

    // allow retriggering if all particles have fallen past threshold
    if (haveFallen == true) {
      triggerState = 1;
    }

    sim.currentImage.countParticles();
    sim.currentImage.displayPixelsMasked(0);
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
void begin(float scaleImg, int particlesPerPixel) {
  sim = null;  // probably unnecessary since trigger moved to draw(), this is just to catch any bugs

  String csvFileName;
  csvFileName = csvFileNames[nameIndex];
  nameIndex = (nameIndex + 1) % csvFileNames.length;

  try {
    // instantiate simulation
    sim = new PixeldustSimulation(this, csvFileName, scaleImg, particlesPerPixel);
  }
  catch (NullPointerException e) {
    // if the csv file fails 
    exit();  // exit program when draw() loop finishes
    return;  // skip the rest of this function, since it will just throw more Exceptions
  } 

  if (!sketchFullScreen()) {
    // set display window to simulation size if running in windowed mode
    surface.setSize(sim.w, sim.h);
  }

  noTint();  // just in case
  sim.begin();
  isComplete = 0;
  triggerState = 0;
}


/* Start simulation on left mouse click, force restart on right mouse click
 */
void mousePressed() {
  print("[" + millis() + "] Mouse trigger received");
  if (mouseButton == LEFT) {
    // begin a person if not already running
    if (triggerState == 1) {
      println(": Triggering");
      triggerState = 2;  // set flag to restart simulation
    } else {
      println(": Ignoring");
    }
  } else if (mouseButton == RIGHT) {
    println(": Restarting");
    // Stop playing audio so we can begin again - may not be necessary!
    // Effectively identical to isComplete==0, but aways guarantees stop
    // TODO make sure this is still needed, and maybe make a proper stop function for sim
    if (sim != null) {
      sim.audio.stop();  // hack, would be better to have sim.stop, but this is just for testing
    }
    triggerState = 2;  // set flag to restart simulation
  }
}

// Client param to callback function means c need not be global
void clientEvent(Client c) {
  // read byte from network trigger and begin person if ready for it
  int input = c.read();
  c.clear();  // clear buffer so bytes don't accumulate
  print("[" + millis() + "] Network trigger received");

  // if we received a 1 from the server (i.e. triggered prox sensor)
  if (input == 1) {
    // begin a person if not already running
    if (triggerState == 1) {
      println(": Triggering");
      triggerState = 2;
    } else {
      println(": Ignoring");
    }
  }
}


// reconnects to network if disconnected
// should be run as a watchdog thread
void watchNetwork() {
  while (true) {
    // repeats loop forever
    if (!c.active()) {
      // if connection lost then keeps trying to reconnect to server until successful
      println("Server connection lost!\nReconnecting...");   
      do {  
        c = new Client(this, "192.168.1.1", 12345);  // may try for a while
        delay(1000);  // wait before trying to reconnect again
      } while (!c.active());
      println("Network reconnected!");
    }
    delay(5000);  // checks connectivity every 5 seconds
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