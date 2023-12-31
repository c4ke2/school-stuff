class Triangle {
  boolean onSphere;

  // positions of three triangle vertices in 3D space
  float[] v1;
  float[] v2;
  float[] v3;

  // position in 3D space of the center of the triangle - required
  float[] center;

  // normal vectors - required
  float[] n; // at center
  float[] n1; // at vertices
  float[] n2;
  float[] n3;
  
  // you can add more data such as edges, projected vertices, projected edges...
  
  float[] projV1;
  float[] projV2;
  float[] projV3;
  
  float[] e1;
  float[] e2;
  float[] e3;

  Triangle(float[] v1, float[] v2, float[] v3) 
  {
    this(v1, v2, v3, false);
  }

  Triangle(float[] v1, float[] v2, float[] v3, boolean spherical) {
    this.v1 = Arrays.copyOf(v1, v1.length);
    this.v2 = Arrays.copyOf(v2, v2.length);
    this.v3 = Arrays.copyOf(v3, v3.length);
    onSphere = spherical;
    updateAll();
  }

  // copy in a new set of 3D vertices - don't change
  void setVertices(float[] newV1, float[] newV2, float[] newV3) {
    System.arraycopy(newV1, 0, v1, 0, newV1.length);
    System.arraycopy(newV2, 0, v2, 0, newV2.length);
    System.arraycopy(newV3, 0, v3, 0, newV3.length);
    updateAll();
  }

  // if triangle vertices change, update remaining data
  void updateAll() 
  {
    // update center, n, n1, n2, n3 and any other vectors here
    
    center = new float[]
    {    
      (v1[X] + v2[X] + v3[X])/3,
      (v1[Y] + v2[Y] + v3[Y])/3,
      (v1[Z] + v2[Z] + v3[Z])/3
    };
    
    projV1 = projectVertex(v1);
    projV2 = projectVertex(v2);
    projV3 = projectVertex(v3);
    
    e1 = subtract(v1,v2);
    e2 = subtract(v2,v3);
    e3 = subtract(v3,v1);
    
    n1 = cross3D(e1,e2);
    n2 = cross3D(e2,e3);
    n3 = cross3D(e3,e1);

    n = cross3D(e1,e2);

    if (onSphere) {
      updateSphericalCenterNormals();
    }
  }

  // calculations to make the curved surface look curved - do not change!
  void updateSphericalCenterNormals() {
    rescaleVec(center, SPHERE_RADIUS);

    n = Arrays.copyOf(center, center.length);
    normalizeVec(n);
    n1 = Arrays.copyOf(v1, v1.length);
    normalizeVec(n1);
    n2 = Arrays.copyOf(v2, v2.length);
    normalizeVec(n2);
    n3 = Arrays.copyOf(v3, v3.length);
    normalizeVec(n3);
  }

  // add data or methods or edit the methods above as needed
}

void rotateTriangles(Triangle[] original, Triangle[] rotated, float theta)
{
  for (int i = 0; i < original.length; i++) {
    float[] rv1 = getRotatedVertex(original[i].v1, theta);
    float[] rv2 = getRotatedVertex(original[i].v2, theta);
    float[] rv3 = getRotatedVertex(original[i].v3, theta);
    rotated[i].setVertices(rv1, rv2, rv3);
  }
}

/*
Parameter v is a 3D vector. Return a copy of v after
 rotating by angle theta about the x, y and z axes in succession.
 This math will be covered later in the course.
 */
float[] getRotatedVertex(float[] v, float theta) {
  float[] r = Arrays.copyOf(v, v.length);
  for (int axis=X; axis<=Z; axis++) {
    eulerRotate(r, theta, axis);
  }
  return r;
}

/*
Rotate 3D vector in place about the given axis
 */
void eulerRotate(float[] v, float theta, int rotateIndex) {
  int ind1 = (rotateIndex+1) % NUM_DIMENSIONS;
  int ind2 = (rotateIndex+2) % NUM_DIMENSIONS;

  float tmp1, tmp2;

  tmp1 = v[ind1]*cos(theta) - v[ind2]*sin(theta);
  tmp2 = v[ind1]*sin(theta) + v[ind2]*cos(theta);
  v[ind1] = tmp1;
  v[ind2] = tmp2;
}

Triangle[] copyTriangleList(Triangle[] originalList) {
  if (originalList == null) return null;
  Triangle[] copyList = new Triangle[originalList.length];
  for (int i=0; i<originalList.length; i++) {
    copyList[i] = new Triangle(originalList[i].v1, originalList[i].v2, originalList[i].v3, originalList[i].onSphere);
  }
  return copyList;
}
