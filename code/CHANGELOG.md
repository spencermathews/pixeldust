# Pixeldust Changelog

## [Unreleased]

### Added

### Changed

### Fixed

## [0.7.0] - 2017-05-16

### Added

* Make `numParticles` a field in Pixeldust for consistency and to limit calls to `numParticles()`.
* New boundary conditions: `checkEdgesMixed()` to give the appearance of a ground.
* Variables to track pixel overflow/underflow (should probably reconsider).
* `README` and `CHANGELOG`

### Changed

* Improve `particleMerge()` so that it uses the `imgParticles` array.
* New parameter to `initRandom()` to allow particles to be limited to bottom of display window.
* Renamed `checkEdgesPeriodic()` to `checkEdgesPeriodicSnap()` and added new `checkEdgesPeriodic()` which maintains position better.
* Renamed `checkEdgesConstrained()` to `checkEdgesReflectiveSnap()`

## [0.6.0] - 2017-05-16

### Added

* More boundary conditions: `checkEdgesConstrained()` and `checkEdgesReflective()`, and rename original to `checkEdgesPeriodic()`.

### Changed

* Improve `updateForward()` so it updates particle counts after every move so pixels aren't falsely treated as overflowed.
* Moved edge checking call out of Mover so it's easier to fiddle with and more in in line with Shiffman's flow.

## [0.5.0] - 2017-05-15

### Added

* Function to update array of particle counts.
* Proper random walk functions that allow a no move option, for von Neumann and Moore neighborhoods.
* Function to directly display particles.

### Changed

* Random vector update function now take a parameter to set maximum acceleration.
* Bin particles at end of update functions instead of before reassembly/display.

### Fixed

* Use Shiffman's random walker code which restricts it to only one of up/down/left/right. Previous implementation forced a move of both x and y, limiting moves to diagonals. Neither allows a no move option.

## [0.4.0] - 2017-05-15

### Added

* Mouse following update method.
* Array to store particle counts corresponding to original image.
* Simple update method to nudge particles toward forming image (forward direction).

### Changed

* Pixeldust constuctor to allow image scale factor (downsampling) to be easily modified.

## [0.3.0] - 2017-05-10

* Particles representation from PVector to Mover class.

## [0.2.0] - 2017-05-10

### Added

* Pixeldust class to orchestrate simulation.
* Ability to initialize particles randomly.
* Update method using random vectors, now the default.

### Changed

* Rename main pde.

## [0.1.0] - 2017-03-07

### Added

* Simple framework for decomposing pixels into particles, scattering pixels using random walk, and reassembling into pixels.

