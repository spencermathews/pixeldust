/**
 * Send a byte to client to trigger sim
 *
 * Modified from:
 * Shared Drawing Canvas (Server) 
 * by Alexander R. Galloway.
 */

import processing.net.*;

Server s;
int serverPort = 12345;

void setup() 
{
  size(100, 100);
  background(0, 255, 0);
  //frameRate(5); // Slow it down a little
  s = new Server(this, serverPort); // Start a simple server on a port
}

void draw() 
{
  if (mousePressed == true) {
    s.write(1);
    background(255, 0, 0);
  } else {
    background(0, 255, 0);
  }
}