// don't change these keys
final char KEY_ROTATE_CW = ']';
final char KEY_ROTATE_CCW = '[';
final char KEY_ZOOM_IN = '='; // plus sign without the shift
final char KEY_ZOOM_OUT = '-';
final char KEY_ORTHO_MODE = 'o';
final char KEY_TEST_MODE = 't';

enum OrthoMode 
{
    IDENTITY, // straight to viewport with no transformations (Pr, V and M are all the identity)
    CENTER640, // bottom left is (-320,-320), top right is (320,320), center is (0,0)
    BOTTOMLEFT640, // bottom left is (0,0), top right is (640,640)
    FLIPX, // same as CENTER640 but x is flipped
    ASPECT // uneven aspect ratio: x is from -320 to 320, y is from -100 to 100
}
OrthoMode orthoMode = OrthoMode.IDENTITY;
final int NUM_ORTHO = 5;

enum TestMode
{
    PATTERN, 
    SCENE,
    STARFIELD
}
TestMode testMode = TestMode.PATTERN;
final int NUM_TEST = 3;

void keyPressed()
{
  switch(key)
  {
    case KEY_ORTHO_MODE: 
    //switching around the orthographic mode
    if(testMode==TestMode.PATTERN)
    {
      orthoMode = OrthoMode.values()[getNextOrdinal(orthoMode, NUM_ORTHO)];
      println("Orthographic mode: "+orthoMode);
      
      //reset back to center with no camera transforms
      model.reset();
      camera.reset();
    
      cameraZoom = 1;
      cameraCenter = new PVector(0,0);
      cameraRot = 0;
      
      switch(orthoMode)
      {
        case IDENTITY:      projection.reset();                sensitivityX = 0.003; sensitivityY = 0.003;  break;
        case CENTER640:     projection = getOrtho(-320,320,-320,320); sensitivityX = 1; sensitivityY = 1;   break;
        case BOTTOMLEFT640: projection = getOrtho(0,640,0,640);       sensitivityX = 1; sensitivityY = 1;   break;
        case FLIPX:         projection = getOrtho(320,-320,-320,320); sensitivityX = -1;sensitivityY = 1;   break;
        case ASPECT:        projection = getOrtho(-320,320,-100,100); sensitivityX = 1; sensitivityY = 0.32;break;
      }
    }
    break;
    
    case KEY_ZOOM_IN:
    //zoom in
    cameraZoom = cameraZoom * (1+ZOOM_AMOUNT);
    camera = getCamera(cameraCenter, camUp, camPerp, cameraZoom);
    break;
    
    case KEY_ZOOM_OUT:
    //zoom out
    cameraZoom = cameraZoom * (1-ZOOM_AMOUNT);
    camera = getCamera(cameraCenter, camUp, camPerp, cameraZoom);
    break;
    
    case KEY_ROTATE_CW:
    cameraRot -= ROT_AMOUNT;
    camera = getCamera(cameraCenter, camUp, camPerp, cameraZoom);
    break;
    
    case KEY_ROTATE_CCW:
    cameraRot += ROT_AMOUNT;
    camera = getCamera(cameraCenter, camUp, camPerp, cameraZoom);
    break;
    
    case KEY_TEST_MODE:
    
    orthoMode = OrthoMode.IDENTITY;
    projection.reset(); sensitivityX = 0.003; sensitivityY = 0.003;

    testMode = TestMode.values()[getNextOrdinal(testMode, NUM_TEST)];
    println("Test mode: "+testMode);
    
    //reset back to center with no camera transforms
    model.reset();
    camera.reset();
    
    cameraZoom = 1;
    cameraCenter = new PVector(0,0);
    cameraRot = 0;
    
    break;
  }
}

//get the next value of an enum
//taken from assignment 1
int getNextOrdinal(Enum e, int enumLength)
{
  return (e.ordinal() + 1) % enumLength;
}

final int NUM_LINES = 10;
// draw an asymmetric test pattern, centered on (0,0), with the given scale
void drawTest(float scale)
{
  float left, right, top, bottom;
  left = bottom = -scale/2;
  right = top = scale/2;

  strokeWeight(1);
  beginShape(LINES);
  for (int i=0; i<NUM_LINES; i++) 
  {
    float x = left + i*scale/NUM_LINES;
    float y = bottom + i*scale/NUM_LINES;

    setHorizontalColor(i);
    myVertex(left, y);
    myVertex(right, y);

    setVerticalColor(i);
    myVertex(x, bottom);
    myVertex(x, top);
  }
  endShape(LINES);
}

void setHorizontalColor(int i) 
{
  int r, g, b;
  r = 1;
  g = (i>NUM_LINES/2) ? 1:0;
  b = 1;
  stroke(r, g, b);
}

void setVerticalColor(int i) 
{
  int r, g, b;
  r = 1;
  g = 1;
  b = (i>NUM_LINES/2) ? 1:0;
  stroke(r, g, b);
}
