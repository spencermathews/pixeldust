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
    fullScreen(FX2D);
  } else {
    size(500, 500, FX2D);
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
    // person ended but still need to drop pixels etc.
    triggerState = sim.fall(triggerState);
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
    println("[" + millis() + "] Recycling", nfc(existingParticles.size()), "particles!");
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

    String debugText = min + ":" + nf(sec, 2) + " | " + int(frameRate) + " fps" + " | " + nfc(sim.particles.size()) + " particles";
    if (!sketchFullScreen()) {
      // Displays elapsed time and fps in title bar
      surface.setTitle(debugText);
    } else {
      // Draws elapsed time and fps in a box, useful for fullScreen
      noStroke();
      fill(0);
      // determines width and height of the text
      int debugWidth = int(textWidth(debugText));
      int debugHeight = int(textAscent() + textDescent());  // note each font is adjusted by a different scalar
      int buffer = 10;  // number of pixels to buffer around text in the box
      int vOffset = 3;
      // calculates upper left corner and width and height of box considering the dimensions of text
      int a = (width - 1) - debugWidth - (2 * buffer);
      int b = (height - 1) - debugHeight - (2 * buffer) - vOffset;
      int c = debugWidth + (2 * buffer);
      int d = debugHeight + (2  * buffer);
      rect(a, b, c, d);
      fill(255);
      textAlign(CENTER, CENTER);  // note vertical centering is strangely off by a little
      text(debugText, a, b, c, d);  // specifying width and height of bounding box
    }

    lastTime = millis();
  }
}