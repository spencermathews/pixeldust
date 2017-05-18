# Pixeldust Class

## Fields

img

imgParticles

imgPixelsOrig

imgParticlesOrig

particles

scaleImg
: how much to downsample image

brightnessPerParticle
: note inversion of brightness such that particles add to black

## Methods

After setup, the flow (update) is to move particles then reconstitute image using particleMerge.


`imgStats`
: output image info

`numParticles`
: calculate number of particles for entire image (based on brightnessPerParticle value).

`pixelSplit`
: calculate number of particles corresponding to pixel color (based on brightnessPerParticle value). lossy

`pixelMerge`
: convert number of particles to brightness value (based on brightnessPerParticle value).

`initParticles`
: Initializes particles array from image. Populates particle, imgParticlesOrig, and imgParticles arrays.

`particleMerge`
: consolidate particles into image for rendering

`imgWidth/imgHeight`
: accessor functions return width/height of scaled image

`update`
: wrapper for dynamics

`display`
: wrapper for display

`initRandom`
: initialize with random particles. Populates particle and imgParticles arrays.
