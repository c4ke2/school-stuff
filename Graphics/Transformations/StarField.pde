// for accessing components of homogeneous 4-vectors
final int X = 0;
final int Y = 1;
final int Z = 2;
final int W = 3;
final int NUM_COORDS = 4;

final int NUM_STARS = 150; // reset as desired
float[][] stars = new float[NUM_STARS][NUM_COORDS];

final float STAR_SPEED = 4;  //how fast the stars move
float wrapZ = -500;  //Z cord of the far plane
float wrapN = -180;  //Z cord of the near plane
float xRange = 320;  //left at -xRange, right at xRange
float yRange = 320;  //top and bottom based from this

// construct projection matrix for view frustum
PMatrix3D getViewFrustum(float left, float right, float bottom, float top, float near, float far)
{
  PMatrix3D frustrum = new PMatrix3D(2*near/(right-left),0,(right+left)/(right-left),0,
  0,2*near/(top-bottom),(top+bottom)/(top-bottom),0,
  0,0,-((far+near)/(far-near)),(-2*near/(far-near)),
  0,0,-1,0);
  return frustrum;
}

//=========================
// initialize the positions of the stars
//=========================
void initStars()
{
  for(int i=0;i<NUM_STARS;i++)
  {
    stars[i][X] = random(-xRange,xRange);
    stars[i][Y] = random(-yRange,yRange);
    stars[i][Z] = random(wrapZ, wrapN);
    stars[i][W] = 1;
    
    stars[i] = getViewFrustum(-xRange,xRange, -yRange, yRange, wrapN, wrapZ).mult(stars[i],null);
    stars[i][Z] = random(wrapZ,wrapN);
  }
}

//=========================
// update the z position of each star
//=========================
void moveStars() 
{
  for(int i=0; i<NUM_STARS;i++)
  {
    stars[i][Z] = (stars[i][Z]-STAR_SPEED);
    if(stars[i][Z] < wrapZ)
      stars[i][Z] = wrapN;
  }
}

//=========================
// draw the stars
//=========================
void drawStars() 
{
  stroke(WHITE);
  beginShape(POINTS);
  for(int i=0; i<NUM_STARS;i++)
  {
    myPush();
    
    strokeWeight((1 - (stars[i][Z]/wrapZ))*5);  //make stars get smaller as they approach the far plane so they don't just vanish
      
    myTranslate(stars[i][X]/(stars[i][Z]),stars[i][Y]/(stars[i][Z]));
    myVertex(0,0);
    
    myPop();
  }
  endShape();
}
