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


## Notes

Shiffman's constructor prior to adding `applyForce()` did not bother to set `acceleration` since that implementation used atomic `update()` functions which started by creating a new acceleration vector. The addition of general forces led to the splitting into two methods: `applyForce()` which simply added forces into the current acceleration, and `update()` which then applied the acceleration to the current velocity and then updates position (then zeroed acceleration since it does not persist). The constructor was concurrently updated to initialize acceleration to 0.