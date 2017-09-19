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

## Global Variables

### Configuration Variables

`fullScreenMode`

`useNet`

`debug`

`csvFileNames`

### Simulation Variables

`nameIndex`

`sim`

`lastTime`

### State Variables

`isComplete`
: Status variable set on every call to sim.run(). Value 0

`triggerState`

### Network Variables

`c`

`serverHost`

`serverPort`

## Functions

settings

setup

draw
: Main event loop. Normally just calls sim.run(). Otherwise, handles pixels falling  and responding to triggered state.

begin
: Called from draw() in response to triggerState set by mousePressed() or clientEvent() to (re)initialize PixeldustSimulation. Name of csv file is used to select person.

### Event Functions

mousePressed

clientEvent

### Network Functions

watchNetwork
: Separate thread which periodically checks network state. If not it attempts to reconnect Client.

### Misc Functions

debugMode
