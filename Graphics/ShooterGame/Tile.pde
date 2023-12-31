//single tile in the background

final float TSIZE = 50;     //size of a tile
final float C_DIFF = 0.05;  //how much darker the colors of the sides are in color mode

class Tile
{
  float xOff = 0;
  float yOff = 0;
  float zOff = 0;
  
  float xInit = 0;
  float yInit = 0;
  
  color c;
  color sc;

  PImage topTexture;
  PImage sideTexture;
  
  Tile(float x, float y)
  {
    c = (getRandomColour());
    sc = color(red(c)-C_DIFF,green(c)-C_DIFF,blue(c)-C_DIFF);
    zOff = random(-1,0)*TSIZE;
    xInit = x*TSIZE;    //offsets not locked to tiles, this is for initial values so scrolling should be fine
    yInit = y*TSIZE;
    
    int tex = (int)(random(0,2));
    topTexture = grassTexture[tex];
    tex = (int)(random(0,2));
    sideTexture = pillarTexture[tex];
  }
  
  void drawTile()
  {
      fill(c);
      beginShape(TRIANGLES);
      if(doTextures)
        texture(topTexture);
      vertex((-TSIZE/2)+xOff,(TSIZE/2)+yOff,(zOff)+Z_CENT,0,1);
      vertex((TSIZE/2)+xOff,(-TSIZE/2)+yOff,(zOff)+Z_CENT,1,0);
      vertex((TSIZE/2)+xOff,(TSIZE/2)+yOff,(zOff)+Z_CENT,1,1);
      
      vertex((-TSIZE/2)+xOff,(TSIZE/2)+yOff,(zOff)+Z_CENT,0,1);
      vertex((-TSIZE/2)+xOff,(-TSIZE/2)+yOff,(zOff)+Z_CENT,0,0);
      vertex((TSIZE/2)+xOff,(-TSIZE/2)+yOff,(zOff)+Z_CENT,1,0);
      endShape();
      
        fill(sc);
  
        //only draw back if on upper side of screen; only draw front if on lower side
        //similar for left and right sides
        if(yOff<.5)
        {//back
          beginShape(TRIANGLES);
          if(doTextures)
            texture(sideTexture);
          vertex((-TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT,0,1);
          vertex((TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT+zOff,1,0);
          vertex((TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT,1,1);
          
          vertex((TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT+zOff,1,0);
          vertex((-TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT,0,1);
          vertex((-TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT+zOff,0,0);
          endShape();
        }
        else
        {//front
          beginShape(TRIANGLES);
          if(doTextures)
            texture(sideTexture);
          vertex((-TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT,0,1);
          vertex((TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT+zOff,1,0);
          vertex((TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT,1,1);
          
          vertex((TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT+zOff,1,0);
          vertex((-TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT,0,1);
          vertex((-TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT+zOff,0,0);
          endShape();
        }
        if(xOff<.5)
        {//left
          beginShape(TRIANGLES);
          if(doTextures)
            texture(sideTexture);
          vertex((TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT,0,1);
          vertex((TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT+zOff,1,0);
          vertex((TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT,1,1);
          
          vertex((TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT+zOff,1,0);
          vertex((TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT,0,1);
          vertex((TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT+zOff,0,0);
          endShape();
          
        }
        else
        {//right
          beginShape(TRIANGLES);
          if(doTextures)
            texture(sideTexture);
          vertex((-TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT,0,1);
          vertex((-TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT+zOff,1,0);
          vertex((-TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT,1,1);
          
          vertex((-TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT+zOff,1,0);
          vertex((-TSIZE/2)+xOff,(-TSIZE/2)+yOff,Z_CENT,0,1);
          vertex((-TSIZE/2)+xOff,(TSIZE/2)+yOff,Z_CENT+zOff,0,0);
          endShape();
        }
  }
  
  void moveTile(float x,float y)
  {
    xOff = xInit + x;
    yOff = yInit + y;
  }
  
}

color getRandomColour()
{
  return color(random(1.0),random(1.0),random(1.0));
}
