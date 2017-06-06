/*
 * Resolve confusion over the shadowing of width and height variables in classes
 *
 * Conclusion: if your Object has width/height fields they shadow the global ones.
 * I'm still not sure how to access those 
 */

PApplet papplet = this;  // cool suggesting from a forum if you want to access PApplet from within your classes

void setup() {
  size(500, 500);
  noLoop();
}



void draw() {
  println("global", width, height);
  Test t = new Test();
  println("global", width, height);
  println("global this", this.width, this.height);
  
}