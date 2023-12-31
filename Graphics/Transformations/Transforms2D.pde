//global matrices
PMatrix2D model      = new PMatrix2D(1,0,0,0,1,0);
PMatrix2D camera     = new PMatrix2D(1,0,0,0,1,0);
PMatrix2D projection = new PMatrix2D(1,0,0,0,1,0);
PMatrix2D viewport   = new PMatrix2D(1,0,0,0,1,0);

//camera variables
PVector cameraCenter    = new PVector(0,0);
PVector camUp           = new PVector(0,1);
PVector camPerp         = new PVector(1,0);

float cameraZoom     = 1;
final float ZOOM_AMOUNT = 0.03;  //zoom per button press

float cameraRot = 0;
final float ROT_AMOUNT = PI/24;  //about 7.5 degrees per button press

// construct viewport matrix using width and height of canvas
PMatrix2D getViewPort() 
{
  return new PMatrix2D(width/2,0,width/2,0,-height/2,height/2);
}

// construct projection matrix using 2D boundaries
PMatrix2D getOrtho(float left, float right, float bottom, float top) 
{
  PMatrix2D invertB = new PMatrix2D(2/(right-left),0,0,0,2/(top-bottom),0);
  PMatrix2D T = new PMatrix2D(1,0,-((top+bottom)/2),0,1,-((right+left)/2));
  T.preApply(invertB);
  return T;
}

// construct camera matrix using camera position, up vector, and zoom setting
PMatrix2D getCamera(PVector center, PVector up, PVector perp, float zoom)
{
  //calculate the base camera matrix (before transforms)
  up.normalize();
  perp.normalize();
  
  float det = (perp.x*up.y - up.x-perp.y);// 1 / ad-bc
  PMatrix2D invertB = new PMatrix2D(up.y/det,-up.x/det,0,-perp.y/det,perp.x/det,0);
  //formula derived from the notes
  PMatrix2D cam = new PMatrix2D(1,0,-center.x,0,1,-center.y);  //translation to center
  cam.preApply(invertB);

  //apply the zoom
  myPush();
  myScale(zoom,zoom);
  cam.preApply(model);
  myPop();

  return cam;
}

/*
Functions that manipulate the matrix stack
*/

void myPush()
{
  //push the model matrix
  matrixStack.push(model.get());
}

void myPop()
{
  //pop the stack
  model = matrixStack.pop();
}

/*
Functions that update the model matrix
*/

void myScale(float sx, float sy)
{
  //remember to push and pop after these
  PMatrix2D scale = new PMatrix2D(sx,0,0,0,sy,0);
  model.preApply(scale);
}

void myTranslate(float tx, float ty)
{
  //remember to push and pop after these
  PMatrix2D tran = new PMatrix2D(1,0,tx,0,1,ty);
  model.preApply(tran);
}

void myRotate(float theta)
{
  //remember to push and pop after these
  PMatrix2D rot = new PMatrix2D(cos(theta),-sin(theta),0,sin(theta),cos(theta),0);
  model.preApply(rot);
}

/* 
overloads for convenience: draw a point when given 
in the form of a PVector or as separate coordinates
*/
void myVertex(PVector vert)
{
  drawVertex(vert.x, vert.y, false);
}

void myVertex(float x, float y)
{
  drawVertex(x, y, false);
}

/*
Receives a point in object space and applies the complete transformation
pipeline, Vp.Pr.V.M.point, to put the point in viewport coordinates.
Then calls vertex to plot this point on the raster
*/
void drawVertex(float x, float y, boolean debug)
{
  PVector p = getMyVertex(x,y);
  if (debug) 
    println("("+x+", "+y+") --> ("+p.x+", "+p.y+")");
  
  vertex(p.x, p.y);
}

PVector getMyVertex(float x, float y)
{
  PVector p = new PVector(x,y,0);  //in object coordinates

  myPush();
  
  if(testMode != TestMode.STARFIELD)
    myRotate(cameraRot);
    
  p = model.mult(p,null);
  p = camera.mult(p,null);

 if(testMode != TestMode.STARFIELD)
    p = projection.mult(p,null);
  
  p = viewport.mult(p,null);
  
  myPop();
  
  return p;
}
