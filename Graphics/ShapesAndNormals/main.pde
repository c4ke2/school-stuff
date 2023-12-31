/*
 This program builds 3D shapes from algorithms that place
 pixels on the raster.
*/

// for the test mode with one triangle
Triangle[] singleTriangle;
Triangle[] rotatedSingleTriangle;

// for drawing and rotating the cube
Triangle[] cubeList;
Triangle[] rotatedCubeList;

// for drawing and rotating the sphere
Sphere sph;
Triangle[] sphereList;
Triangle[] rotatedSphereList;
Cube c;

// to make the image rotate - don't change these values
float theta = 0.0;  // rotation angle
float dtheta = 0.01; // rotation speed

PGraphics buffer;

void setup() {
  colorMode(RGB, 1.0f);  // set RGB to 0..1 instead of 0..255

  buffer = createGraphics(600, 600);

  //triangle for single triangle mode
  float[] singTriV1 = {-120,40,1};
  float[] singTriV2 = {120,-40,1};
  float[] singTriV3 = {20,160,1};
  singleTriangle = new Triangle[]{new Triangle(singTriV1,singTriV2,singTriV3)};
  rotatedSingleTriangle = copyTriangleList(singleTriangle);

  // draw a rotating cube made of triangles
  c = new Cube();
  c.initAll();
  cubeList = c.getTri();
  rotatedCubeList = copyTriangleList(cubeList);

  // draw a rotating sphere made of triangles
  sph = new Sphere(SPHERE_RADIUS, PHI_DIVISIONS, THETA_DIVISIONS);
  sphereList = sph.getTessellation();
  rotatedSphereList = copyTriangleList(sphereList);

  printSettings();
}

void settings() {
  size(600, 600); // hard-coded canvas size, same as the buffer
}

/*
You should read this function carefully and understand how it works,
 but you should not need to edit it
 */
void draw() {
  buffer.beginDraw();
  buffer.colorMode(RGB, 1.0f);
  buffer.background(0); // clear to black each frame

  /*
  CAUTION: none of your functions should call loadPixels() or updatePixels().
   This is already done in the template. Extra calls will probably break things.
   */
  buffer.loadPixels();

  if (doRotate) {
    theta += dtheta;
    if (theta > TWO_PI) theta -= TWO_PI;
  }

  //do not change these blocks: rotation is already set up for you
  if (displayMode == DisplayMode.KNOT) {
    drawLissajousKnot();
  } else if (displayMode == DisplayMode.TEST_LINES) {
    testBresenham();
  } else if (displayMode == DisplayMode.TEST_TRIANGLE) {
    rotateTriangles(singleTriangle, rotatedSingleTriangle, theta);
    drawTriangles(rotatedSingleTriangle);
  } else if (displayMode == DisplayMode.TESSELLATE_CUBE) {
    rotateTriangles(cubeList, rotatedCubeList, theta);
    drawTriangles(rotatedCubeList);
  } else if (displayMode == DisplayMode.TESSELLATE_SPHERE) {
    rotateTriangles(sphereList, rotatedSphereList, theta);
    drawTriangles(rotatedSphereList);
  }

  buffer.updatePixels();
  buffer.endDraw();
  image(buffer, 0, 0); // draw our raster image on the screen
}

/*
 Receives an array of triangles and draws them on the raster by
 calling draw2DTriangle()
 */
void drawTriangles(Triangle[] triangles) 
{
  for(int i=0;i<triangles.length;i++)
    draw2DTriangle(triangles[i]); 
}

/*
Use the projected vertices to draw the 2D triangle on the raster.
 Several tasks need to be implemented:
 - cull degenerate or back-facing triangles
 - draw triangle edges using bresenhamLine()
 - draw normal vectors if needed
 - fill the interior using fillTriangle()
 */
void draw2DTriangle(Triangle t) 
{  
  float[] e1 = subtract(t.projV2,t.projV1);
  float[] e2 = subtract(t.projV3,t.projV1);
  
  float cross = cross2D(e1,e2);

  if(cross>=0)
  {
    if(shadingMode != ShadingMode.NONE)
      fillTriangle(t);
      
    if(doOutline)
    {
      setColor(OUTLINE_COLOR);
      
      //draw v1 to v2
      bresenhamLine((int)t.projV1[X], (int)t.projV1[Y], (int)t.projV2[X], (int)t.projV2[Y]) ;
      //draw v2 to v3
      bresenhamLine((int)t.projV2[X], (int)t.projV2[Y], (int)t.projV3[X], (int)t.projV3[Y]) ;
      //draw v3 to v1
      bresenhamLine((int)t.projV3[X], (int)t.projV3[Y], (int)t.projV1[X], (int)t.projV1[Y]) ;
    }
    
    if(doNormals)
      drawNormals(t);
  }
}

/*
 For debugging purposes, draw the normal vectors to each vertex
 and triangle center
 */
final int NORMAL_LENGTH = 20;
final float[] FACE_NORMAL_COLOR = {0f, 1f, 1f}; // cyan
final float[] VERTEX_NORMAL_COLOR = {1f, 1f, 0f}; // yellow

void drawNormals(Triangle t) 
{  
  float[] projCenter = projectVertex(t.center);
  float[] N1 = t.n1;
  rescaleVec(N1,NORMAL_LENGTH);
  float[] N2 = t.n2;
  rescaleVec(N2,NORMAL_LENGTH);
  float[] N3 = t.n3;
  rescaleVec(N3,NORMAL_LENGTH);
  float[] N = t.n;
  rescaleVec(N,NORMAL_LENGTH);
  
  //get end points for drawing normal vectors
  float[] endN1 = {t.v1[X] + N1[X], t.v1[Y]+N1[Y], t.v1[Z]+N1[Z]};
  endN1 = projectVertex(endN1);
  float[] endN2 = {t.v2[X] + N2[X], t.v2[Y]+N2[Y], t.v2[Z]+N2[Z]};
  endN2 = projectVertex(endN2);
  float[] endN3 = {t.v3[X] + N3[X], t.v3[Y]+N3[Y], t.v3[Z]+N3[Z]};
  endN3 = projectVertex(endN3);
  float[] endN4 = {t.center[X] + N[X], t.center[Y]+N[Y], t.center[Z]+N[Z]};
  endN4 = projectVertex(endN4);
  
  //draw the vectors
  setColor(VERTEX_NORMAL_COLOR);
  bresenhamLine((int)t.projV1[X],(int)t.projV1[Y],(int)endN1[X],(int)endN1[Y]);
  bresenhamLine((int)t.projV2[X],(int)t.projV2[Y],(int)endN2[X],(int)endN2[Y]);
  bresenhamLine((int)t.projV3[X],(int)t.projV3[Y],(int)endN3[X],(int)endN3[Y]);
  setColor(FACE_NORMAL_COLOR);
  bresenhamLine((int)projCenter[X],(int)projCenter[Y],(int)endN4[X],(int)endN4[Y]);
}

/*
Fill the 2D triangle on the raster, using a scanline algorithm.
 Modify the raster using setColor() and setPixel() ONLY.
 The various shading modes should be implemented here.
 */
void fillTriangle(Triangle t) 
{
  //create the bounding box
  float maxX = getMax(t.projV1[X],t.projV2[X]);
  maxX = getMax(maxX,t.projV3[X]);
  float minX = getMin(t.projV1[X],t.projV2[X]);
  minX = getMin(t.projV3[X],minX);
  float maxY = getMax(t.projV1[Y],t.projV2[Y]);
  maxY = getMax(maxY,t.projV3[Y]);
  float minY = getMin(t.projV1[Y],t.projV2[Y]);
  minY = getMin(t.projV3[Y],minY);

  if(shadingMode == ShadingMode.FLAT)
    setColor(FILL_COLOR);
    
  if(shadingMode == ShadingMode.PHONG_FACE)
     setColor(phong(t.center,t.n,EYE,LIGHT,MATERIAL,FILL_COLOR,PHONG_SHININESS));
  
  float[] v1Ph = new float[3];
  float[] v2Ph = new float[3];
  float[] v3Ph = new float[3];
  float[] avgPh = new float[3];

  if(shadingMode == ShadingMode.PHONG_VERTEX || shadingMode == ShadingMode.PHONG_GOURAUD || shadingMode == ShadingMode.PHONG_SHADING)
  {
     //get the average from each vertex
     v1Ph = phong((t.v1),t.n1,EYE,LIGHT,MATERIAL,FILL_COLOR,PHONG_SHININESS);
     v2Ph = phong((t.v2),t.n2,EYE,LIGHT,MATERIAL,FILL_COLOR,PHONG_SHININESS);
     v3Ph = phong((t.v3),t.n3,EYE,LIGHT,MATERIAL,FILL_COLOR,PHONG_SHININESS);
     
     if(shadingMode == ShadingMode.PHONG_VERTEX)
     {
       avgPh = new float[]{(v1Ph[R]+v2Ph[R]+v3Ph[R])/3, (v1Ph[G]+v2Ph[G]+v3Ph[G])/3,(v1Ph[B]+v2Ph[B]+v3Ph[B])/3};
       setColor(avgPh);
     }
  }
  
  //for each pixel in the bounding box, draw if in triangle
  for(int y = (int)minY;y<(int)maxY+1;y++)
  {
    for(int x = (int)minX;x<(int)maxX+1;x++)
    {
      if(pointInTriangle(x,y,t))
      {
        if(shadingMode == ShadingMode.BARYCENTRIC || shadingMode == ShadingMode.PHONG_GOURAUD || shadingMode == ShadingMode.PHONG_SHADING)
        {
          //get barycentric coordinates
          float tArea = ((maxY-minY)*(maxX-minX))/2.0;
          float[] p = {x,y,0};
          float[] p1 = subtract(p,t.projV1);
          float[] p2 = subtract(p,t.projV2);
          float[] p3 = subtract(p,t.projV3);
          
          float[] e1 = subtract(t.projV2,t.projV1);
          float[] e2 = subtract(t.projV3,t.projV2);
          float[] e3 = subtract(t.projV1,t.projV3);
          
          float u = ((cross2D(e2,p2))/2)/tArea;
          float v = ((cross2D(e3,p3))/2)/tArea;
          float w;  //calculated slightly differently on where it's used
          
          if(shadingMode == ShadingMode.BARYCENTRIC)
          {
              w = ((cross2D(e1,p1))/2)/tArea;    //Barycentric shading gets a bit blue when this is changed to the cheap version
              setColor(new float[] {u,v,w});
          }
          else if(shadingMode == ShadingMode.PHONG_GOURAUD)
          {
            //gouraud shading
             w = 1 - u - v;  //gouraud doesn't like the expensive calculation
             setColor(new float[]{(u*v1Ph[R]+v*v2Ph[R]+w*v3Ph[R]),(u*v1Ph[G]+v*v2Ph[G]+w*v3Ph[G]),(u*v1Ph[B]+v*v2Ph[B]+w*v3Ph[B])});
          }
          else if(shadingMode == ShadingMode.PHONG_SHADING)
          {
            //phong shading
            if(displayMode == DisplayMode.TESSELLATE_SPHERE)
            {
              //calculate a normal from the barycentrics
               w = ((cross2D(e1,p1))/2)/tArea;  //phong is more smooth with this version of the calculation
              float[] ncpy1 = Arrays.copyOf(t.n1, t.n1.length);
              float[] ncpy2 = Arrays.copyOf(t.n2, t.n2.length);
              float[] ncpy3 = Arrays.copyOf(t.n3, t.n3.length);
              float[] pN = addition(addition(scalerMult(ncpy1,u),scalerMult(ncpy2,v)),scalerMult(ncpy3,w));
            
              setColor(phong(p,pN,EYE,LIGHT,MATERIAL,FILL_COLOR,PHONG_SHININESS));
            }
            else  //only do the costlier stuff when needed: this is fine for the cube/single triangle.  using the above for them also works, but is not needed
             setColor(phong(p,t.n,EYE,LIGHT,MATERIAL,FILL_COLOR,PHONG_SHININESS));
          }
        }
        //draw the pixel
        setPixel(x,y);
      }
    }
  }
}

/*
  pointInTriangle
  given a 2D point, determines it it is in triangle t

  x and y are the coordinates for the point.
*/
boolean pointInTriangle(int x, int y, Triangle t)
{
  float[] p = {x,y,0};
  
  //get vectors from p to vertices
  float[] p1 = subtract(p,t.projV1);
  float[] p2 = subtract(p,t.projV2);
  float[] p3 = subtract(p,t.projV3);
  
  //get the edges of the projected vertices
  float[] e1 = subtract(t.projV2,t.projV1);
  float[] e2 = subtract(t.projV3,t.projV2);
  float[] e3 = subtract(t.projV1,t.projV3);
  
  //calculate the cross products
  float cross1 = cross2D(e1,p1);
  float cross2 = cross2D(e2,p2);
  float cross3 = cross2D(e3,p3);

  //return true if the sign of each cross product is the same
  return ((cross1<=0 && cross2<=0 && cross3<=0)||(cross1>=0&&cross2>=0&&cross3>=0));
}

/*
Given a point p, unit normal vector n, eye location, light location, and various
 material properties, calculate the Phong lighting at that point (see course
 notes and the assignment text for more details).
 Return a vector of length 3 containing the calculated RGB values.
 */
float[] phong(float[] p, float[] n, float[] eye, float[] light,
  float[] material, float[] fillColor, float shininess) 
{
  normalizeVec(n);
  float[] L = subtract(light,p);
  normalizeVec(L);
  float[] V = subtract(eye,p);
  normalizeVec(V);

  //constants
  float mA = material[A];
  float mD = material[D];
  float mS = material[S];
  
  //ambient
  float[] amb = new float[]{fillColor[R],fillColor[G],fillColor[B]};
  
  //diffuse
  float[] diff = new float[]{fillColor[R],fillColor[G],fillColor[B]};

  if(dotProduct(L,n)>0)
  {
    diff = scalerMult(diff,dotProduct(L,n));
  }
  else
  {
    mD = 0;
  }
   
  //specular
  //calculate the reflection vector
  float[] RCoeff = new float[]{n[X],n[Y],n[Z]};
  scalerMult(RCoeff,2*dotProduct(RCoeff,L));
  float[] Rvec = subtract(RCoeff,L);
  normalizeVec(Rvec);
  
  float[] spec = {0,0,0};
  if(dotProduct(Rvec,V)>SPECULAR_FLOOR)
  {
    float coeff = pow(dotProduct(Rvec,V),shininess);
     spec[R] = fillColor[R] * coeff;
     spec[G] = fillColor[G] * coeff;
     spec[B] = fillColor[B] * coeff;
  }
  
  //get final lighting
  float[] lighting = new float[3];
  lighting[R] = mA*amb[R] + mD*diff[R] + mS*spec[R];
  lighting[G] = mA*amb[G] + mD*diff[G] + mS*spec[G];
  lighting[B] = mA*amb[B] + mD*diff[B] + mS*spec[B];
  
  return lighting;
}
