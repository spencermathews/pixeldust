# Pixeldust Class

The original image file is read into `img` and saved there. A scaled version of the image (based on scale factor `scaleImg`) is saved as `imgPixelsOrig`.  `imgPixels`

## Fields

`img`
: original image

`imgPixelsOrig`
: original image scaled

`imgParticlesOrig`
: per pixel occupation of original scaled image

`particles`
: array of Movers

`imgParticles`
: number of particles within each pixel area, recomputed from `particles` array

`imgPixels`
: image to render based on particle occupation, recomputed from `imgParticles`

`scaleImg`
: how much to downsample image

brightnessPerParticle
: note inversion of brightness such that particles add to black

## Methods

After setup, the flow (update) is to move particles then reconstitute image using particleMerge.

### Basic Methods

`update`
: wrapper for dynamics

`display`
: wrapper for display

### Manipulation Methods

`particleMerge`
: consolidate particles into image for rendering

`pixelSplit`
: calculate number of particles corresponding to pixel color (based on `brightnessPerParticle` value). lossy

`pixelMerge`
: convert number of particles to brightness value (based on `brightnessPerParticle` value).

### Utility Methods

`numParticles`
: calculate number of particles for entire image (based on `brightnessPerParticle` value).

### Initialization Methods

`Pixeldust`
: constructor

`initParticles`
: Initializes `particles` array from `imgPixelsOrig`. Populates `particles`, `imgParticlesOrig`, and `imgParticles` arrays.

`initRandom`
: initialize with random particles. Populates `particles` and `imgParticles` arrays.

### Accessor and Informational Methods

`imgStats`
: output image info

`imgWidth/imgHeight`
: accessor functions return width/height of scaled image

