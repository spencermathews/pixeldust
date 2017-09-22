/*
 * Pixeldust
 *
 * Spencer Mathews, began: 3/2017
 */

float SCALE_IMG = 4;

import processing.sound.*;
import processing.net.*;

String[] csvFileNames = {"Anthony-timing.csv", "Chavez-timing.csv", 
  "Mother-Jones-timing.csv", "Guevara-timing.csv", "Davis-timing.csv", 
  "Einstein-timing.csv", "Luxemburg-timing.csv", "Mandela-timing.csv", 
  "Kahlo-timing.csv", "Chi-Minh-timing.csv"};

int nameIndex = int(random(csvFileNames.length));  // index for stepping through name array

PixeldustSimulation sim;

Client c;  // network client, only used if useNet == true
String serverHost = "192.168.1.1";
int serverPort = 12345;

int lastTime;  // keeps track of timer for fps in title

// status variables, are (0,0) during running person, (1,0) after person/audio finished while we're dropping, and (1,1) when we are ready to restart i.e intermision
int isComplete;  // whether or not current person is complete, initialize to -1, then set to 0 in begin() and 1 in run() after audio finishes
int triggerState;  // trigger disabled (0), trigger active (1), triggered (2) 

boolean fullScreenMode = true;  // choose fullScreen or windowed mode
boolean useNet = true;  // set to false to disable network triggering
boolean debug = false;

/* Set full screen or not depending on value of fullScreen variable
 *
 * Done in settings() since this can't be done conditionally in setup()
 */
void settings () {
  if (fullScreenMode) {
    fullScreen(P2D);
  } else {
    size(500, 500, P2D);
  }
}

void setup () {
  if (!sketchFullScreen()) {
    // allows resizing window if running in windowed mode
    surface.setResizable(true); // enable resizable display window, probably best in setup?
  }

  noSmooth();  // may increase performance

  lastTime = 0;
  isComplete = -1;  // start off with special value so draw loop is no-op until we setup first person
  triggerState = 1; // start off active

  if (useNet == true) {
    println("Connecting to network trigger...");

    c = new Client(this, serverHost, serverPort);  // may try for a while
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
    begin(SCALE_IMG);
  } else if (isComplete == 0) {  // normal running
    // iterates simulationset and sets isComplete to 1 after person is finished
    isComplete = sim.run();
  } else if (isComplete == 1) {
    // person ended but still need to drop pixels etc., should probably be handled in sim

    float triggerThreshold = 0.5;  // amount of falling before we can retrigger, 1 = we can retrigger right away, closer to 0 means longer wait
    //float x1 = width/2 - sim.w/2;   // gets upper left position of sim bounding box
    //float y1 = height/2 - sim.h/2;  // gets upper left position of sim bounding box
    float baseline = height/2 + sim.h/2;  // y coordinate of the bottom of the sim bounding box, could be off by 1 or a few due to rounding

    // iterates through particles and make them fall
    for (int i = 0; i < sim.particles.size(); i++) {
      Particle particle = sim.particles.get(i);
      particle.acc = new PVector(0, 0);
      particle.vel = new PVector(random(-3, 3), .03 * (baseline - particle.pos.y) * particle.mass);
      particle.update();
      particle.updateRandom(random(20), random(40));  // adds a little bit of randomness to particles linger at bottom
      // remove particles that are out of bounds, is this a good idea? it diverges from original approach
      // TODO I think you need to use Iterator.remove() to do this properly! I think we may miss some if there are consecutive to remove
      //if (particle.isOutOfBounds(x1, y1, sim.w, sim.h)) {
      //  sim.particles.remove(i);  // consider if remove is the right thing to do here...!
      //}
    }

    // tests if we have fallen far enough, could maybe include in update loop? can shortcut eval here at the cost of a second loop
    boolean haveFallen = true;  // checks that all particles have fallen below a threshold
    for (int i = 0; i < sim.particles.size(); i++) {
      // indicates that fall is not complete if we spot any particles above a line
      if (sim.particles.get(i).pos.y < baseline - sim.h * triggerThreshold) {
        haveFallen = false;
      }
    }

    // allow retriggering if all particles have fallen past threshold
    if (haveFallen == true) {
      triggerState = 1;
    }

    sim.display();
  }

  if (debug == true && sim != null) {
    debugMode();
  }
}


// creates a new person/sim and set to run
void begin(float scaleImg) {
  ArrayList<Particle> existingParticles;
  if (sim != null) {
    // Gets particles for current simulation, if there is one
    existingParticles = sim.particles;
    sim = null;  // probably unnecessary since trigger moved to draw(), this is just to catch any bugs
  } else {
    // Sets existingParticles to null, since otherwise Processing complains
    // that 'The local variable "existingParticles" may not have been initialized'
    existingParticles = null;
  }

  String csvFileName;
  csvFileName = csvFileNames[nameIndex];
  nameIndex = (nameIndex + 1) % csvFileNames.length;

  try {
    // instantiate simulation
    if (existingParticles == null) {
      // If no particles already, constructs simulation which will create its own initial set of particles
      sim = new PixeldustSimulation(this, csvFileName, scaleImg);
    } else {
      // Passes existingParticles on to the new simulation
      sim = new PixeldustSimulation(this, csvFileName, scaleImg, existingParticles);
    }
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
      sim = null;  // Clears sim so existing particles aren't kept
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
        c = new Client(this, serverHost, serverPort);  // may try for a while
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

    if (!sketchFullScreen()) {
      // Displays elapsed time and fps in title bar
      surface.setTitle(min + ":" + nf(sec, 2) + " / " + int(frameRate) + " fps");
    } else {
      // Draws elapsed time and fps in a box, useful for fullScreen
      noStroke();
      fill(0);
      rect(width-100, height-50, 100, 46);
      fill(255);
      text(min + ":" + nf(sec, 2) + " / " + int(frameRate) + " fps", width-88, height-22);
    }

    lastTime = millis();
  }
}