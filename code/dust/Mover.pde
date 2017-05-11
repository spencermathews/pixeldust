/* Derived from Mover class from Shiffman's Nature of Code Example 1.9
 * Modified constructor to take position parameters.
 */

class Mover {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float topspeed;
  float mass;

  Mover(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    topspeed = 5;
    mass = 1;
  }

  /* As per Shiffman NOC Example 1.9
   * but included checkEdges here instead of externally
   */
  void updateRandom() {
    acceleration = PVector.random2D();
    acceleration.mult(random(2));

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

  /* 
   */
  void updateAttractors(Attractor[] attractors) {
    //acceleration.mult(0);
    for (int i = 0; i < attractors.length; i++) {
      PVector force = attractors[i].attract(this);
      //println(force);
      applyForce(force);
    }
    update();
    checkEdges();
  }

  /* As per Shiffman NOC Ch 2
   */
  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  /* As per Shiffman NOC Ch 2
   */
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
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