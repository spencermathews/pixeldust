# Mover Class

## Fields

`position`

`velocity`

`acceleration`

`topspeed`

## Methods

Methods include various ways to *update* the mover's location and to establish boundary conditions by *edge checking*.

### Basic Methods

`display`

### Update Methods

`updateRandomWalkBasic`

`updateRandomWalkVonNeumann`

`updateRandomWalkMoore`

`updateRandom`

`updateMouse`

### Edge Checking Methods

`checkEdgesPeriodicSnap`
: consider calling from Pixeldust and not Mover.updateX to increase flexibility

`checkEdgesPeriodic`

`checkEdgesReflectiveSnap`

`checkEdgesReflective`
