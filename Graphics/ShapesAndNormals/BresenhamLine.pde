/*
Use Bresenham's line algorithm to draw a line on the raster between
 the two given points. Modify the raster using setColor() and setPixel() ONLY.
 */
void bresenhamLine(int fromX, int fromY, int toX, int toY) 
{
  int x=fromX,y=fromY;    //starting positions for drawing the line
  int deltaX = toX-fromX; //change in x over the course of the line
  int deltaY = toY-fromY; //change in y over the course of the line
  int stepX=1, stepY=1;   //the direction to step in for each direction
  
  //determine steps
  if(deltaY<0)
  {
     stepY = -1;
     deltaY = -deltaY;
  }
  if(deltaX<0)
  {
    stepX = -1;
    deltaX = -deltaX;
  }
    
  float m = float(deltaY)/float(deltaX);  //slope of line
  
  if(abs(deltaY)<=abs(deltaX))
  {//x is fast variable
      float error = m;
      while((stepX==-1 && toX<x)||(x<toX && stepX==1))
      {
        setPixel(x,y);
        x+=stepX;
        
        if(error>0.5)
        {
          y+=stepY;
          error-=1;
        }
        
        error+=m;
      }

  }
  else
  {//y is fast variable
      float error = 0;  //for vertical lines where slope is infinity
      if(deltaX!=0)     //for lines where y is fast
        error = 1/m;
      
      while((stepY==-1 && toY<y)||(y<toY && stepY==1))
      {
        setPixel(x,y);
        y+=stepY;
        
        if(error>0.5)
        {
          x+=stepX;
          error-=1;
        }
        
        error+=(1/m);    //m will never be 0 in this section.  if m is 0, it will use the above code in the if that doesn't divide by m.
      }      
  }
}

/*
Don't change anything below here
*/

void testBresenham() {
  final color WHITE = color(1f, 1f, 1f);
  final color RED = color(1f, 0f, 0f);

  final int SMALL_STEP = 105;
  final int BIG_STEP = 180;

  buffer.updatePixels(); // display everything drawn so far

  buffer.stroke(RED);
  // comparison lines
  // quadrant 1
  correctedLine(0, 0, BIG_STEP, 0);
  correctedLine(0, 0, BIG_STEP, SMALL_STEP);
  correctedLine(0, 0, SMALL_STEP, BIG_STEP);

  // quadrant 2
  correctedLine(0, 0, 0, BIG_STEP);
  correctedLine(0, 0, -BIG_STEP, SMALL_STEP);
  correctedLine(0, 0, -SMALL_STEP, BIG_STEP);

  // quadrant 3
  correctedLine(0, 0, -BIG_STEP, 0);
  correctedLine(0, 0, -BIG_STEP, -SMALL_STEP);
  correctedLine(0, 0, -SMALL_STEP, -BIG_STEP);

  // quadrant 4
  correctedLine(0, 0, 0, -BIG_STEP);
  correctedLine(0, 0, BIG_STEP, -SMALL_STEP);
  correctedLine(0, 0, SMALL_STEP, -BIG_STEP);

  buffer.loadPixels(); // switch back to editing raster
  setColor(WHITE);
  
  // using the implementation of Bresenham's algorithm
  // quadrant 1
  bresenhamLine(0, 0, BIG_STEP, 0);
  bresenhamLine(0, 0, BIG_STEP, SMALL_STEP);
  bresenhamLine(0, 0, SMALL_STEP, BIG_STEP);

  // quadrant 2
  bresenhamLine(0, 0, 0, BIG_STEP);
  bresenhamLine(0, 0, -BIG_STEP, SMALL_STEP);
  bresenhamLine(0, 0, -SMALL_STEP, BIG_STEP);

  // quadrant 3
  bresenhamLine(0, 0, -BIG_STEP, 0);
  bresenhamLine(0, 0, -BIG_STEP, -SMALL_STEP);
  bresenhamLine(0, 0, -SMALL_STEP, -BIG_STEP);

  // quadrant 4
  bresenhamLine(0, 0, 0, -BIG_STEP);
  bresenhamLine(0, 0, BIG_STEP, -SMALL_STEP);
  bresenhamLine(0, 0, SMALL_STEP, -BIG_STEP);
}

/*
 Add a small shift that depends on the direction of the line
 */
void correctedLine(int x0, int y0, int x1, int y1) {
  final int LINE_SHIFT = 5;

  // shift left/right or up/down
  int xDir = -Integer.signum(y1 - y0);
  int yDir = Integer.signum(x1 - x0);
  
  int px0 = rasterToProcessingX(x0 + xDir*LINE_SHIFT);
  int py0 = rasterToProcessingY(y0 + yDir*LINE_SHIFT);
  
  int px1 = rasterToProcessingX(x1 + xDir*LINE_SHIFT);
  int py1 = rasterToProcessingY(y1 + yDir*LINE_SHIFT);

  buffer.line(px0, py0, px1, py1);
}

int rasterToProcessingX(int rx) {
  return width/2 + rx;
}

int rasterToProcessingY(int ry) {
  return height/2 - ry;
}
