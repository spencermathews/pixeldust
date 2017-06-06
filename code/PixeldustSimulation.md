# PixeldustSimulation Class

Orchestrates simulation.

We want to be able to specify a csv file listing an audio file and some arbitrary number of image files, along with the times at which they should be displayed during audio playback.

## Fields

`audioFile`

`audio`

`imageFiles`

`images`

`width`

`height`

`times`

`particles`

`startTime`

## Methods

### Initialization Methods

`PixeldustSimulation` [constructor]
: Pass in name of guiding csv file, how much to scale images, and number of particles per black pixel. Parses csv file to initialize audioFile, imageFiles[], and times[], then creates audio, images[],and particles[].
: constructor

`parse`

`convertTime`
: helper method

`initAudio`

`initImages`

`initParticles`

`begin`
: Play audio, note startTime, and initialize current to 0-th.

### General Methods

`setCurrent`
:

`run`

### Helper Methods

`convertTime`

`elapsedTime`

## Etc

Single experiment to test particle limits (implemented as Mover[]):

Particles | RAM
----------|----
2^15 | 80 MB
2^20 (1M) | 170 MB
2^21 (2M)| 334 MB
2^22 (4M)| 600 MB
2^23 (8M)| 1.2 GB
2^24 | tired of waiting

Note: 32-bit signed `int` have range -2,147,483,648 ($$−2^{31}$$) through 2,147,483,647 ($$2^{31}−1$$), and it's doubtful Processing allows 64-bit `long` for array indexing. So this puts an upper limit on the number of possible particles.
