/*******************************************

This program implements the transformation
pipeline.  Modes include a test pattern,
a hierarchal model, and a 3D star field

*******************************************/

import java.util.Stack;  // for your matrix stack
Stack<PMatrix2D> matrixStack = new Stack<PMatrix2D>();

void setup() 
{
  size(640, 640);  // don't change, and don't use the P3D renderer
  colorMode(RGB, 1.0f);

  viewport = getViewPort();
  camera = getCamera(cameraCenter, camUp, camPerp, cameraZoom);  //at this point it's the identity matrix
  initStars();
  
  println("Test mode: "+testMode);
  println("Orthographic mode: "+orthoMode);
}

void draw() 
{  
  clear();
  switch (testMode) 
  {
  case PATTERN:
    // three copies of the same pattern, at different scales
    drawTest(1000); 
    drawTest(100);
    drawTest(1);
    break;

  case SCENE:
    drawScene();
    break;

  case STARFIELD:
    moveStars();
    drawStars();
    break;
  }
}

// feel free to add a new file for drawing your scene
void drawScene()
{
  //draws a cross of rotated pikachu (pikachu is the mascot of Pokemon, you've definitely seen it before)
  //zoom out and hold down rotation key to spin it like a wheel
  //some pikachus have shorter or longer tails than others (this is on purpose)
  
  float pikaOffset = 5;  //where to start the cross
  pikaCenterX=-pikaOffset;
  pikaCenterY=pikaOffset;
  
  for(int i=0;i<9;i++)
  {
    pikaCenterRot = (i+4)*(2*PI/8);
    pikaCenterX += 1;
    pikaCenterY += -1;
    
    if(i<4)
      drawPikachu(YELLOW3,BROWN2,RED2,i);
    else
      drawPikachu(YELLOW5,BROWN3,RED,i);
  }
  
  pikaCenterX=pikaOffset;
  pikaCenterY=pikaOffset;
  for(int i=0;i<9;i++)
  {
    pikaCenterRot = (i+4)*(2*PI/8);
    pikaCenterX += -1;
    pikaCenterY += -1;
    if(i<3)
      drawPikachu(YELLOW,BROWN2,RED3,i);
    else if (i<5)
      drawPikachu(YELLOW2,BROWN,RED,i);
    else
      drawPikachu(YELLOW4,BROWN3,RED2,i);
  }
}

float sensitivityX = 0.003;
float sensitivityY = 0.003;
void mouseDragged()
{
  float xMove = mouseX - pmouseX;
  float yMove = mouseY - pmouseY; 

  PVector adj = new PVector(-(xMove*sensitivityX)/cameraZoom,(yMove*sensitivityY)/cameraZoom);
  cameraCenter.add(adj);
  camera = getCamera(cameraCenter, camUp, camPerp, cameraZoom);
}
