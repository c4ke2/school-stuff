/*
Here are some of the math operations that I found useful. The ones I use to draw the 
sphere are already filled in. A few more are left as stubs. You can complete any or all
of these definitions and add more as needed.
*/

// create and return the vector v-w
float[] subtract(float[] v, float[] w) 
{
  float[] result = new float[v.length];
  
  result[X] = v[X]-w[X];
  result[Y] = v[Y]-w[Y];
  
  if(v.length>2 && w.length>2)
    result[Z] = v[Z]-w[Z];
  
  return result;
}

//create and turn v+w
float[] addition(float[] v, float[] w) 
{
  float[] result = new float[v.length];
  
  result[X] = v[X]+w[X];
  result[Y] = v[Y]+w[Y];
  
  if(v.length>2 && w.length>2)
    result[Z] = v[Z]+w[Z];
  
  return result;
}

// the 2D cross product, as discussed in Unit 1
// v and w are 2D vectors, result is a scalar
float cross2D(float[] v, float[] w) 
{
  //v x w = (0,0,vxwy-wxvy)
  return ((v[X]*w[Y])-(w[X]*v[Y]));
}

// the 3D cross product
// v and w are 3D vectors, result is a 3D vector
float[] cross3D(float[] v, float[] w) 
{
  float[] result = new float[3];
  
  //v x w = (vywz-vzwy,vzwx-vxwz,vxwy-wxvy)
  
  result[0]=(v[Y]*w[Z])-(v[Z]*w[Y]);
  result[1]=(v[Z]*w[X])-(v[X]*w[Z]);
  result[2]=(v[X]*w[Y])-(v[Y]*w[X]);
  
  return result;
}

// dot product
// v and w are vectors of the same length, result is a scalar
float dotProduct(float[] v, float[] w) 
{
  return v[X]*w[X]+v[Y]*w[Y]+v[Z]*w[Z];
}

//returns the greater of two floats
float getMax(float a, float b)
{
  if(a>b)
    return a;
  else
    return b;
}

//returns the lesser of two floats
float getMin(float a, float b)
{
  if(a<b)
    return a;
  else
    return b;
}

//multiplies a vector v by scaler s
float[] scalerMult(float[] v,float s)
{
  for(int i=0;i<v.length;i++)
    v[i] = v[i]*s;
  return v;
}

/*
The functions below are already complete
*/

float lengthVec(float[] v) {
  float lengthSq = 0;
  for (int i=0; i<v.length; i++)
  {
    lengthSq += v[i]*v[i];
  }
  return sqrt(lengthSq);
}

void normalizeVec(float[] v) {
  float len = lengthVec(v);
  for (int i=0; i<v.length; i++)
  {
    v[i] /= len;
  }
}

void rescaleVec(float[] v, float newLength) {
  normalizeVec(v);
  for (int i=0; i<v.length; i++) {
    v[i] *= newLength;
  }
}
