# Pixeldust Code

This is the main code for Pixeldust.

# Dust

`dust.pde`
: the main sketch

`PixeldustSimulation`
: Orchestrates a series of images

`Pixeldust`
: Represents a single image

`Mover`
: Represents a particle

# Pi

pixelDustSensorNet
: Triggers Pixeldust from Raspberry Pi using prox sensor

## Setup

Running Pixeldust requires code from the `master` branch and data from the `data` branch. The following commands will set things up. Run from the `pixeldust` root directory.

    git checkout master
    git checkout data -- code/dust/data
    git reset


