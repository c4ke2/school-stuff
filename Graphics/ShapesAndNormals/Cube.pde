/*
Create and return the array of triangles that tessellate a cube of the given
 side length that is centered on (0,0,0). The triangles are right triangles whose
 legs (perpendicular sides) lie along or are parallel to the edges of the cube.
 The constant CUBE_DIVISIONS is the number of triangles that lie along *each* edge
 on *each* face of the cube.  For example:
 divisions = 3 
 --> 3 triangles per edge
 --> 3 x 3 x 2 = 18 triangles per face (draw this on paper if it isn't clear)
 --> 18 x 6 = 108 triangles total
 */

// for the cube and its tessellation
final float CUBE_SIZE = 300;
final int CUBE_DIVISIONS = 10;
// start with a small number for CUBE_DIVISIONS, like 1 or 2.  Once things are working,
// increase to around 10

class Cube
{
    float squareLength = CUBE_SIZE/CUBE_DIVISIONS;  //length of a side of each square on the cube, each is made of 2 triangles
     
    //triangles for each face
    Triangle[] triF = new Triangle[CUBE_DIVISIONS*CUBE_DIVISIONS*2];
    Triangle[] triB = new Triangle[CUBE_DIVISIONS*CUBE_DIVISIONS*2];
    Triangle[] triT = new Triangle[CUBE_DIVISIONS*CUBE_DIVISIONS*2];
    Triangle[] triBt = new Triangle[CUBE_DIVISIONS*CUBE_DIVISIONS*2];
    Triangle[] triR = new Triangle[CUBE_DIVISIONS*CUBE_DIVISIONS*2];
    Triangle[] triL = new Triangle[CUBE_DIVISIONS*CUBE_DIVISIONS*2];
    
    //initialize all triangles
    void initAll()
    {
      initFront();
      initBack();
      initTop();
      initBottom();
      initRight();
      initLeft();
    }
    
    //initialize the front triangles
    void initFront()
    {
        float[][][] vertF = new float[CUBE_DIVISIONS+1][CUBE_DIVISIONS+1][3];
        final float zPos = CUBE_SIZE/2;
        int xOff = 0;
        int yOff = 0;
        
        for(int y =0; y < CUBE_DIVISIONS+1; y++)
        {
          for(int x = 0; x<CUBE_DIVISIONS+1;x++)
          {
            vertF[x][y][X] = (-CUBE_SIZE/2)+xOff;
            vertF[x][y][Y] = (CUBE_SIZE/2)+yOff;
            vertF[x][y][Z] = zPos;
            
            xOff += squareLength;
          }
          
          yOff -= squareLength;
          xOff = 0;
        }

        int index = 0;
        for(int y=0;y<CUBE_DIVISIONS;y++)
        {
          for(int x = 0;x<CUBE_DIVISIONS;x++)
          {

              triF[index] = new Triangle(vertF[x][y],vertF[x+1][y+1],vertF[x+1][y]);
              index++;
              triF[index] = new Triangle(vertF[x][y],vertF[x][y+1],vertF[x+1][y+1]);
              index++;

          } 
        }
    }
    
    //initialize the back face
    void initBack()
    {
        float[][][] vertB = new float[CUBE_DIVISIONS+1][CUBE_DIVISIONS+1][3];
        final float zPos = -CUBE_SIZE/2;
        int xOff = 0;
        int yOff = 0;
        
        for(int y =0; y < CUBE_DIVISIONS+1; y++)
        {
          for(int x = 0; x<CUBE_DIVISIONS+1;x++)
          {
            vertB[x][y][X] = (-CUBE_SIZE/2)+xOff;
            vertB[x][y][Y] = (CUBE_SIZE/2)+yOff;
            vertB[x][y][Z] = zPos;
            
            xOff += squareLength;
          }
          
          yOff -= squareLength;
          xOff = 0;
        }
        
        int index = 0;
        for(int y=0;y<CUBE_DIVISIONS;y++)
        {
          for(int x = 0;x<CUBE_DIVISIONS;x++)
          {
              triB[index] = new Triangle(vertB[x][y],vertB[x+1][y],vertB[x+1][y+1]);
              index++;
              triB[index] = new Triangle(vertB[x][y],vertB[x+1][y+1],vertB[x][y+1]);
              index++;
          } 
        }
    }
    
    //initialize the top face
    void initTop()
    {
        float[][][] vertT = new float[CUBE_DIVISIONS+1][CUBE_DIVISIONS+1][3];
        final float yPos = CUBE_SIZE/2;
        int xOff = 0;
        int yOff = 0;
        
        for(int y =0; y < CUBE_DIVISIONS+1; y++)
        {
          for(int x = 0; x<CUBE_DIVISIONS+1;x++)
          {
            vertT[x][y][X] = (-CUBE_SIZE/2)+xOff;
            vertT[x][y][Y] = yPos;
            vertT[x][y][Z] = (CUBE_SIZE/2)+yOff;
            
            xOff += squareLength;
          }
          
          yOff -= squareLength;
          xOff = 0;
        }
        int index = 0;
        for(int y=0;y<CUBE_DIVISIONS;y++)
        {
          for(int x = 0;x<CUBE_DIVISIONS;x++)
          {
              triT[index] = new Triangle(vertT[x][y],vertT[x+1][y],vertT[x+1][y+1]);
              index++;
              triT[index] = new Triangle(vertT[x][y],vertT[x+1][y+1],vertT[x][y+1]);
              index++;
          } 
        }
    }
    
    //initialize the bottom face
    void initBottom()
    {
        float[][][] vertBt = new float[CUBE_DIVISIONS+1][CUBE_DIVISIONS+1][3];
        final float yPos = -CUBE_SIZE/2;
        int xOff = 0;
        int yOff = 0;
        
        for(int y =0; y < CUBE_DIVISIONS+1; y++)
        {
          for(int x = 0; x<CUBE_DIVISIONS+1;x++)
          {
            vertBt[x][y][X] = (-CUBE_SIZE/2)+xOff;
            vertBt[x][y][Y] = yPos;
            vertBt[x][y][Z] = (CUBE_SIZE/2)+yOff;
            
            xOff += squareLength;
          }
          
          yOff -= squareLength;
          xOff = 0;
        }
        int index = 0;
        for(int y=0;y<CUBE_DIVISIONS;y++)
        {
          for(int x = 0;x<CUBE_DIVISIONS;x++)
          {
              triBt[index] = new Triangle(vertBt[x][y],vertBt[x+1][y+1],vertBt[x+1][y]);
              index++;
              triBt[index] = new Triangle(vertBt[x][y],vertBt[x][y+1],vertBt[x+1][y+1]);
              index++;
          } 
        }
    }
    
    //initialize the right face
    void initRight()
    {
        float[][][] vertR = new float[CUBE_DIVISIONS+1][CUBE_DIVISIONS+1][3];
        final float xPos = CUBE_SIZE/2;
        int xOff = 0;
        int yOff = 0;
        
        for(int y =0; y < CUBE_DIVISIONS+1; y++)
        {
          for(int x = 0; x<CUBE_DIVISIONS+1;x++)
          {
            vertR[x][y][X] = xPos;
            vertR[x][y][Y] = (CUBE_SIZE/2)+yOff;
            vertR[x][y][Z] = (-CUBE_SIZE/2)+xOff;
            
            xOff += squareLength;
          }
          
          yOff -= squareLength;
          xOff = 0;
        }
        
        int index = 0;
        for(int y=0;y<CUBE_DIVISIONS;y++)
        {
          for(int x = 0;x<CUBE_DIVISIONS;x++)
          {
              triR[index] = new Triangle(vertR[x][y],vertR[x+1][y],vertR[x+1][y+1]);
              index++;
              triR[index] = new Triangle(vertR[x][y],vertR[x+1][y+1],vertR[x][y+1]);
              index++;
          } 
        }
    }
    
    //initialize the left face
    void initLeft()
    {
        float[][][] vertL = new float[CUBE_DIVISIONS+1][CUBE_DIVISIONS+1][3];
        final float xPos = -CUBE_SIZE/2;
        int xOff = 0;
        int yOff = 0;
        
        for(int y =0; y < CUBE_DIVISIONS+1; y++)
        {
          for(int x = 0; x<CUBE_DIVISIONS+1;x++)
          {
            vertL[x][y][X] = xPos;
            vertL[x][y][Y] = (CUBE_SIZE/2)+yOff;
            vertL[x][y][Z] = (-CUBE_SIZE/2)+xOff;
            
            xOff += squareLength;
          }
          
          yOff -= squareLength;
          xOff = 0;
        }
        
        int index = 0;
        for(int y=0;y<CUBE_DIVISIONS;y++)
        {
          for(int x = 0;x<CUBE_DIVISIONS;x++)
          {
              triL[index] = new Triangle(vertL[x][y],vertL[x+1][y+1],vertL[x+1][y]);
              index++;
              triL[index] = new Triangle(vertL[x][y],vertL[x][y+1],vertL[x+1][y+1]);
              index++;
          } 
        }
    }

    //returns an array of all the triangles
    //concat might not be fastest, but this is only called once
    Triangle[] getTri()
    {
      Triangle[] t = (Triangle[])concat(triF,triB);
      t = (Triangle[])concat(t,triT);
      t = (Triangle[])concat(t,triBt);
      t = (Triangle[])concat(t,triR);
      t = (Triangle[])concat(t,triL);
      return t;
    }
}
