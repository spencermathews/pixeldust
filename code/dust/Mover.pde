/* Derived from Mover class from Shiffman's Nature of Code Example 1.9
 * Modified constructor to take position parameters.
 */

class Mover {

  PVector position;
  PVector velocity;
  PVector acceleration;

  float topspeed;
  float maxAccel;

  float mass;

  /* Constructs Mover with given position
   */
  Mover(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    topspeed = 6;
    maxAccel = 2;
    mass = random(1, 4);
  }

  /* Constructs Mover with given position and topspeed
   */
  Mover(float x, float y, float maxAcceleration, float maxSpeed) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    topspeed = maxSpeed;  // Shiffman hard coded this to 6
    maxAccel = maxAcceleration;  // Shiffman hard coded this to 2
    mass =  mass = random(1, 4);  // TODO add as param
  }

  /* Move particles using random walk, basic
   *
   * It is not possible to stay put.
   *
   * Modified from Shiffman NOC Introduction
   *
   * TODO parameterize by magnitude and/or randomize magnitude
   */
  void updateRandomWalkBasic() {
    // randomly move left, right, up, or down, no option to stay still
    int choice = int(random(4));
    velocity = new PVector(0, 0);
    if (choice == 0) {
      velocity.x++;
    } else if (choice == 1) {
      velocity.x--;
    } else if (choice == 2) {
      velocity.y++;
    } else {
      velocity.y--;
    }
    position.add(velocity);
  }

  /* Move particles using random walk with von Neumann neighborhood
   *
   * Possibility of no move.
   *
   * Note: movement constrained to display window
   *
   * Modified from Shiffman NOC Introduction
   */
  void updateRandomWalkVonNeumann() {
    // randomly move to any of 8 surrounding pixels or stay still - int steps
    velocity = new PVector(int(random(3))-1, int(random(3))-1);
    position.add(velocity);
  }

  /* Moves particles using random walk with Moore neighborhood
   *
   * Possibility of no move.
   *
   * Modified from Shiffman NOC Introduction
   */
  void updateRandomWalkMoore() {
    // randomly move to any of 8 surrounding pixels or stay still - float steps
    velocity = new PVector(random(-1, 1), random(-1, 1));
    position.add(velocity);
  }


  /* Moves particles by applying a random vector
   *
   * Magnitude is random up to given max acceleration.
   * Velocity is limited by the Mover's topspeed field.
   *
   * Modified from Shiffman NOC Example 1.9
   * but included checkEdges here instead of externally
   */
  void updateRandom() {
    acceleration = PVector.random2D();
    acceleration.mult(random(maxAccel));  // use Mover's maxAccel

    velocity.add(acceleration);
    velocity.limit(topspeed);  // uses Mover's topspeed field
    position.add(velocity);
  }


  /* Moves particles by applying a random vector, specify random limit, and max speed (also updates topspeed field)
   *
   * Magnitude is random up to given max acceleration.
   * Velocity is constrained by the given max speed.
   *
   * param maxAcceleration float maximum magnitude of acceleration vector
   * param maxSpeed        float top speed that can result
   */
  void updateRandom(float maxAcceleration, float maxSpeed) {
    acceleration = PVector.random2D();
    acceleration.mult(random(maxAcceleration));  // use param

    velocity.add(acceleration);
    velocity.limit(maxSpeed);  // use param
    position.add(velocity);
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
  }

  void display() {
    stroke(0);
    strokeWeight(1);
    fill(0);
    point(position.x, position.y);
  }

  /* Impose periodic boundary conditions but snap to edge
   *
   * As per Shiffman NOC Example 1.9
   */
  void checkEdgesPeriodicSnap(int w, int h) {

    if (position.x >= w) {
      position.x = 0;
    } else if (position.x < 0) {
      position.x = w - 0.999;
    }

    if (position.y >= h) {
      position.y = 0;
    } else if (position.y < 0) {
      position.y = h - 0.999;
    }
  }

  /* Impose periodic boundary conditions but preserve magnitude
   *
   * Note special handling of when position exactly equal to 0 in either dimension.
   *
   * May not make much difference over the snap version.
   */
  void checkEdgesPeriodic(int w, int h) {

    float offset = 0.001;  // slight offset to avoid equality with width/height

    if (position.x >= w) {
      position.x = 0 + (position.x - w);
    } else if (position.x < 0) {
      position.x = w + position.x;
    }
    // handle edge case
    if (position.x == w) {
      position.x = w - offset;
    }

    if (position.y >= h) {
      position.y = 0 + (position.y - h);
    } else if (position.y < 0) {
      position.y = h + position.y;
    }
    // handle edge case, catching position.y==0 as a special case is insufficient
    // since position.y will still be assigned value of height when initially small negative number
    if (position.y == h) {
      position.y = h - offset;
    }

    // catch conditions where we have gone more than a full width/height
    // only a concern if we allow topspeed more than width/height
    // using mod works fine here but verify for negative numbers (note -1%n -> -1)
    // TODO improve
    position.x = position.x % w;
    position.y = position.y % h;
  }

  /* Constrain position to edge of display window
   */
  void checkEdgesReflectiveSnap(int w, int h) {

    if (position.x >= w) {
      position.x = w - 0.999;
      velocity.x = -abs(velocity.x);
    } else if (position.x < 0) {
      position.x = 0;
      velocity.x = abs(velocity.x);
    }

    if (position.y >= h) {
      position.y = h - 0.999;
      velocity.y = -abs(velocity.y);
    } else if (position.y < 0) {
      position.y = 0;
      velocity.y = abs(velocity.y);
    }
  }

  /* Impose reflective boundary condition preserving magnitude
   *
   * Particles elastically bounce off edges.
   *
   * Note special handling of when position exactly equal to width or height.
   */
  void checkEdgesReflective(int w, int h) {

    float offset = 0.001;  // slight offset to avoid equality with width/height

    if (position.x > w) {
      position.x = w - (position.x - w);
      velocity.x = -abs(velocity.x);
    } else if (position.x < 0) {
      position.x = 0 - position.x;
      velocity.x = abs(velocity.x);
    }
    // handle edge case
    if (position.x == w) {
      position.x = w - offset;
      velocity.x = -abs(velocity.x);
    }

    if (position.y > h) {
      position.y = h - (position.y - h);
      velocity.y = -abs(velocity.y);
    } else if (position.y < 0) {
      position.y = 0 - position.y;
      velocity.y = abs(velocity.y);
    }
    // handle edge case
    if (position.y == h) {
      position.y = h - offset;
      velocity.y = -abs(velocity.y);
    }

    // catch conditions where we have gone more than a full width/height
    // doesn't precicely handle reflect dynamics
    // but should be fine for large systems and it's just for rare edge cases anyway
    // TODO improve
    position.x = constrain(position.x, 0, w - offset);
    position.y = constrain(position.y, 0, h - offset);
  }

  void checkEdgesMixed(int w, int h) {

    float offset = 0.001;  // slight offset to avoid equality with width/height

    // uses periodic boundary on x axis
    if (position.x >= w) {
      position.x = 0 + (position.x - w);
    } else if (position.x < 0) {
      position.x = w + position.x;
    }
    // handle edge case
    if (position.x == w) {
      position.x = w - offset;
    }

    // uses reflective bounary on y axis
    if (position.y > h) {
      position.y = h - (position.y - h);
      velocity.y = -abs(velocity.y);
    } else if (position.y < 0) {
      position.y = 0 - position.y;
      velocity.y = abs(velocity.y);
    }
    // handle edge case
    if (position.y == h) {
      position.y = h - offset;
      velocity.y = -abs(velocity.y);
    }

    // catch conditions where we have gone more than a full width/height
    // may not precicely handle periodic and/or reflect dynamics
    // but should be fine for large systems and it's just for rare edge cases anyway
    position.x = position.x % w;
    position.y = constrain(position.y, 0, h - offset);
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
}