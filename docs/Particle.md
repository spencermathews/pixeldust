# Particle Class

Derived from Jason Labbe's p5.js [Particles to image](https://www.openprocessing.org/sketch/427313) sketch.

## Global Variables

`loadPercentage`

`closeEnoughtTarget`

`particleSizeSlider`

`speedSlider`

`resSlider`

## Fields

`pos`

`vel`

`acc`

`target`

`isKilled`

`mass`

`maxSpeed`

`maxForce`
: Should logically be swapped with maxSpeed, but names from example sketch.

`currentColor`

`colorBlendRate`

`currentSize`

`distToTarget`

## Methods

Methods include various ways to *update* the mover's location and to establish boundary conditions by *edge checking*.

`move`

`draw`

`kill`

`isOutOfBounds`

`update`

`updateRandom`
