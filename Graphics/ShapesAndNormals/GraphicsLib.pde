import java.util.Arrays;

// GLOBAL CONSTANTS

// when you store (x,y) or (x,y,z) coordinates in an array,
// USE THESE NAMED CONSTANTS to access the entries
final int X = 0;
final int Y = 1;
final int Z = 2;
final int NUM_DIMENSIONS = 3;

// when you store (r,g,b) values in an array,
//USE THESE NAMED CONSTANTS to access the entries
final int R = 0;
final int G = 1;
final int B = 2;

// when you store (ambient,diffuse,specular) values in an array,
//USE THESE NAMED CONSTANTS to access the entries
final int A = 0;
final int D = 1;
final int S = 2;

// colors for drawing triangle meshes
final float[] OUTLINE_COLOR = {1.0, 0.3, 0.1};  // RGB
final float[] FILL_COLOR    = {1.0, 1.0, 1.0}; // RGB

// for projection and lighting
final float[] EYE = {0, 0, 600}; // location

// reasonable defaults for Phong lighting
final float[] LIGHT = {300, 300, 350}; // location
final float[] MATERIAL = {.35, .45, 0.3}; // ambient, diffuse, specular
final float PHONG_SHININESS = 50; // exponent

/*
 A shortcut, because exponents are costly: only include the specular term
 if (R dot V) > SPECULAR_FLOOR
 */
final float SPECULAR_CUTOFF = 0.01; // specular below this is capped to 0
final float SPECULAR_FLOOR = (float)Math.pow(SPECULAR_CUTOFF, 1/PHONG_SHININESS);

// to change the current color
color stateColor;
void setColor(float[] col) {
  stateColor = color(col[R], col[G], col[B]);
}

// for convenience, the color can be passed in different forms
void setColor(color c) {
  stateColor = c;
}

// draw a pixel at the given location
void setPixel(float x, float y) {
  int index = indexFromXYCoord(x, y);
  if (0 <= index && index < buffer.pixels.length) {
    buffer.pixels[index] = stateColor;
  } else {
    println("ERROR:  this pixel is not within the raster.");
  }
}

// helper functions for pixel calculations
int indexFromXYCoord(float x, float y) {
  int col = colNumFromXCoord(x);
  int row = rowNumFromYCoord(y);
  return indexFromColRow(col, row);
}

int colNumFromXCoord(float x) {
  return (int)round(x + width/2);
}

int rowNumFromYCoord(float y) {
  return (int)round(height/2 - y);
}

int indexFromColRow(int col, int row) {
  return row*width + col;
}

/*
 Perspective projection. Parameter v is a 3D vector, return value is a 2D vector.
 Returns null if v is behind the position of the eye -- watch out for that result
 when you use this function in your code!
 The math being implemented here will be covered later in the course.
 */
final float PERSPECTIVE = 0.002; // don't change this value
float[] projectVertex(float[] v) {
  float adjZ = v[Z] - EYE[Z];  // negative z direction points into the screen
  if (adjZ >= 0) return null; // clipping plane at z coord of eye
  adjZ = -adjZ; // use |z| for division

  float[] p = new float[2];
  for (int coord=X; coord<=Y; coord++) {
    p[coord] = v[coord] / (adjZ*PERSPECTIVE);
  }

  return p;
}
