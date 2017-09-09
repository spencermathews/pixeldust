# Raspberry Pi Code

`pixeldustSensorNet`
: Production code! Server for the Pi that triggers Pixeldust (dust.pde). It's a merging of the hardware interface of `pixeldustsensor` and the network interface of `triggerTest`.

`triggerTest`
: Use for testing! Sends a network trigger using the [Processing Network Library](https://processing.org/reference/libraries/net/). Simplification of [SharedCanvasServer.pde](https://github.com/processing/processing/blob/master/java/libraries/net/examples/SharedCanvasServer/SharedCanvasServer.pde). See [Network Tutorial](https://processing.org/tutorials/network/) for explanation.

`pixeldustsensor`
: Direct translation of Jesse's Python code for triggering an LED using a prox sensor using the [Processing Hardware I/O Library](https://processing.org/reference/libraries/io/).
