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


/**
 Dynamically adds/removes particles to make up the next image.
 */
void nextImage() {
  // Switch index to next image.
  imgIndex++;
  if (imgIndex > imgs.length-1) {
    imgIndex = 0;
  }
  imgs[imgIndex].loadPixels();

  // Create an array of indexes from particle array.
  ArrayList<Integer> particleIndexes = new ArrayList<Integer>();
  for (int i = 0; i < allParticles.size(); i++) {
    particleIndexes.add(i);
  }

  int pixelIndex = 0;

  // Go through each pixel of the image.
  for (int y = 0; y < imgs[imgIndex].height; y++) {
    for (int x = 0; x < imgs[imgIndex].width; x++) {
      // Get the pixel's color.
      color pixel = imgs[imgIndex].pixels[pixelIndex];

      pixelIndex += 1;

      // Do not assign a particle to this pixel under some conditions
      if (random(1.0) > loadPercentage*resSlider || brightness(pixel) > brightnessThreshold) {
        continue;
      }

      color pixelColor = pixel;

      Particle newParticle;
      if (particleIndexes.size() > 0) {
        // Re-use existing particle.
        // JS Array splice can handle non-int params it seems, but ArrayList.remove fails, also was originally length-1
        int index = particleIndexes.remove(int(random(particleIndexes.size())));
        newParticle = allParticles.get(index);
      } else {
        // Create a new particle.
        newParticle = new Particle(random(width), height-1);
        allParticles.add(newParticle);
      }

      newParticle.target.x = x+width/2-imgs[imgIndex].width/2;
      newParticle.target.y = y+height/2-imgs[imgIndex].height/2;
      newParticle.currentColor = pixelColor;
      newParticle.currentSize = particleSizeSlider;
    }
  }

  // Kill off any left over particles that aren't assigned to anything.
  if (particleIndexes.size() > 0) {
    for (int i = 0; i < particleIndexes.size(); i++) {
      allParticles.get(particleIndexes.get(i)).kill();
    }
  }
  println("Particles:", allParticles.size(), "Left over:", particleIndexes.size());
}