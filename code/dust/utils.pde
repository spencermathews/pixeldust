/**
 Randomly uses an angle and magnitude from supplied position to get a new position.
 @param {number} x
 @param {number} y
 @param {number} mag
 @return {p5.Vector}
 */
PVector generateRandomPos(float x, float y, float mag) {
  PVector pos = new PVector(x, y);

  PVector randomDirection = new PVector(random(width), random(height));

  PVector vel = PVector.sub(randomDirection, pos);
  vel.normalize();
  vel.mult(mag);
  pos.add(vel);

  return pos;
}