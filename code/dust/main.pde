/*
Particles to image
 
 Converted from p5.js to Processing by Spencer Mathews
 
 Particles seek a target to make up an image. 
 They get bigger the closer they get to their target.
 
 Controls:
 - Press any key to change to the next image.
 - Use the on-screen controls to change settings.
 
 Author:
 Jason Labbe
 
 Site:
 jasonlabbe3d.com
 */

PImage[] imgs = new PImage[0];
String[] imgNames = {"Chavez-gloves.png", "Chavez-Chavez.png", "Chavez-name.png"};
int imgIndex = -1;

float loadPercentage = 1.0; // 0 to 1.0, originally 0.045
float closeEnoughTarget = 50;

ArrayList<Particle> allParticles = new ArrayList<Particle>();

// Used by Particle
// TODO convert back into sliders
float particleSizeSlider = 1; // originally 8
float speedSlider = 1;
// Used by nextImage
float resSlider = 1;
//var nextImageButton;

float brightnessThreshold = 254; // do no create particles from pixels lighter than this


void _setup() {
  size(960, 540, FX2D);

  //// Create on-screen controls.
  //mouseSizeSlider = new SliderLayout("Mouse size", 50, 200, 100, 1, 100, 100);

  //particleSizeSlider = new SliderLayout("Particle size", 1, 20, 8, 1, 100, mouseSizeSlider.slider.position().y+70);

  //speedSlider = new SliderLayout("Speed", 0, 5, 1, 0.5, 100, particleSizeSlider.slider.position().y+70);

  //resSlider = new SliderLayout("Count multiplier (on next image)", 0.1, 2, 1, 0.1, 100, speedSlider.slider.position().y+70);

  //nextImageButton = createButton("Next image");
  //nextImageButton.position(100, resSlider.slider.position().y+40);
  //nextImageButton.mousePressed(nextImage);

  // Pre-load all images.
  for (int i = 0; i < imgNames.length; i++) {
    PImage newImg = loadImage(imgNames[i]);
    float scaleImg = 2;
    newImg.resize(floor(newImg.width/scaleImg), 0);
    imgs = (PImage[])append(imgs, newImg);
  }

  // Change to first image.
  nextImage();
}


void _draw() {
  background(255);

  for (int i = allParticles.size()-1; i > -1; i--) {
    allParticles.get(i).move();
    allParticles.get(i).draw();

    if (allParticles.get(i).isKilled) {
      if (allParticles.get(i).isOutOfBounds()) {
        allParticles.remove(i);
      }
    }
  }

  //// Display slider labels.
  //mouseSizeSlider.display();_
  //particleSizeSlider.display();
  //speedSlider.display();
  //resSlider.display();

  if (mousePressed) {
    image(imgs[imgIndex], 0, 0);
  }

  surface.setTitle(int(frameRate) + " fps");
}


void _keyPressed() {
  nextImage();
}