# Pixeldust Code

This is the main code for Pixeldust.

## Contents

### /dust

`dust.pde`
: the main sketch

`PixeldustSimulation`
: Orchestrates a series of images

`Pixeldust`
: Represents a single image

`Mover`
: Represents a particle

### /pi

`pixelDustSensorNet.pde`
: Triggers Pixeldust from Raspberry Pi using prox sensor

## Setup

Running Pixeldust requires code from the `master` branch and data from the `data` branch. The following commands will set things up.

    git clone https://github.com/spencermathews/pixeldust.git
    cd pixeldust
    git checkout master
    git checkout data -- code/dust/data
    git reset

If you have already cloned the repository then the checkouts and reset should suffice.

Run `code/dust/dust.pde`.

Note: additional steps are required to run without the network trigger, see below.

### Testing

#### Network Triggering

By default Pixeldust will look for a the network trigger. To test locally the code must be instructed to either ignore the network trigger (easy way) or a local trigger can be run (more complicated):

* Disable network trigger by changing `useNet` to `false`
* Alternatively, the trigger may be run locally by changing hardcoded `serverHost` to localhost `127.0.0.1` and running `triggerTest.pde` instead of `pixelDustSensorNet.pde`

The simulation can be triggered by a left mouse click in the display window. A right click will immediately end the current person and reinitialize beginning with the next person.

#### Fullscreen Mode

By default Pixeldust will run fullscreen. It may be useful to run in windowed mode:

* Run in windowed mode by changing `fullScreenMode` to `false`

#### Debug Mode

Debug mode cases the framerate, progress, etc to be output:

* Enable debug mode by changing `debug` to `true`




