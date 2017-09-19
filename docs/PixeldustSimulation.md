# PixeldustSimulation Class

Orchestrates simulation.

We want to be able to specify a csv file listing an audio file and some arbitrary number of image files, along with the times at which they should be displayed during audio playback.

## Fields

### Configuration Fields

`brightnessThreshold`

### Audio Fields

`audioFile`

`audio`

### Image Fields

`w`

`h`

`imageNames`

`imgs`

`imgIndex`

`particles`

### Timing Fields

`times`

`transitions`

`currentTime`

`currentInterval`

`startTime`

## Methods

### Initialization Methods

`PixeldustSimulation` [constructor]
: Pass in name of guiding csv file and how much to scale images Parses csv file to initialize audioFile, imgs[], and times[], then creates audio, images[],and particles[].
: constructor

`parse`

`initAudio`

`initImages`

`initParticles`

`begin`
: Play audio, note startTime, and initialize current to 0-th. Currently called by dust.pde:begin(). Logically could be included in PixeldustSimulation constructor, but leaving it separate permits images to be loaded prior to starting simulation.

### Control Methods

`setCurrent`

`nextImage`

### Display Methods

`run`
: Main method which performs update and display.

`display`
: Performs basic display of particles.

`displayLetterBox`

### Timing Methods

`elapsedTime`

`convertTime`
: Helper method.
