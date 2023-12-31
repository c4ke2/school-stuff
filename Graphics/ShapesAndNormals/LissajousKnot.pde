/*
Draw a Lissajous knot on the raster using the parametric equations given
 in the assignment. Modify the raster using setColor() and setPixel() ONLY.
 */
void drawLissajousKnot() 
{  
  float t = 0;        //step along the pattern
  float x, y, z;      //x,y,z cords for drawing
  
  final float R = 200;                  //knot scale
  final float Ox = .7, Oy = .5;         //affects knot shape
  final float nx = 7, ny = 3, nz = 2;   //affects knot shape
  
  final float stepsMult = 0.0005;      //helps determine how many steps to take
  
  for(int i=0; t<=2*PI; i++)
  {
    //calculate variables
      x = R*cos(nx*t+Ox);
      y = R*cos(ny*t+Oy);
      z = cos(nz*t);
      
      //draw the pixel
      setColor(color((z+1)/2));  //change z to be on a 0-1 scale instead of -1 to 1, set colour to that
      setPixel(x,y);
      
      //increment t
      t = i*stepsMult;
  } 
}
