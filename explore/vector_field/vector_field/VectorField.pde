class VectorField {

  VectorField() {
  }

  /* Solve for vector at point using simple harmonic oscillator
   *
   * TODO should make so we can give it any function
   */
  PVector evaluate(PVector location) {
    float x = location.y;
    float y = -location.x;
    return new PVector(x, y);
  }

  //// inspired by Shiffman https://processing.org/tutorials/pvector/
  //void iterate(PVector location, float dt) {
  //  PVector velocity = evaluate(location);
  //  location.add(velocity); // acts on parameter!
  //}

  /* Draw vectors 
   *
   * spacing
   * scayl scales arrow length relative to spacing
   */
  void drawVectors(float spacing, float scayl) {
    for (float x = -width/2 + spacing; x < width/2; x+=spacing) {
      for (float y = -height/2 + spacing; y < height/2; y+=spacing) {
        PVector loc = new PVector(x, y);
        drawVector(evaluate(loc), loc, spacing*scayl);
      }
    }
  }

  /* Renders a vector object 'v' as an arrow and a position 'loc'
   *
   * From Shiffman SmokeParticleSystem, though may be other better examples
   *
   * TODO make background a heat map of velocity
   */
  void drawVector(PVector v, PVector loc, float scayl) {
    pushMatrix();
    float arrowsize = 4;
    // Translate to position to render vector
    translate(loc.x, loc.y);
    stroke(255);
    // Call vector heading function to get direction (note that pointing up is a heading of 0) and rotate
    rotate(v.heading());
    // Calculate length of vector & scale it to be bigger or smaller if necessary
    float len = v.mag()*scayl;
    // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
    line(0, 0, len, 0);
    line(len, 0, len-arrowsize, +arrowsize/2);
    line(len, 0, len-arrowsize, -arrowsize/2);
    popMatrix();
  }
}