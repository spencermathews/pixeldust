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
    topspeed = 20;
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

  /* Move particles using random walk with Moore neighborhood
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

  /* Move particles by applying a random vector
   *
   * Velocity is limited by the Mover's topspeed field.
   *
   * Modified from Shiffman NOC Example 1.9
   * but included checkEdges here instead of externally
   *
   * param high float maximum magnitude of acceleration vector
   */
  void updateRandom(float high) {
    acceleration = PVector.random2D();
    acceleration.mult(random(high));

    velocity.add(acceleration);
    velocity.limit(topspeed);
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
  void checkEdgesPeriodicSnap() {

    if (position.x >= width) {
      position.x = 0;
    } else if (position.x < 0) {
      position.x = width - 0.999;
    }

    if (position.y >= height) {
      position.y = 0;
    } else if (position.y < 0) {
      position.y = height - 0.999;
    }
  }

  /* Impose periodic boundary conditions but preserve magnitude
   *
   * Note special handling of when position exactly equal to 0 in either dimension.
   *
   * May not make much difference over the snap version.
   */
  void checkEdgesPeriodic() {

    float offset = 0.001;  // slight offset to avoid equality with width/height

    if (position.x >= width) {
      position.x = 0 + (position.x - width);
    } else if (position.x < 0) {
      position.x = width + position.x;
    }
    // handle edge case
    if (position.x == width) {
      position.x = width - offset;
    }

    if (position.y >= height) {
      position.y = 0 + (position.y - height);
    } else if (position.y < 0) {
      position.y = height + position.y;
    }
    // handle edge case, catching position.y==0 as a special case is insufficient
    // since position.y will still be assigned value of height when initially small negative number
    if (position.y == height) {
      position.y = height - offset;
    }
  }

  /* Constrain position to edge of display window
   */
  void checkEdgesReflectiveSnap() {

    if (position.x >= width) {
      position.x = width - 0.999;
      velocity.x = -abs(velocity.x);
    } else if (position.x < 0) {
      position.x = 0;
      velocity.x = abs(velocity.x);
    }

    if (position.y >= height) {
      position.y = height - 0.999;
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
  void checkEdgesReflective() {

    float offset = 0.001;  // slight offset to avoid equality with width/height

    if (position.x > width) {
      position.x = width - (position.x - width);
      velocity.x = -abs(velocity.x);
    } else if (position.x < 0) {
      position.x = 0 - position.x;
      velocity.x = abs(velocity.x);
    }
    // handle edge case
    if (position.x == width) {
      position.x = width - offset;
      velocity.x = -abs(velocity.x);
    }

    if (position.y > height) {
      position.y = height - (position.y - height);
      velocity.y = -abs(velocity.y);
    } else if (position.y < 0) {
      position.y = 0 - position.y;
      velocity.y = abs(velocity.y);
    }
    // handle edge case
    if (position.y == height) {
      position.y = height - offset;
      velocity.y = -abs(velocity.y);
    }
  }

  void checkEdgesMixed() {

    float offset = 0.001;  // slight offset to avoid equality with width/height

    // uses periodic boundary on x axis
    if (position.x >= width) {
      position.x = 0 + (position.x - width);
    } else if (position.x < 0) {
      position.x = width + position.x;
    }
    // handle edge case
    if (position.x == width) {
      position.x = width - offset;
    }

    // uses reflective bounary on y axis
    if (position.y > height) {
      position.y = height - (position.y - height);
      velocity.y = -abs(velocity.y);
    } else if (position.y < 0) {
      position.y = 0 - position.y;
      velocity.y = abs(velocity.y);
    }
    // handle edge case
    if (position.y == height) {
      position.y = height - offset;
      velocity.y = -abs(velocity.y);
    }
  }
}