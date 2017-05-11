/* Derived from Mover class from Shiffman's Nature of Code Example 1.9
 * Modified constructor to take position parameters.
 */

class Mover {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float topspeed;

  Mover(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    topspeed = 6;
  }

  // currently unused
  void update() {
    acceleration = PVector.random2D();
    acceleration.mult(random(2));

    velocity.add(acceleration);
    velocity.limit(topspeed);
    position.add(velocity);
  }

  // currently unused
  void display() {
    stroke(0);
    strokeWeight(2);
    fill(127);
    ellipse(position.x, position.y, 48, 48);
  }

  // currently unused
  void checkEdges() {

    if (position.x > width) {
      position.x = 0;
    } else if (position.x < 0) {
      position.x = width;
    }

    if (position.y > height) {
      position.y = 0;
    } else if (position.y < 0) {
      position.y = height;
    }
  }
}