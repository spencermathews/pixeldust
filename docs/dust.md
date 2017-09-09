# dust

The main Pixeldust executable.

## Configuration

### CSV Format

Each person consists of multiple images and an audio file. These file names, along with timing and other configurations, are given by a CSV file for each person.

* The first line is the name of the audio file
* All subsequent lines list images and options in the format of `IMAGE_FILE, TIMESTAMP, TRANSITION`
*  time is given as M:S
*  transition 1 indicates a normal transition, while transition 0 indicates no transition

e.g.

    audioFile.mp3
    imageFile1.png, 0:59, 1
    ...
    imageFile1.png, 1:59, 0

## Fields

sim

lastTime

isComplete
: Status variable set on every call to sim.run(). Value 0 

isReady

useNet

debug

## Functions

setup

draw
: Main event loop. Normally just calls run(). Otherwise, handles pixels falling.

run
: Simply calls sim.run() and updates isComplete state variable with retval. Note: could probably be moved up to draw().

begin
: Called by mousePressed() or clientEvent() to (re)initialize PixeldustSimulation. Name of csv file is used to select person.

mousePressed

clientEvent

debugMode
