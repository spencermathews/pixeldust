# Pixeldust Class

## Fields

img

particles

scaleImg
: how much to downsample image

particlesPerPixel

brightnessPerParticle

## Methods

After setup, the flow (update) is to moveParticles then reconstitute image using particleMerge.


imgStats
: just info

numParticles
: calculate number of particles for entire image (based on brightnessPerParticle value).

pixelSplit
: calculate number of particles corresponding to pixel color (based on brightnessPerParticle value). lossy

pixelMerge
: convert number of particles to brightness value (based on brightnessPerParticle value).

particleSplit
: initialize particles array from image

particleMerge
: consolidate particles into image for rendering

moveParticles
: dynamics!

imgWidth

imgHeight

update

display

