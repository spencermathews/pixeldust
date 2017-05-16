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
    topspeed = 5;
  }

  /* Move particles using random walk
   *
   * Note: movement constrained to display window
   *
   * TODO parameterize by magnitude and/or randomize magnitude
   */
  void updateRandomWalk() {

    float moveX, moveY;

    if (random(-1, 1) < 0) {
      moveX = -1;
    } else {
      moveX = 1;
    }
    if (random(-1, 1) < 0) {
      moveY = -1;
    } else {
      moveY = 1;
    }

    position.x += moveX;
    position.y += moveY;

    checkEdges();
  }

  /*
   *
   * Modified from Shiffman NOC Example 1.9
   * but included checkEdges here instead of externally
   */
  void updateRandom(float high) {
    acceleration = PVector.random2D();
    acceleration.mult(random(high));

    velocity.add(acceleration);
    velocity.limit(topspeed);
    position.add(velocity);

    checkEdges();
  }

  /* As per Shiffman NOC Example 1.11
   * but included checkEdges here instead of externally
   */
  void updateMouse() {

    // Compute a vector that points from position to mouse
    PVector mouse = new PVector(mouseX, mouseY);
    acceleration = PVector.sub(mouse, position);
    // Set magnitude of acceleration
    //acceleration.setMag(0.2);
    acceleration.normalize();
    acceleration.mult(0.2);

    // Velocity changes according to acceleration
    velocity.add(acceleration);
    // Limit the velocity by topspeed
    velocity.limit(topspeed);
    // position changes by velocity
    position.add(velocity);

    checkEdges();
  }

  // currently unused
  void display() {
    stroke(0);
    strokeWeight(2);
    fill(127);
    ellipse(position.x, position.y, 48, 48);
  }

  /* As per Shiffman NOC Example 1.9, but added -1 to width/height
   * Could also choose to constrain instead of wrapping.
   * TODO pull request this detail to upstream
   */
  void checkEdges() {

    if (position.x > width-1) {
      position.x = 0;
    } else if (position.x < 0) {
      position.x = width-1;
    }

    if (position.y > height-1) {
      position.y = 0;
    } else if (position.y < 0) {
      position.y = height-1;
    }
  }
}