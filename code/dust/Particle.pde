float closeEnoughTarget = 50;  // was a global in the example
float speedSlider = 1;

// Used by nextImage
float loadPercentage = 1.0;    // 0 to 1.0, originally 0.045
float particleSizeSlider = 1; // originally 8
float resSlider = 1;


/**
 A particle that uses a seek behaviour to move to its target.
 @param {number} x
 @param {number} y
 
 Inspired by Particle to Image by Jason Labbe
 */
class Particle {

  PVector pos;
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0);
  boolean isKilled = false;

  float maxSpeed = random(0.25, 2); // How fast it can move per frame.
  float maxForce = random(8, 15); // Its speed limit.

  color currentColor = color(0);
  float colorBlendRate = random(0.01, 0.05);

  float currentSize = 0;

  // Saving as class var so it doesn't need to calculate twice.
  float distToTarget = 0;

  Particle(float x, float y) {
    this.pos = new PVector(x, y);
  }

  void move() {
    this.distToTarget = dist(this.pos.x, this.pos.y, this.target.x, this.target.y);

    // If it's close enough to its target, the slower it'll get
    // so that it can settle.
    float proximityMult;
    if (this.distToTarget < closeEnoughTarget) {
      proximityMult = this.distToTarget/closeEnoughTarget;
      this.vel.mult(0.9);
    } else {
      proximityMult = 1;
      this.vel.mult(0.95);
    }

    // Steer towards its target.
    if (this.distToTarget > 0) {
      PVector steer = new PVector(this.target.x, this.target.y);
      steer.sub(this.pos);
      steer.normalize();
      steer.mult(this.maxSpeed*proximityMult*speedSlider);
      steer.rotate(random(-1, 1)); // add a little directional randomness 
      this.acc.add(steer);
    }

    // Move it.
    this.vel.add(this.acc);
    this.vel.limit(this.maxForce*speedSlider);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }

  void draw() {
    stroke(this.currentColor);

    strokeWeight(this.currentSize);

    point(this.pos.x, this.pos.y);
  }

  void kill() {
    if (! this.isKilled) {
      this.target = generateRandomPos(width/2, height/2, max(width, height));
      this.isKilled = true;
    }
  }

  boolean isOutOfBounds() {
    return (this.pos.x < 0 || this.pos.x > width || 
      this.pos.y < 0 || this.pos.y > height);
  }

  // tests out of bounds based on a bounding box
  // params as rect(), given as upper-left corner then width and height
  boolean isOutOfBounds(float x1, float y1, float x2, float y2) {
    return (this.pos.x < x1 || this.pos.x > x1 + x2 || 
      this.pos.y < y1 || this.pos.y > y1 + y2);
  }
}