/*
 *
 */
 int x = 5;
 float brightnessPerParticle = 255/5;

void setup() {
  
  for (int i = 0; i<256; i++) {
    
    println(i, pixelSplit(color(i)), pixelSplit2(color(i)), pixelSplit3(color(i)));
  }
  
  
}

void draw() {
}
  // original
  int pixelSplit(color c) {
    return int((255 - brightness(c)) / brightnessPerParticle);
  }

 int pixelSplit2(color c) {
    return int(255/brightnessPerParticle - brightness(c) / brightnessPerParticle);
  }
  int pixelSplit3(color c) {
    return int(255/brightnessPerParticle - int(brightness(c) / brightnessPerParticle));
  }

  /*
   * Determine pixel brightness based on how many particles occupy that pixel
   *
   * Used to convert particle density to color value. 
   *
   * param  particleCount int number of particles occupying pixel space
   * return               color
   */
  color pixelMerge(int particleCount) {
    float b = 255 - particleCount * brightnessPerParticle;
    return color(b);
  }