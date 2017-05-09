/* Draw a vector field defined by equations
 *
 * Spencer Mathews, 5/2017
 */

VectorField vf;

void setup() {
  size(512, 512);
  vf = new VectorField();
}

void draw() {
  background(0);
  translate(width/2, height/2);

  vf.drawVectors(32, 0.005);
}